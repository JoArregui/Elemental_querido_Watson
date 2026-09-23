import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ValueNotifier<bool> {
  static const _hcKey = 'a11y_high_contrast';
  static const _fontKey = 'a11y_font_scale';
  double _fontScale = 1.0;

  AccessibilityService() : super(false);

  bool get isHighContrast => value;
  double get fontScale => _fontScale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_hcKey) ?? false;
    _fontScale = prefs.getDouble(_fontKey) ?? 1.0;
  }

  Future<void> toggleHighContrast() async {
    value = !value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hcKey, value);
  }

  Future<void> cycleFontScale() async {
    // 1.0 -> 1.3 -> 1.6 -> 1.0
    if (_fontScale >= 1.6) {
      _fontScale = 1.0;
    } else if (_fontScale >= 1.3) {
      _fontScale = 1.6;
    } else {
      _fontScale = 1.3;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontKey, _fontScale);
  }

  String get fontLabel {
    if (_fontScale >= 1.6) return 'Extra grande';
    if (_fontScale >= 1.3) return 'Grande';
    return 'Normal';
  }
}
