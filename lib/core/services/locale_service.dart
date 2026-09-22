import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ValueNotifier<Locale> {
  static const _key = 'app_locale';
  LocaleService() : super(const Locale('es'));

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && ['es', 'en'].contains(code)) {
      value = Locale(code);
    } else {
      value = const Locale('es');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['es', 'en'].contains(locale.languageCode)) return;
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  bool get isEnglish => value.languageCode == 'en';
  bool get isSpanish => value.languageCode == 'es';
}
