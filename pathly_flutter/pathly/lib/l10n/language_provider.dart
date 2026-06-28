import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _current = AppLanguage.arabic;

  AppLanguage get current => _current;
  AppStrings  get s       => AppStrings(_current);
  LanguageInfo get info   => LanguageInfo.fromLang(_current);
  bool get isRtl          => info.isRtl;
  Locale get locale       => info.locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language');
    if (saved != null) {
      final found = AppLanguage.values.where((l) => l.name == saved);
      if (found.isNotEmpty) _current = found.first;
    }
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _current = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang.name);
    notifyListeners();
  }
}
