import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../l10n/language_provider.dart';
import '../theme/app_theme.dart';

class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();

    return Directionality(
      textDirection: lp.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: PathlyTheme.surfaceAlt,
        appBar: AppBar(
          title: Text(lp.s.chooseLanguage),
          backgroundColor: PathlyTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: LanguageInfo.all.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final info = LanguageInfo.all[i];
            final selected = lp.current == info.lang;
            return GestureDetector(
              onTap: () {
                lp.setLanguage(info.lang);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? PathlyTheme.primaryLight : PathlyTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFC4B5FD)
                        : PathlyTheme.border,
                    width: selected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(info.flag, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? const Color(0xFF3C3489)
                                  : PathlyTheme.textPrimary,
                            ),
                          ),
                          Text(
                            info.nameEn,
                            style: TextStyle(
                              fontSize: 12,
                              color: selected
                                  ? const Color(0xFF5B21B6)
                                  : PathlyTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (info.isRtl)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('RTL',
                            style: TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w500)),
                      ),
                    const SizedBox(width: 8),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: PathlyTheme.primary, size: 22)
                    else
                      const Icon(Icons.radio_button_unchecked_rounded,
                          color: PathlyTheme.textMuted, size: 22),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
