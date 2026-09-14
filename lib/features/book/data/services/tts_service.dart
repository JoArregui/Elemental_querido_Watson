import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Lectura en voz alta (audiolibro) en español.
/// Todo va envuelto en try/catch para que la app nunca se rompa
/// si el dispositivo no tiene motor de voz disponible.
class TtsService {
  FlutterTts? _tts;
  bool _ready = false;
  VoidCallback? _onComplete;

  Future<void> _ensureReady() async {
    if (_ready) return;
    try {
      final tts = FlutterTts();
      await tts.setLanguage('es-ES');
      await tts.setSpeechRate(0.5);
      await tts.setPitch(1.0);
      tts.setCompletionHandler(() => _onComplete?.call());
      tts.setCancelHandler(() => _onComplete?.call());
      tts.setErrorHandler((_) => _onComplete?.call());
      _tts = tts;
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Se llama cuando la lectura termina (natural, detenida o con error).
  // ignore: avoid_setters_without_getters
  set onComplete(VoidCallback? cb) => _onComplete = cb;

  Future<void> speak(String text) async {
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
