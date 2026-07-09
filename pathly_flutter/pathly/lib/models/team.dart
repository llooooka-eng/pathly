/// نماذج الفريق (تعاون عبر Firestore).

class TeamMember {
  final String uid;
  final String email;
  final int streak;
  final int goals;

  const TeamMember({
    required this.uid,
    required this.email,
    required this.streak,
    required this.goals,
  });

  factory TeamMember.fromDoc(String uid, Map<String, dynamic> data) => TeamMember(
        uid: uid,
        email: (data['email'] as String?) ?? '',
        streak: (data['streak'] as num?)?.toInt() ?? 0,
        goals: (data['goals'] as num?)?.toInt() ?? 0,
      );
}

class Team {
  final String id;
  final String name;
  final String code;
  final String ownerUid;
  final List<TeamMember> members;

  const Team({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerUid,
    this.members = const [],
  });

  /// الأعضاء مرتّبون تنازليًا حسب الـ streak (لوحة التقدّم).
  List<TeamMember> get leaderboard {
    final sorted = List<TeamMember>.from(members)
      ..sort((a, b) => b.streak.compareTo(a.streak));
    return sorted;
  }
}
