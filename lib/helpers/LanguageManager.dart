// lib/helpers/LanguageManager.dart

import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english,
  turkish,
  french,
  dutch,
}

class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();

  factory LanguageManager() {
    return _instance;
  }

  LanguageManager._internal();

  static const String _langKey = 'selectedLanguage';

  AppLanguage currentLanguage = AppLanguage.english;

  /// Uygulama açıldığında çağır
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_langKey);
    if (savedLang != null) {
      currentLanguage = AppLanguage.values.firstWhere(
              (e) => e.toString() == savedLang,
          orElse: () => AppLanguage.english);
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang.toString());
  }
}
