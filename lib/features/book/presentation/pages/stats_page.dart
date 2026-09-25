import 'package:flutter/material.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/l10n/app_localizations.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/datasources/book_local_data_source.dart';

/// D1: Estadísticas + telemetría UX
/// Pantalla perfil: tiempo medio por puzzle, tasa acierto, libro más jugado, etc.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  String _fmtDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEn = l10n.locale.languageCode == 'en';
    final repo = di.sl<BookProgressRepository>();
    final totalXp = repo.totalexperiencia();
    final solved = repo.totalSolvedPuzzles;
    final totalAttempts = repo.totalAttempts;
    final successRate = repo.successRate;
    final avgTime = repo.avgTimePerPuzzle;
    final totalTime = repo.totalTimeSeconds;
    final avgHints = repo.avgHintsPerPuzzle;
    final mostPlayed = repo.mostPlayedBookId;
    final sessions = repo.totalSessions;
    final branchCount = repo.branchChoices.length;
    final collectibles = repo.collectiblesCount;
    final secrets = repo.secretsCount;

    String rank = isEn ? 'Apprentice' : 'Aprendiz';
    if (totalXp >= 1500) rank = isEn ? 'Holmes' : 'Holmes';
    else if (totalXp >= 800) rank = isEn ? 'Watson' : 'Watson';
    else if (totalXp >= 300) rank = isEn ? 'Investigator' : 'Investigador';

    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Text(isEn ? 'Statistics' : 'Estadísticas', style: const TextStyle(color: Colors.amber)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.amber),
            tooltip: isEn ? 'Share stats' : 'Compartir estadísticas',
            onPressed: () async {
              final text = isEn
                  ? 'Elemental — Stats\nRank $rank · $totalXp XP\nSolved $solved · Rate ${(successRate * 100).toStringAsFixed(1)}%\nAvg time ${_fmtDuration(avgTime.round())} · Total ${_fmtDuration(totalTime)}\nMost played: $mostPlayed'
                  : 'Elemental — Estadísticas\nRango $rank · $totalXp XP\nResueltos $solved · Tasa ${(successRate * 100).toStringAsFixed(1)}%\nTiempo medio ${_fmtDuration(avgTime.round())} · Total ${_fmtDuration(totalTime)}\nMás jugado: $mostPlayed';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // — Resumen global —
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade700, width: 2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.analytics, color: Colors.brown),
                const SizedBox(width: 8),
                Text(isEn ? 'Global summary' : 'Resumen global', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Text('⭐ $totalXp · $rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ]),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.6,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _statTile(Icons.emoji_events, isEn ? 'Solved' : 'Resueltos', '$solved / 108', Colors.green),
                  _statTile(Icons.percent, isEn ? 'Success rate' : 'Tasa acierto', totalAttempts == 0 ? '—' : '${(successRate * 100).toStringAsFixed(1)}%', Colors.blue),
                  _statTile(Icons.timer, isEn ? 'Avg time / puzzle' : 'Tiempo medio', avgTime == 0 ? '—' : _fmtDuration(avgTime.round()), Colors.orange),
                  _statTile(Icons.hourglass_bottom, isEn ? 'Total time' : 'Tiempo total', _fmtDuration(totalTime), Colors.brown),
                  _statTile(Icons.lightbulb, isEn ? 'Avg hints' : 'Pistas medias', avgHints.toStringAsFixed(1), Colors.amber.shade700),
                  _statTile(Icons.repeat, isEn ? 'Sessions' : 'Sesiones', '$sessions', Colors.purple),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 16),
          // — Libro más jugado —
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.brown.shade300)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.shade100, shape: BoxShape.circle), child: const Icon(Icons.menu_book, color: Colors.brown)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isEn ? 'Most played book' : 'Libro más jugado', style: const TextStyle(fontSize: 12, color: Colors.brown)),
                Text(mostPlayed, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(isEn ? '$branchCount branched stories triggered' : '$branchCount historias ramificadas activadas', style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ])),
              const Icon(Icons.star, color: Colors.amber),
            ]),
          ),
          const SizedBox(height: 16),
          // — Por libro —
          Text(isEn ? 'Per-book breakdown' : 'Desglose por libro', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          FutureBuilder(
            future: di.sl<BookLocalDataSource>().getLibrary(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.amber));
              final books = snap.data!;
              return Column(children: books.map((b) {
                final solvedPerBook = repo.solvedCount(b.id);
                final xpPerBook = repo.experienciaFor(b.id);
                final attempts = b.pages.fold<int>(0, (sum, p) => sum + (repo.attemptsPerPuzzle[p.puzzle.id] ?? 0));
                final successes = b.pages.fold<int>(0, (sum, p) => sum + (repo.successPerPuzzle[p.puzzle.id] ?? 0));
                final rate = attempts == 0 ? 0.0 : successes / attempts;
                final avgT = b.pages.map((p) => repo.timePerPuzzle[p.puzzle.id] ?? 0).where((v) => v > 0).toList();
                final avgTimeBook = avgT.isEmpty ? 0 : avgT.reduce((a, b) => a + b) / avgT.length;
                final isMost = b.id == mostPlayed;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(10), border: Border.all(color: isMost ? Colors.amber.shade700 : Colors.brown.shade200, width: isMost ? 2 : 1)),
                  child: Row(children: [
                    Container(width: 44, height: 44, decoration: BoxDecoration(color: Color(b.colorValue), borderRadius: BorderRadius.circular(8)), child: Icon(b.stage == 1 ? Icons.schedule : b.stage == 2 ? Icons.sailing : b.stage == 3 ? Icons.celebration : b.stage == 4 ? Icons.star : b.stage == 5 ? Icons.train : Icons.account_balance, color: Colors.amber.shade200, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('$solvedPerBook/${b.pageCount} · $xpPerBook XP · ${rate == 0 && attempts == 0 ? '—' : '${(rate * 100).toStringAsFixed(0)}%'} ${isEn ? 'rate' : 'acierto'}', style: const TextStyle(fontSize: 11, color: Colors.brown)),
                      const SizedBox(height: 4),
                      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: b.pageCount == 0 ? 0 : solvedPerBook / b.pageCount, minHeight: 6, backgroundColor: Colors.brown.shade100, valueColor: AlwaysStoppedAnimation<Color>(solvedPerBook == b.pageCount ? Colors.green : Colors.amber.shade700))),
                    ])),
                    const SizedBox(width: 8),
                    Column(children: [
                      Text(avgTimeBook == 0 ? '—' : _fmtDuration(avgTimeBook.round()), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(isEn ? 'avg' : 'media', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      if (isMost) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Text(isEn ? 'TOP' : 'TOP', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                    ]),
                  ]),
                );
              }).toList());
            },
          ),
          const SizedBox(height: 16),
          // — Colección y secretos —
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _miniStat('$collectibles/90', isEn ? 'Collectibles' : 'Coleccionables', Icons.collections),
              Container(width: 1, height: 40, color: Colors.brown.shade200),
              _miniStat('$secrets/18', isEn ? 'Secrets' : 'Secretos', Icons.lock_open),
              Container(width: 1, height: 40, color: Colors.brown.shade200),
              _miniStat('${repo.rewardsUnlocked.length}/6', isEn ? 'Rewards' : 'Recompensas', Icons.emoji_events),
            ]),
          ),
          const SizedBox(height: 16),
          // — Telemetría detallada —
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.brown.shade800, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.insights, color: Colors.amber, size: 18), const SizedBox(width: 8), Text(isEn ? 'Telemetry (D1)' : 'Telemetría (D1)', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 10),
              _telemetryRow(isEn ? 'Total attempts' : 'Intentos totales', '$totalAttempts'),
              _telemetryRow(isEn ? 'Successes' : 'Aciertos', '${repo.totalSuccesses}'),
              _telemetryRow(isEn ? 'Branched triggers (2 fails)' : 'Ramificaciones (2 fallos)', '$branchCount'),
              _telemetryRow(isEn ? 'Avg hints / puzzle' : 'Pistas medias', avgHints.toStringAsFixed(2)),
              _telemetryRow(isEn ? 'Puzzles with time' : 'Puzzles con tiempo', '${repo.timePerPuzzle.values.where((v) => v > 0).length}'),
              const SizedBox(height: 8),
              Text(isEn ? 'Data is stored locally (SharedPreferences) and powers the charts above. No network upload.' : 'Datos guardados localmente (SharedPreferences) y usados en los gráficos superiores. Sin envío a red.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontStyle: FontStyle.italic)),
            ]),
          ),
          const SizedBox(height: 24),
          // — Acciones —
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
            icon: const Icon(Icons.refresh),
            label: Text(isEn ? 'Close' : 'Cerrar', style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.brown.shade200)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, size: 16, color: color)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ])),
      ]),
    );
  }

  Widget _miniStat(String value, String label, IconData icon) {
    return Column(children: [
      Icon(icon, color: Colors.brown, size: 20),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ]);
  }

  Widget _telemetryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }
}
