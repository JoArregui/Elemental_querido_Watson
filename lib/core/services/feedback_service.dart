import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// C1 - Narrativa e inmersión: SFX/hápticos centralizado sin añadir dependencias nativas.
/// Usa HapticFeedback (incluido en Flutter) y placeholder para audio.
/// Cuando se añada `audioplayers`, basta con implementar `_playSound` sin tocar callers.
class FeedbackService {
  static const _tag = 'FeedbackService';

  Future<void> success() async {
    try {
      HapticFeedback.mediumImpact();
      // TODO(C1): audioplayers -> AssetsAudioPlayer.play('assets/sfx/success.mp3')
      if (kDebugMode) debugPrint('$_tag: success haptic+ sfx');
    } catch (_) {}
  }

  Future<void> error() async {
    try {
      HapticFeedback.heavyImpact();
      if (kDebugMode) debugPrint('$_tag: error haptic');
    } catch (_) {}
  }

  Future<void> lightTap() async {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> celebrate() async {
    try {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      HapticFeedback.heavyImpact();
      if (kDebugMode) debugPrint('$_tag: celebrate double haptic');
    } catch (_) {}
  }
}
