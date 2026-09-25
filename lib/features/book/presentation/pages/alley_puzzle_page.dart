import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../injection_container.dart' as di;
import '../../../puzzle/domain/entities/puzzle.dart';
import '../../data/datasources/alley_puzzles.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../widgets/puzzle_card.dart';
import '../widgets/solved_celebration.dart';

class AlleyPuzzlePage extends StatefulWidget {
  final int alleyIndex; // 1..8
  final String asset;
  final String alleyName;
  const AlleyPuzzlePage({super.key, required this.alleyIndex, required this.asset, required this.alleyName});

  @override
  State<AlleyPuzzlePage> createState() => _AlleyPuzzlePageState();
}

class _AlleyPuzzlePageState extends State<AlleyPuzzlePage> {
  late Puzzle _puzzle;
  bool _isSolved = false;
  bool? _lastCorrect;
  int _failedAttempts = 0;
  bool _showCelebration = false;
  String? _lastLocale;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = AppLocalizations.of(context).locale.languageCode;
    final isEn = locale == 'en';
    if (!_initialized) {
      _puzzle = AlleyPuzzles.getForAlley(widget.alleyIndex, isEn);
      final repo = di.sl<BookProgressRepository>();
      _isSolved = repo.solvedFor(AlleyPuzzles.bookId).contains(_puzzle.id);
      _lastLocale = locale;
      _initialized = true;
    } else if (_lastLocale != locale) {
      // Locale cambió — recargar puzzle del mismo alley en nuevo idioma
      _puzzle = AlleyPuzzles.getForAlley(widget.alleyIndex, isEn);
      final repo = di.sl<BookProgressRepository>();
      // IDs son iguales en ambos idiomas, pero recarga estado por seguridad
      _isSolved = repo.solvedFor(AlleyPuzzles.bookId).contains(_puzzle.id);
      _lastLocale = locale;
      // No resetea _failedAttempts para no dar intentos extra por cambiar idioma
    }
  }

  Timer? _celebrationTimer;

  @override
  void dispose() {
    _celebrationTimer?.cancel();
    super.dispose();
  }

  Future<void> _onSubmit(String answer, int hintsUsed) async {
    if (_isSolved) return;
    if (_failedAttempts >= 3) return; // bloqueado tras 3 fallos — rama cambiada
    final repo = di.sl<BookProgressRepository>();
    final ok = _puzzle.checkAnswer(answer);
    // Capturar l10n antes de awaits para evitar use_build_context_synchronously
    final l10nBefore = AppLocalizations.of(context);
    await repo.recordAttempt(puzzleId: _puzzle.id, success: ok, hintsUsed: hintsUsed);
    if (!mounted) return;
    if (ok) {
      final maxPenalty = (_puzzle.experiencia - 1).clamp(0, 999);
      final penalty = (hintsUsed * 5).clamp(0, maxPenalty);
      final awarded = (_puzzle.experiencia - penalty).clamp(1, 999);
      final firstTime = await repo.markSolved(
        bookId: AlleyPuzzles.bookId,
        puzzleId: _puzzle.id,
        experiencia: awarded,
        collectibleId: 'map-${widget.alleyIndex}',
      );
      setState(() {
        _isSolved = true;
        _lastCorrect = true;
        _showCelebration = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(
              '${l10nBefore.tr('correctXp', {'xp': '$awarded'})} ${firstTime ? '' : '(repetido)'}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      _celebrationTimer?.cancel();
      _celebrationTimer = Timer(const Duration(milliseconds: 3200), () {
        if (mounted) setState(() => _showCelebration = false);
      });
    } else {
      final next = (_failedAttempts + 1).clamp(0, 3);
      final isThirdFail = next == 3;
      if (isThirdFail) {
        await repo.recordBranch(_puzzle.id, 'alt');
      }
      setState(() {
        _lastCorrect = false;
        _failedAttempts = next;
      });
      if (isThirdFail && mounted) {
        final isEn = AppLocalizations.of(context).locale.languageCode == 'en';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.brown.shade800,
            content: Text(
              isEn ? 'Story branched! This alley reveals an alternative path.' : '¡Rama cambiada! Este callejón revela un camino alternativo.',
              style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEn = l10n.locale.languageCode == 'en';
    final repo = di.sl<BookProgressRepository>();
    final totalSolved = repo.solvedFor(AlleyPuzzles.bookId).length;
    final totalXp = repo.experienciaFor(AlleyPuzzles.bookId);

    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.alleyName, style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              isEn ? 'Alley ${widget.alleyIndex} · Puzzle' : 'Callejón ${widget.alleyIndex} · Puzzle',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Text('⭐ $totalXp · $totalSolved/8', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 12)),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Imagen hero del callejón
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Image.asset(widget.asset, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.brown.shade200, child: const Icon(Icons.image, size: 48, color: Colors.white))),
                          ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: _isSolved ? Colors.green : Colors.amber, borderRadius: BorderRadius.circular(8)),
                                  child: Text(_isSolved ? (isEn ? 'SOLVED' : 'RESUELTO') : (isEn ? 'LOCKED' : 'POR RESOLVER'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(widget.alleyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                          if (_isSolved)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 20),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Progreso global del mapa
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFF1A1009), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade700)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isEn ? 'Map progress' : 'Progreso del mapa', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('$totalSolved/8', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(value: totalSolved / 8, minHeight: 8, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(_isSolved ? Colors.green : Colors.amber)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEn ? 'Solve all 8 to master Nebelheim!' : '¡Resuelve los 8 para dominar Nebelheim!',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // PuzzleCard
                    PuzzleCard(
                      puzzle: _puzzle,
                      isSolved: _isSolved,
                      lastAnswerCorrect: _lastCorrect,
                      failedAttempts: _failedAttempts,
                      onSubmit: _onSubmit,
                    ),
                    const SizedBox(height: 12),
                    if (_isSolved)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                        icon: const Icon(Icons.map),
                        label: Text(isEn ? 'Back to map' : 'Volver al mapa', style: const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.pop(context, true),
                      )
                    else if (_failedAttempts >= 3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.brown.shade800, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber)),
                            child: Row(children: [
                              const Icon(Icons.alt_route, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(child: Text(isEn ? 'Branch changed — no more attempts. Return to map to try another alley.' : 'Rama cambiada — sin más intentos. Vuelve al mapa y prueba otro callejón.', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12))),
                            ]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown.shade700, foregroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 14)),
                            icon: const Icon(Icons.map),
                            label: Text(isEn ? 'Back to map' : 'Volver al mapa', style: const TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber)),
                        icon: const Icon(Icons.lightbulb, size: 18),
                        label: Text(isEn ? 'Need a hint? Fail once to see Watson' : '¿Pista? Falla una vez para ver a Watson'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_puzzle.hintText), duration: const Duration(seconds: 3)));
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_showCelebration)
            SolvedCelebration(
              pageNumber: widget.alleyIndex,
              pageCount: 8,
              experiencia: _puzzle.experiencia,
              onDone: () => setState(() => _showCelebration = false),
            ),
        ],
      ),
    );
  }
}
