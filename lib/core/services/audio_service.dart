import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Banda sonora por libro — 6 ambientes loop (assets/audio/*.wav) con duck al TTS.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentBook;
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(0.30);
      _ready = true;
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService init error: $e');
    }
  }

  static const _map = {
    'nebelheim': 'audio/nebelheim.wav',
    'lighthouse': 'audio/lighthouse.wav',
    'carnival': 'audio/carnival.wav',
    'observatory': 'audio/observatory.wav',
    'train': 'audio/train.wav',
    'abbey': 'audio/abbey.wav',
  };

  Future<void> playForBook(String bookId) async {
    if (_currentBook == bookId) return;
    final asset = _map[bookId];
    if (asset == null) return;
    try {
      await _ensureReady();
      await _player.stop();
      await _player.setVolume(0.30);
      await _player.play(AssetSource(asset), volume: 0.30);
      _currentBook = bookId;
      if (kDebugMode) debugPrint('AudioService: play $bookId -> $asset');
    } catch (e) {
      if (kDebugMode) debugPrint('AudioService play error $bookId: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      if (kDebugMode && _currentBook != null) debugPrint('AudioService: stop $_currentBook');
    } catch (_) {}
    _currentBook = null;
  }

  Future<void> duck(bool enable) async {
    try {
      await _player.setVolume(enable ? 0.08 : 0.30);
      if (kDebugMode) debugPrint('AudioService: duck $enable');
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
