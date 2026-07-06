import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/goal.dart';

/// المزامنة السحابية عبر Firebase (Auth + Firestore) وتسجيل دخول Google.
///
/// كل الاستدعاءات محميّة بـ [firebaseReady]؛ إن لم تُهيّأ Firebase (لم تُكمل
/// خطوات الإعداد في FIREBASE_SETUP.md) تبقى الميزة معطّلة دون أن يتعطّل التطبيق.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  /// تُضبط إلى true من main.dart بعد نجاح Firebase.initializeApp().
  bool firebaseReady = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser =>
      firebaseReady ? FirebaseAuth.instance.currentUser : null;
  bool get isSignedIn => currentUser != null;
  String? get userEmail => currentUser?.email;

  Future<User?> signInWithGoogle() async {
    if (!firebaseReady) return null;
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // ألغى المستخدم
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    if (!firebaseReady) return;
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  DocumentReference<Map<String, dynamic>>? get _doc {
    final user = currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  /// رفع الأهداف الحالية إلى السحابة (يستبدل النسخة المخزّنة).
  Future<void> uploadGoals(List<Goal> goals) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set({
      'goals': goals.map((g) => g.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// استرجاع الأهداف من السحابة، أو null إن لم توجد نسخة محفوظة.
  Future<List<Goal>?> downloadGoals() async {
    final doc = _doc;
    if (doc == null) return null;
    final snap = await doc.get();
    final data = snap.data();
    final rawGoals = data?['goals'];
    if (rawGoals is! List) return null;
    return rawGoals
        .map((e) => Goal.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
