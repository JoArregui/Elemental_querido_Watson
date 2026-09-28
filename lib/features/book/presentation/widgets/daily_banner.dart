import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../injection_container.dart' as di;
import '../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../data/repositories/daily_puzzle_repository.dart';
import 'puzzle_card.dart';
import '../../../../core/services/feedback_service.dart';

/// B piloto: banner de reto diario + racha, sin backend.
class DailyBanner extends StatefulWidget {
  const DailyBanner({super.key});
  @override
  State<DailyBanner> createState() => _DailyBannerState();
}

class _DailyBannerState extends State<DailyBanner> {
  String? _title;
  String? _statement;
  String? _puzzleId;
  int _streak = 0;
  bool _loading = true;
  bool _todaySolved = false;
  int _failedAttempts = 0;
  bool _blocked = false;

  static const int _maxAttempts = DailyPuzzleRepository.maxDailyAttempts;

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _loading = false;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = di.sl<DailyPuzzleRepository>();
      final ds = di.sl<PuzzleLocalDataSource>();
      final id = await repo.getTodayPuzzleId(ds);
      final puzzle = await ds.getPuzzle(id);
      final streak = await repo.getStreak();
      final solved = await repo.isTodaySolved();
      final failed = await repo.getTodayAttempts();
      final blocked = await repo.isTodayBlocked();
      if (!mounted) return;
      setState(() {
        _puzzleId = puzzle.id;
        _title = puzzle.title;
        _statement = puzzle.statement;
        _streak = streak;
        _todaySolved = solved;
        _failedAttempts = failed;
        _blocked = blocked;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isEn =>
      AppLocalizations.of(context).locale.languageCode == 'en';

  String get _blockedMessage => _isEn
      ? 'You have used your 3 attempts. Come back tomorrow to try again — keep training your mind until then!'
      : 'Has agotado tus 3 intentos. Vuelve a intentarlo mañana, hasta entonces sigue entrenando tu mente.';

  void _showBlockedSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF3CD),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Icon(Icons.lock, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    _isEn
                        ? 'No attempts left today'
                        : 'Sin intentos por hoy',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16))),
          ]),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300)),
              child: Column(children: [
                Text(_blockedMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                          AppLocalizations.of(context)
                              .tr('streakFire', {'count': '$_streak'}),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                    ]),
              ])),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade800,
                      foregroundColor: Colors.amber),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(_isEn ? 'See you tomorrow!' : '¡Nos vemos mañana!'))),
        ]),
      ),
    );
  }

  void _openDaily() {
    if (_puzzleId == null) return;
    // Si ya está completado hoy, muestra mensaje bloqueado y no permite reintentar
    if (_todaySolved) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFFFFF3CD),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Daily challenge completed!' : '¡Reto diario completado!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))]),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade300)), child: Column(children: [
              Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'You have already solved today\'s challenge. Come back tomorrow for a new riddle and keep your streak alive!' : 'Ya has completado el reto de hoy. ¡Vuelve mañana con un nuevo acertijo y sigue entrenando tu mente para mantener la racha!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.local_fire_department, color: Colors.orange, size: 18), const SizedBox(width: 6), Text(AppLocalizations.of(context).tr('streakFire', {'count': '$_streak'}), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))]),
            ])),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade800, foregroundColor: Colors.amber), onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'See you tomorrow!' : '¡Nos vemos mañana!'))),
          ]),
        ),
      );
      return;
    }
    // Si ya agotó los 3 intentos, mensaje de bloqueo pedido por el usuario.
    if (_blocked) {
      _showBlockedSheet();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF3CD),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => FutureBuilder(
          future: di.sl<PuzzleLocalDataSource>().getPuzzle(_puzzleId!),
          builder: (c, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.brown));
            final p = snap.data!;
            // Local al sheet para repintar intentos restantes y acierto/fallo.
            var sheetFailed = _failedAttempts;
            bool? sheetLastCorrect;
            return StatefulBuilder(
              builder: (c2, setSheet) => SingleChildScrollView(
              controller: ctrl,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(AppLocalizations.of(context).tr('streakFire', {'count': '$_streak'}), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _isEn
                              ? 'Attempt ${sheetFailed + 1}/$_maxAttempts'
                              : 'Intento ${sheetFailed + 1}/$_maxAttempts',
                          style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PuzzleCard(
                    puzzle: p,
                    isSolved: false,
                    lastAnswerCorrect: sheetLastCorrect,
                    failedAttempts: sheetFailed,
                    onSubmit: (answer, hintsUsed) async {
                      final ok = p.checkAnswer(answer);
                      if (ok) {
                        await di.sl<DailyPuzzleRepository>().markTodaySolved();
                        if (!ctx.mounted) return;
                        FeedbackService().success();
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green.shade700,
                            content: Text(
                              _isEn
                                  ? 'You got it right! ${AppLocalizations.of(context).tr('dailyChallenge')} ✓ +${p.experiencia} XP'
                                  : '¡Has acertado! ${AppLocalizations.of(context).tr('dailyChallenge')} ✓ +${p.experiencia} XP · ${AppLocalizations.of(context).tr('streakFire', {'count': '${_streak + 1}'})}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        );
                        setState(() { _streak = _streak + 1; _todaySolved = true; });
                      } else {
                        FeedbackService().error();
                        final repo = di.sl<DailyPuzzleRepository>();
                        final remaining = await repo.recordFailedAttempt();
                        final used = _maxAttempts - remaining;
                        if (!ctx.mounted) return;
                        if (remaining <= 0) {
                          Navigator.pop(ctx);
                          if (!mounted) return;
                          setState(() { _failedAttempts = used; _blocked = true; });
                          _showBlockedSheet();
                        } else {
                          setSheet(() { sheetFailed = used; sheetLastCorrect = false; });
                          setState(() { _failedAttempts = used; });
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(
                                _isEn
                                    ? 'Wrong — you did not get it. $remaining ${remaining == 1 ? 'attempt' : 'attempts'} left.'
                                    : 'No has acertado. Te quedan $remaining ${remaining == 1 ? 'intento' : 'intentos'}.',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), const SizedBox(width: 10), Text(AppLocalizations.of(context).tr('loadingDaily'))]),
      );
    }
    final bannerSolved = _todaySolved;
    final bannerBlocked = _blocked && !_todaySolved;
    final bannerLocked = bannerSolved || bannerBlocked;
    final isEn = AppLocalizations.of(context).locale.languageCode == 'en';
    return Opacity(
      opacity: bannerLocked ? 0.85 : 1.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: bannerSolved ? [Colors.green.shade300, Colors.green.shade100] : bannerBlocked ? [Colors.red.shade300, Colors.orange.shade100] : [Colors.orange.shade400, Colors.amber.shade300]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bannerSolved ? Colors.green.shade700 : bannerBlocked ? Colors.red.shade700 : Colors.brown.shade700, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openDaily,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: bannerSolved ? Colors.green : bannerBlocked ? Colors.red : Colors.transparent)),
                  child: Icon(bannerSolved ? Icons.check_circle : bannerBlocked ? Icons.lock : Icons.calendar_today, size: 20, color: bannerSolved ? Colors.green : bannerBlocked ? Colors.red : Colors.brown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(bannerSolved ? (isEn ? 'Completed today' : 'Completado hoy') : bannerBlocked ? (isEn ? 'No attempts left' : 'Sin intentos hoy') : AppLocalizations.of(context).tr('dailyChallenge'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                            child: Text(AppLocalizations.of(context).tr('streakFire', {'count': '$_streak'}), style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          if (bannerSolved) ...[const SizedBox(width: 6), const Icon(Icons.verified, size: 14, color: Colors.green)],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(bannerSolved ? (isEn ? 'Come back tomorrow for a new riddle!' : '¡Vuelve mañana con un nuevo reto!') : bannerBlocked ? (isEn ? 'Come back tomorrow — keep training!' : 'Vuelve mañana, sigue entrenando tu mente') : (_title ?? AppLocalizations.of(context).tr('dailyChallenge')), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                      Text(bannerSolved ? (isEn ? 'Streak protected · 1/day' : 'Racha protegida · 1/día') : bannerBlocked ? (isEn ? '3/3 attempts used' : '3/3 intentos usados') : (_statement ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                ),
                Icon(bannerLocked ? Icons.lock : Icons.play_circle_fill, color: bannerSolved ? Colors.green.shade800 : bannerBlocked ? Colors.red.shade800 : Colors.brown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
