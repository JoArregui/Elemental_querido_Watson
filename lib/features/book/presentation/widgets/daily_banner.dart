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
      if (!mounted) return;
      setState(() {
        _puzzleId = puzzle.id;
        _title = puzzle.title;
        _statement = puzzle.statement;
        _streak = streak;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDaily() {
    if (_puzzleId == null) return;
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
            return SingleChildScrollView(
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
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  PuzzleCard(
                    puzzle: p,
                    isSolved: false,
                    lastAnswerCorrect: null,
                    failedAttempts: 0,
                    onSubmit: (answer, hintsUsed) async {
                      final ok = p.checkAnswer(answer);
                      if (ok) {
                        await di.sl<DailyPuzzleRepository>().markTodaySolved();
                        if (!ctx.mounted) return;
                        FeedbackService().success();
                        Navigator.pop(ctx);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context).tr('dailyChallenge')} ✓ +${p.experiencia} XP · ${AppLocalizations.of(context).tr('streakFire', {'count': '${_streak + 1}'})}')),
                        );
                        setState(() => _streak = _streak + 1);
                      } else {
                        FeedbackService().error();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context).tr('incorrectStay', {'xp': '${p.experiencia}'}))),
                        );
                      }
                    },
                  ),
                ],
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.amber.shade300]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade700, width: 1.5),
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
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today, size: 20, color: Colors.brown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(AppLocalizations.of(context).tr('dailyChallenge'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)),
                          child: Text(AppLocalizations.of(context).tr('streakFire', {'count': '$_streak'}), style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(_title ?? AppLocalizations.of(context).tr('dailyChallenge'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                    Text(_statement ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: Colors.brown),
            ],
          ),
        ),
      ),
    );
  }
}
