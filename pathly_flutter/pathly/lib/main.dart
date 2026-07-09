import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'services/goals_provider.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'l10n/language_provider.dart';
import 'l10n/app_strings.dart';
import 'screens/home_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/daily_unlock_screen.dart';
import 'screens/language_picker_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final adService      = AdService();
  final langProvider   = LanguageProvider();
  final goalsProvider  = GoalsProvider();

  await NotificationService.instance.initialize();

  // تهيئة Firebase للمزامنة السحابية — تُعطَّل الميزة بأمان إن لم يكتمل الإعداد.
  // انظر FIREBASE_SETUP.md لخطوات التهيئة (flutterfire configure + ملفات المنصّات).
  try {
    await Firebase.initializeApp();
    SyncService.instance.firebaseReady = true;
  } catch (_) {
    SyncService.instance.firebaseReady = false;
  }

  await Future.wait([
    adService.initialize(),
    langProvider.load(),
    goalsProvider.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: goalsProvider),
        ChangeNotifierProvider.value(value: adService),
        ChangeNotifierProvider.value(value: langProvider),
      ],
      child: const PathlyApp(),
    ),
  );
}

class PathlyApp extends StatelessWidget {
  const PathlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();

    return MaterialApp(
      title: 'Pathly',
      theme: PathlyTheme.light,
      debugShowCheckedModeBanner: false,
      locale: lp.locale,
      supportedLocales: LanguageInfo.all.map((i) => i.locale).toList(),
      // WraP everything in Directionality so RTL languages (ar, ur) work properly
      builder: (context, child) => Directionality(
        textDirection: lp.isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      home: const DailyUnlockScreen(child: MainShell()),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GoalsScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalsProvider>();
    final lp       = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PathlyTheme.primary,
        elevation: 0,
        title: const Text('Pathly',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          // زر اختيار اللغة في شريط الأعلى
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LanguagePickerScreen())),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(lp.info.flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(lp.info.locale.languageCode.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          // زر الإعدادات (التذكير اليومي)
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PathlyTheme.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            if (i == 2) {
              final goal = provider.primaryGoal;
              if (goal != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => AIChatScreen(goal: goal)));
              }
              return;
            }
            setState(() => _currentIndex = i < 2 ? i : i - 1);
          },
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),   label: lp.s.navHome),
            BottomNavigationBarItem(
                icon: const Icon(Icons.flag_rounded),   label: lp.s.navGoals),
            BottomNavigationBarItem(
                icon: const Icon(Icons.auto_awesome_rounded), label: lp.s.navAI),
            BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_rounded),   label: lp.s.navProgress),
          ],
        ),
      ),
    );
  }
}
