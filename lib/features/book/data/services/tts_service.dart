import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/locale_service.dart';

/// Lectura en voz alta (audiolibro) en español.
/// Todo va envuelto en try/catch para que la app nunca se rompa
/// si el dispositivo no tiene motor de voz disponible.
class TtsService {
  FlutterTts? _tts;
  bool _ready = false;
  VoidCallback? _onComplete;

  String _lastLang = '';
  Future<void> _ensureReady() async {
    final loc = (() { try { return GetIt.I.get<LocaleService>().value.languageCode; } catch (_) { return 'es'; }})();
    final lang = loc == 'en' ? 'en-US' : 'es-ES';
    if (_ready && _lastLang == lang) return;
    try {
      final tts = _tts ?? FlutterTts();
      await tts.setLanguage(lang);
      await tts.setSpeechRate(0.5);
      await tts.setPitch(1.0);
      tts.setCompletionHandler(() => _onComplete?.call());
      tts.setCancelHandler(() => _onComplete?.call());
      tts.setErrorHandler((_) => _onComplete?.call());
      _tts = tts;
      _ready = true;
      _lastLang = lang;
    } catch (_) {
      _ready = false;
    }
  }

  /// Se llama cuando la lectura termina (natural, detenida o con error).
  // ignore: avoid_setters_without_getters
  set onComplete(VoidCallback? cb) => _onComplete = cb;

  Future<void> speak(String text) async {
    // Force re-check language on every speak (locale may have changed)
    _lastLang = '';
    await _ensureReady();
    try {
      await _tts?.stop();
      await _tts?.speak(text);
    } catch (_) {
      _onComplete?.call();
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {
      _onComplete?.call();
    }
  }
}
