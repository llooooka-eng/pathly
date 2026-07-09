import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pathly/models/goal.dart';
import 'package:pathly/services/goals_provider.dart';
import 'package:pathly/l10n/language_provider.dart';
import 'package:pathly/screens/goals_screen.dart';
import 'package:pathly/screens/progress_screen.dart';

/// انتظار قصير كي تكتمل عمليات الحفظ غير المنتظَرة (_save يعمل بلا await).
Future<void> _settleSave() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Goal serialization', () {
    test('round-trips through JSON', () {
      final g = Goal(
        id: 'x',
        title: 'Test',
        category: GoalCategory.coding,
        description: 'desc',
        startDate: DateTime(2024, 1, 1),
        targetDate: DateTime(2024, 6, 1),
        currentStreak: 5,
        totalDays: 5,
        progress: 0.42,
        lessons: const [
          DailyLesson(day: 1, content: 'c', translation: 't', isCompleted: true),
        ],
        isPro: true,
      );

      final back = Goal.fromJson(g.toJson());

      expect(back.id, 'x');
      expect(back.category, GoalCategory.coding);
      expect(back.startDate, DateTime(2024, 1, 1));
      expect(back.currentStreak, 5);
      expect(back.progress, closeTo(0.42, 1e-9));
      expect(back.lessons.single.isCompleted, true);
      expect(back.isPro, true);
    });
  });

  group('GoalsProvider', () {
    test('seeds default goals on first run', () async {
      final p = GoalsProvider();
      await p.load();
      expect(p.goals.length, 2);
      expect(p.primaryGoal, isNotNull);
    });

    test('free limit blocks adding; Pro unlocks custom goals', () async {
      final p = GoalsProvider();
      await p.load(); // 2 seed goals, free limit 1 => cannot add
      expect(p.canAddGoal, false);

      p.addCustomGoal(
          title: 'A', category: GoalCategory.custom, description: '', durationDays: 30);
      expect(p.goals.length, 2, reason: 'blocked while free');

      p.upgradeToPro();
      p.addCustomGoal(
          title: 'A', category: GoalCategory.custom, description: '', durationDays: 30);
      expect(p.goals.length, 3);
      expect(p.goals.last.title, 'A');
    });

    test('delete persists across provider instances', () async {
      final p = GoalsProvider();
      await p.load();
      final id = p.goals.first.id;
      p.deleteGoal(id);
      await _settleSave();

      final p2 = GoalsProvider();
      await p2.load();
      expect(p2.goals.any((g) => g.id == id), false);
      expect(p2.goals.length, 1);
    });

    test('replaceAll persists downloaded goals', () async {
      final p = GoalsProvider();
      await p.load();
      p.replaceAll([
        Goal(
          id: 'z',
          title: 'Restored',
          category: GoalCategory.reading,
          description: '',
          startDate: DateTime.now(),
          targetDate: DateTime.now(),
        ),
      ]);
      await _settleSave();

      final p2 = GoalsProvider();
      await p2.load();
      expect(p2.goals.length, 1);
      expect(p2.goals.single.id, 'z');
    });
  });

  group('Widget smoke tests', () {
    Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
      // حجم شاشة هاتف واقعي (‎~390x844‎) مع inset لشريط الحالة (‎47px‎)
      // كي تتصرّف ترويسات SliverAppBar كما على جهاز حقيقي.
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      tester.view.padding = const FakeViewPadding(top: 141);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      final goals = GoalsProvider();
      await goals.load();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: goals),
            ChangeNotifierProvider.value(value: LanguageProvider()),
          ],
          child: MaterialApp(home: screen),
        ),
      );
      await tester.pump();
    }

    testWidgets('GoalsScreen builds and shows goals', (tester) async {
      await pumpScreen(tester, const GoalsScreen());
      expect(tester.takeException(), isNull);
      expect(find.text('أهدافي'), findsWidgets);
    });

    testWidgets('ProgressScreen builds', (tester) async {
      await pumpScreen(tester, const ProgressScreen());
      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });
  });
}
