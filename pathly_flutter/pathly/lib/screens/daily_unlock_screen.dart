import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../l10n/language_provider.dart';
import '../theme/app_theme.dart';
import 'language_picker_screen.dart';

class DailyUnlockScreen extends StatefulWidget {
  final Widget child;
  const DailyUnlockScreen({super.key, required this.child});

  @override
  State<DailyUnlockScreen> createState() => _DailyUnlockScreenState();
}

class _DailyUnlockScreenState extends State<DailyUnlockScreen> {
  bool _watching = false;

  @override
  Widget build(BuildContext context) {
    final ad = context.watch<AdService>();
    final lp = context.watch<LanguageProvider>();
    final s  = lp.s;

    if (ad.unlocked) return widget.child;

    return Scaffold(
      backgroundColor: PathlyTheme.surfaceAlt,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // زر اختيار اللغة في الأعلى
              Align(
                alignment: lp.isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LanguagePickerScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: PathlyTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: PathlyTheme.border, width: 0.5),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(lp.info.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(lp.info.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                              color: PathlyTheme.textSecondary)),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more_rounded, size: 14, color: PathlyTheme.textMuted),
                    ]),
                  ),
                ),
              ),

              const Spacer(),

              // Logo
              Column(children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: PathlyTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(s.appName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600,
                        color: PathlyTheme.textPrimary)),
                const SizedBox(height: 6),
                Text(s.appTagline,
                    style: const TextStyle(fontSize: 14, color: PathlyTheme.textMuted)),
              ]),

              const SizedBox(height: 32),

              // Unlock card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: PathlyTheme.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC4B5FD), width: 0.5),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: PathlyTheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.watchAd,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15,
                            color: Color(0xFF3C3489))),
                    const SizedBox(height: 2),
                    Text(s.toUnlockApp,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5B21B6))),
                  ])),
                ]),
              ),

              const SizedBox(height: 14),

              // Features
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PathlyTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PathlyTheme.border, width: 0.5),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.nowUnlocked,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                          color: PathlyTheme.textSecondary)),
                  const SizedBox(height: 10),
                  ...[s.aiHealthTips, s.dailyLesson, s.aiSportCoach, s.stepsTracking]
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: PathlyTheme.success),
                              const SizedBox(width: 10),
                              Expanded(child: Text(f,
                                  style: const TextStyle(fontSize: 13,
                                      color: PathlyTheme.textPrimary))),
                            ]),
                          )),
                ]),
              ),

              const Spacer(),

              // Button
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: (ad.adLoaded && !_watching)
                      ? _watch
                      : ((ad.isLoading || _watching) ? null : ad.loadAd),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PathlyTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: PathlyTheme.primary.withOpacity(0.5),
                  ),
                  child: (ad.isLoading || _watching)
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          const SizedBox(width: 10),
                          Text(s.loading, style: const TextStyle(fontSize: 15)),
                        ])
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.play_arrow_rounded, size: 22),
                          const SizedBox(width: 8),
                          Text(s.watchAdEnter,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ]),
                ),
              ),

              const SizedBox(height: 12),
              Text(s.adFreeSession,
                  style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _watch() async {
    setState(() => _watching = true);
    final rewarded = await context.read<AdService>().showAd();
    if (!rewarded && mounted) setState(() => _watching = false);
  }
}
