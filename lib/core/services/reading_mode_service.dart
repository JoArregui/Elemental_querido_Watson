import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modo de juego del lector:
/// - simple (false): navegación libre, se puede pasar de página sin resolver.
/// - exigente (true): hay que acertar el acertijo para pasar de página.
class ReadingModeService extends ValueNotifier<bool> {
  static const _key = 'reading_mode_strict';

  ReadingModeService() : super(false);

  bool get isStrict => value;
  bool get isSimple => !value;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_key) ?? false;
  }

  /// Relee el modo guardado (tras importar un .elemental).
  Future<void> reload() async {
    await init();
    notifyListeners();
  }

  Future<void> setStrict(bool strict) async {
    value = strict;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, strict);
  }

  Future<void> toggle() => setStrict(!value);
}
