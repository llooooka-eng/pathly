import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';

class GoalsProvider extends ChangeNotifier {
  final List<Goal> _goals = [
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
  }

  void upgradeToPro() {
    _isPro = true;
    notifyListeners();
  }
}
