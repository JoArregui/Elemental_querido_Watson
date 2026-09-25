import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/locale_service.dart';

/// Progreso de palabra emitido por flutter_tts.
class TtsProgress {
  final String text;
  final int start;
  final int end;
  final String word;
  const TtsProgress(this.text, this.start, this.end, this.word);
}

/// Lectura en voz alta (audiolibro) en español / inglés — C3: narración mejorada.
/// Incluye resaltado de palabra (progressHandler), pausa por frase y control de pausa/reanudación.
/// Todo va envuelto en try/catch para que la app nunca se rompa si el dispositivo no tiene motor TTS.
class TtsService {
  FlutterTts? _tts;
  bool _ready = false;
  VoidCallback? _onComplete;

  // C3: progreso de palabra y oraciones
  final StreamController<TtsProgress> _progressController = StreamController<TtsProgress>.broadcast();
  Stream<TtsProgress> get progress => _progressController.stream;
  final StreamController<int> _sentenceController = StreamController<int>.broadcast();
  Stream<int> get sentenceIndex => _sentenceController.stream;

  String _lastLang = '';
  String _fullText = '';
  List<String> _sentences = [];
  List<int> _sentenceStarts = [];
  int _currentSentence = 0;
  bool _isPaused = false;
  bool _stopRequested = false;
  Completer<void>? _sentenceCompleter;

  bool get isPaused => _isPaused;

  Future<void> _ensureReady() async {
    final loc = (() { try { return GetIt.I.get<LocaleService>().value.languageCode; } catch (_) { return 'es'; }})();
    final lang = loc == 'en' ? 'en-US' : 'es-ES';
    if (_ready && _lastLang == lang) return;
    try {
      final tts = _tts ?? FlutterTts();
      await tts.setLanguage(lang);
      await tts.setSpeechRate(0.46);
      await tts.setPitch(1.0);
      // iOS/Android necesitan setVolume previo
      await tts.setVolume(1.0);
      tts.setCompletionHandler(() {
        if (_sentenceCompleter != null && !_sentenceCompleter!.isCompleted) {
          _sentenceCompleter!.complete();
        } else {
          _onComplete?.call();
        }
      });
      tts.setCancelHandler(() {
        if (_sentenceCompleter != null && !_sentenceCompleter!.isCompleted) {
          _sentenceCompleter!.complete();
        }
        _onComplete?.call();
      });
      tts.setErrorHandler((_) {
        if (_sentenceCompleter != null && !_sentenceCompleter!.isCompleted) {
          _sentenceCompleter!.complete();
        }
        _onComplete?.call();
      });
      // C3: handler de progreso palabra a palabra (soportado en Android/iOS/web con matices)
      try {
        tts.setProgressHandler((String text, int start, int end, String word) {
          _progressController.add(TtsProgress(text, start, end, word));
          // También mapear a índice de oración
          for (int i = 0; i < _sentenceStarts.length; i++) {
            final s = _sentenceStarts[i];
            final e = i + 1 < _sentenceStarts.length ? _sentenceStarts[i + 1] : _fullText.length;
            if (start >= s && start < e && _currentSentence != i) {
              _currentSentence = i;
              _sentenceController.add(i);
              break;
            }
          }
        });
      } catch (_) {}
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

  /// Pausa por frase: corta el texto en oraciones y reproduce secuencialmente con pausa de 650 ms.
  List<String> _splitSentences(String text) {
    // Separa por . ! ? seguidos de espacio o fin; conserva delimitador
    final pattern = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$');
    final matches = pattern.allMatches(text);
    return matches.map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> speak(String text) => speakWithHighlight(text, pausePerSentence: true);

  /// C3: habla con resaltado y pausa opcional por frase.
  Future<void> speakWithHighlight(String text, {bool pausePerSentence = true, Duration pauseDuration = const Duration(milliseconds: 650)}) async {
    _lastLang = '';
    await _ensureReady();
    _fullText = text;
    _stopRequested = false;
    _isPaused = false;
    _sentences = pausePerSentence ? _splitSentences(text) : [text];
    _sentenceStarts = [];
    int offset = 0;
    for (final s in _sentences) {
      final idx = text.indexOf(s, offset);
      _sentenceStarts.add(idx >= 0 ? idx : offset);
      offset = (idx >= 0 ? idx : offset) + s.length;
    }
    _currentSentence = 0;
    if (_sentenceStarts.isNotEmpty) _sentenceController.add(0);

    try {
      await _tts?.stop();
      for (int i = 0; i < _sentences.length; i++) {
        if (_stopRequested) break;
        // Esperar si está pausado
        while (_isPaused && !_stopRequested) {
          await Future.delayed(const Duration(milliseconds: 120));
        }
        if (_stopRequested) break;
        _currentSentence = i;
        _sentenceController.add(i);
        _sentenceCompleter = Completer<void>();
        await _tts?.speak(_sentences[i]);
        // Esperar a que termine la oración (completionHandler completa el completer)
        await _sentenceCompleter!.future.timeout(const Duration(seconds: 30), onTimeout: () {});
        if (i < _sentences.length - 1 && pausePerSentence && !_stopRequested && !_isPaused) {
          await Future.delayed(pauseDuration);
        }
      }
    } catch (_) {
      _onComplete?.call();
    }
    if (!_stopRequested) _onComplete?.call();
  }

  Future<void> pause() async {
    if (_isPaused) return;
    _isPaused = true;
    try { await _tts?.pause(); } catch (_) { await _tts?.stop(); }
  }

  Future<void> resume() async {
    if (!_isPaused) return;
    _isPaused = false;
    // Si el TTS estaba pausado nativamente, intentar reanudar re-hablando oración actual
    try {
      // flutter_tts en Android no tiene resume fiable; re-hablamos la oración actual
      if (_sentences.isNotEmpty && _currentSentence < _sentences.length) {
        _sentenceCompleter = Completer<void>();
        await _tts?.speak(_sentences[_currentSentence]);
        await _sentenceCompleter!.future.timeout(const Duration(seconds: 30), onTimeout: () {});
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    _stopRequested = true;
    _isPaused = false;
    if (_sentenceCompleter != null && !_sentenceCompleter!.isCompleted) {
      _sentenceCompleter!.complete();
    }
    try {
      await _tts?.stop();
    } catch (_) {
      _onComplete?.call();
    }
  }

  void dispose() {
    _progressController.close();
    _sentenceController.close();
  }
}
