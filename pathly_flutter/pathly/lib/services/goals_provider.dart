import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalsProvider extends ChangeNotifier {
  static const String _goalsKey = 'goals_data';
  static const String _proKey = 'is_pro';

  List<Goal> _goals = [];
  bool _isPro = false;
  final int _freeGoalLimit = 1;
  final _uuid = const Uuid();

  List<Goal> get goals => _goals;
  bool get isPro => _isPro;
  bool get canAddGoal => _isPro || _goals.length < _freeGoalLimit;

  Goal? get primaryGoal => _goals.isNotEmpty ? _goals.first : null;

  int get totalStreak {
    if (_goals.isEmpty) return 0;
    return _goals.map((g) => g.currentStreak).reduce((a, b) => a + b);
  }

  // ─── Persistence ────────────────────────────────────────────────────────
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_proKey) ?? false;

    final raw = prefs.getString(_goalsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _goals = list
            .map((e) => Goal.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // بيانات تالفة → نعود للأهداف الافتراضية
        _goals = _defaultGoals();
      }
    } else {
      // أول تشغيل: نبدأ بالأهداف الافتراضية ونحفظها
      _goals = _defaultGoals();
      await _save();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _goalsKey,
      jsonEncode(_goals.map((g) => g.toJson()).toList()),
    );
    await prefs.setBool(_proKey, _isPro);
  }

  // ─── Mutations ──────────────────────────────────────────────────────────
  void addGoal(GoalTemplate template) {
    if (!canAddGoal) return;
    final goal = Goal(
      id: _uuid.v4(),
      title: template.title,
      category: template.category,
      description: template.description,
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(Duration(days: template.durationDays)),
      currentStreak: 0,
      totalDays: 0,
      progress: 0.0,
    );
    _goals.add(goal);
    notifyListeners();
    _save();
  }

  void addCustomGoal({
    required String title,
    required GoalCategory category,
    required String description,
    required int durationDays,
  }) {
    if (!canAddGoal) return;
    final goal = Goal(
      id: _uuid.v4(),
      title: title,
      category: category,
      description: description,
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(Duration(days: durationDays)),
      currentStreak: 0,
      totalDays: 0,
      progress: 0.0,
    );
    _goals.add(goal);
    notifyListeners();
    _save();
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
    _save();
  }

  void completeLesson(String goalId) {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx == -1) return;
    final g = _goals[idx];
    _goals[idx] = g.copyWith(
      currentStreak: g.currentStreak + 1,
      totalDays: g.totalDays + 1,
      progress: (g.totalDays + 1) / 365,
    );
    notifyListeners();
    _save();
  }

  void upgradeToPro() {
    _isPro = true;
    notifyListeners();
    _save();
  }

  /// استبدال كل الأهداف (يُستخدم بعد الاسترجاع من السحابة).
  void replaceAll(List<Goal> goals) {
    _goals = List<Goal>.from(goals);
    notifyListeners();
    _save();
  }

  // ─── Seed data ──────────────────────────────────────────────────────────
  List<Goal> _defaultGoals() => [
        Goal(
          id: '1',
          title: 'اللغة الإسبانية',
          category: GoalCategory.language,
          description: 'جملة يومية حتى الطلاقة',
          startDate: DateTime.now().subtract(const Duration(days: 83)),
          targetDate: DateTime.now().add(const Duration(days: 282)),
          currentStreak: 84,
          totalDays: 84,
          progress: 0.23,
          lessons: [
            DailyLesson(day: 84, content: '¿Cómo estás hoy?', translation: 'كيف حالك اليوم؟'),
            DailyLesson(day: 83, content: '¿Cómo te llamas?', translation: 'ما اسمك؟', isCompleted: true),
            DailyLesson(day: 82, content: 'Buenos días', translation: 'صباح الخير', isCompleted: true),
          ],
        ),
        Goal(
          id: '2',
          title: 'اللياقة البدنية',
          category: GoalCategory.fitness,
          description: '30 دقيقة تمرين يومياً',
          startDate: DateTime.now().subtract(const Duration(days: 11)),
          targetDate: DateTime.now().add(const Duration(days: 79)),
          currentStreak: 12,
          totalDays: 12,
          progress: 0.13,
        ),
      ];
}
