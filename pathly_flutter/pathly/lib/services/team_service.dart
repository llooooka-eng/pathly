import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';
import 'sync_service.dart';

/// إدارة الفرق (تعاون) عبر Firestore. يتطلّب تسجيل الدخول عبر [SyncService].
///
/// البنية:
///   teams/{teamId}                         = { name, code, ownerUid, createdAt }
///   teams/{teamId}/members/{uid}           = { email, streak, goals, updatedAt }
///   users/{uid}.teamId                     = مرجع فريق المستخدم الحالي
class TeamService {
  TeamService._();
  static final TeamService instance = TeamService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  bool get _ready =>
      SyncService.instance.firebaseReady && SyncService.instance.isSignedIn;

  String? get _uid => SyncService.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  Future<String?> myTeamId() async {
    if (!_ready) return null;
    final snap = await _userDoc.get();
    return snap.data()?['teamId'] as String?;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random.secure();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  /// إنشاء فريق جديد وإضافة المستخدم كعضو. يعيد رمز الدعوة.
  Future<String?> createTeam(String name,
      {required int streak, required int goals}) async {
    if (!_ready) return null;
    final code = _generateCode();
    final teamRef = _db.collection('teams').doc();
    await teamRef.set({
      'name': name,
      'code': code,
      'ownerUid': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _addSelfAsMember(teamRef.id, streak: streak, goals: goals);
    return code;
  }

  /// الانضمام لفريق عبر رمز الدعوة. يعيد true عند النجاح، false إن لم يوجد.
  Future<bool> joinTeam(String code,
      {required int streak, required int goals}) async {
    if (!_ready) return false;
    final query = await _db
        .collection('teams')
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;
    await _addSelfAsMember(query.docs.first.id, streak: streak, goals: goals);
    return true;
  }

  Future<void> _addSelfAsMember(String teamId,
      {required int streak, required int goals}) async {
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(_uid)
        .set({
      'email': SyncService.instance.userEmail ?? '',
      'streak': streak,
      'goals': goals,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _userDoc.set({'teamId': teamId}, SetOptions(merge: true));
  }

  /// تحديث إحصائيات المستخدم داخل فريقه (لتحديث لوحة التقدّم).
  Future<void> pushMyStats({required int streak, required int goals}) async {
    if (!_ready) return;
    final teamId = await myTeamId();
    if (teamId == null) return;
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(_uid)
        .set({
      'email': SyncService.instance.userEmail ?? '',
      'streak': streak,
      'goals': goals,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> leaveTeam() async {
    if (!_ready) return;
    final teamId = await myTeamId();
    if (teamId == null) return;
    await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(_uid)
        .delete();
    await _userDoc.set({'teamId': FieldValue.delete()}, SetOptions(merge: true));
  }

  /// جلب فريق المستخدم الحالي مع أعضائه، أو null إن لم يكن في فريق.
  Future<Team?> getMyTeam() async {
    if (!_ready) return null;
    final teamId = await myTeamId();
    if (teamId == null) return null;

    final teamSnap = await _db.collection('teams').doc(teamId).get();
    final data = teamSnap.data();
    if (data == null) return null;

    final membersSnap = await _db
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .get();
    final members = membersSnap.docs
        .map((d) => TeamMember.fromDoc(d.id, d.data()))
        .toList();

    return Team(
      id: teamId,
      name: (data['name'] as String?) ?? '',
      code: (data['code'] as String?) ?? '',
      ownerUid: (data['ownerUid'] as String?) ?? '',
      members: members,
    );
  }
}
