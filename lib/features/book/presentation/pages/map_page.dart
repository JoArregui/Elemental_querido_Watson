import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../injection_container.dart' as di;
import '../../data/datasources/alley_puzzles.dart';
import '../../data/repositories/book_progress_repository.dart';
import 'alley_puzzle_page.dart';

class MapPage extends StatefulWidget {
  /// Callback opcional legado — ahora el minijuego es la acción principal.
  /// Si se proporciona, se llama además al resolver (para compatibilidad).
  final void Function(int alley)? onSelect;
  const MapPage({super.key, this.onSelect});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Set<String> _solvedIds;

  @override
  void initState() {
    super.initState();
    _refreshSolved();
  }

  void _refreshSolved() {
    final repo = di.sl<BookProgressRepository>();
    _solvedIds = repo.solvedFor(AlleyPuzzles.bookId);
  }

  bool _isSolved(int alley) {
    final isEn = AppLocalizations.of(context).locale.languageCode == 'en';
    final p = AlleyPuzzles.getForAlley(alley, isEn);
    // Comprobar ambos locales para robustez
    return _solvedIds.contains(p.id) || _solvedIds.contains('alley_$alley');
  }

  Future<void> _openAlley(int alley, String asset, String name) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AlleyPuzzlePage(alleyIndex: alley, asset: asset, alleyName: name),
      ),
    );
    if (!mounted) return;
    setState(() => _refreshSolved());
    if (result == true && widget.onSelect != null) {
      widget.onSelect!(alley);
    }
  }

  List<Map<String, String>> _alleys(bool isEn) => [
        {'name': isEn ? 'Alley of the Cat' : 'Callejón del Gato', 'asset': 'assets/mapa/Callejon_gato.jpg'},
        {'name': isEn ? 'Moon Alley' : 'Callejón de la Luna', 'asset': 'assets/mapa/Callejon_luna.jpg'},
        {'name': isEn ? 'Alley of Oblivion' : 'Callejón del Olvido', 'asset': 'assets/mapa/Callejon_olvido.jpg'},
        {'name': isEn ? 'River Alley' : 'Callejón del Río', 'asset': 'assets/mapa/Callejon_rio.jpg'},
        {'name': isEn ? 'Shadow Alley' : 'Callejón de la Sombra', 'asset': 'assets/mapa/Callejon_sombra.jpg'},
        {'name': isEn ? 'Wind Alley' : 'Callejón del Viento', 'asset': 'assets/mapa/Callejon_viento.jpg'},
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEn = l10n.locale.languageCode == 'en';
    final alleys = _alleys(isEn);
    final repo = di.sl<BookProgressRepository>();
    // Usar cache _solvedIds como fuente única para evitar doble verdad con repo directo
    final solvedCount = _solvedIds.length;
    final totalXp = repo.experienciaFor(AlleyPuzzles.bookId);

    // Villa = alley 7, Torre = alley 8 — mismo fallback que _isSolved
    final villaSolved = _solvedIds.contains(AlleyPuzzles.getForAlley(7, isEn).id) || _solvedIds.contains('alley_7');
    final torreSolved = _solvedIds.contains(AlleyPuzzles.getForAlley(8, isEn).id) || _solvedIds.contains('alley_8');

    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        iconTheme: const IconThemeData(color: Colors.amber),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEn ? 'Nebelheim Map' : 'Mapa de Nebelheim', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(isEn ? 'Minigame · 8 exclusive puzzles' : 'Minijuego · 8 puzzles exclusivos', style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: solvedCount == 8 ? Colors.green : Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Text('⭐ $totalXp · $solvedCount/8', style: TextStyle(fontWeight: FontWeight.bold, color: solvedCount == 8 ? Colors.white : Colors.black, fontSize: 12)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                // Cabecera plano → puzzle 7 EXCLUSIVO
                _VillaHeader(
                  isEn: isEn,
                  solved: villaSolved,
                  onTap: () => _openAlley(7, 'assets/mapa/plano_villa.jpg', isEn ? 'Villa Plan — Overlook' : 'Plano Villa — Mirador'),
                ),
                const SizedBox(height: 12),
                // Plaza → puzzle 8 EXCLUSIVO
                _PlazaCenter(
                  isEn: isEn,
                  solved: torreSolved,
                  onTap: () => _openAlley(8, 'assets/mapa/Plaza_torre.jpg', isEn ? 'Tower Square' : 'Plaza de la Torre'),
                ),
                const SizedBox(height: 12),
                // Barra progreso minijuego
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: const Color(0xFF1A1009), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade700)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isEn ? 'Minigame progress' : 'Progreso minijuego', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('$solvedCount/8 puzzles', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: solvedCount / 8, minHeight: 8, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(solvedCount == 8 ? Colors.green : Colors.amber)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn ? 'Tap any image — each hides an EXCLUSIVE puzzle!' : '¡Toca cualquier imagen — cada una esconde un puzzle EXCLUSIVO!',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Grid 6 callejones — cada uno puzzle exclusivo alley_1..6
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: alleys.length,
                    itemBuilder: (_, i) {
                      final alley = alleys[i];
                      final idx = i + 1;
                      final solved = _isSolved(idx);
                      return _AlleyCard(
                        index: idx,
                        name: alley['name']!,
                        asset: alley['asset']!,
                        isEn: isEn,
                        solved: solved,
                        onTap: () => _openAlley(idx, alley['asset']!, alley['name']!),
                      );
                    },
                  ),
                ),
                if (solvedCount == 8)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade700, width: 2)),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.green, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEn ? 'Master of Nebelheim! All 8 exclusive puzzles solved!' : '¡Maestro de Nebelheim! ¡Los 8 puzzles exclusivos resueltos!',
                              style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    isEn ? '8 exclusive puzzles · Map-only (alley_1..8)' : '8 puzzles exclusivos · solo en el Mapa (alley_1..8)',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera plano_villa → puzzle exclusivo 7
class _VillaHeader extends StatelessWidget {
  final bool isEn;
  final bool solved;
  final VoidCallback onTap;
  const _VillaHeader({required this.isEn, required this.solved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset('assets/mapa/plano_villa.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: const Color(0xFF3E2723), child: const Icon(Icons.map, color: Colors.amber, size: 48))),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)]),
                  ),
                ),
              ),
              // Badge puzzle exclusivo
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: solved ? Colors.green : Colors.amber, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(solved ? Icons.check_circle : Icons.lock_open, size: 12, color: solved ? Colors.white : Colors.black),
                    const SizedBox(width: 4),
                    Text(solved ? (isEn ? 'SOLVED · Puzzle 7' : 'RESUELTO · Puzzle 7') : (isEn ? 'Puzzle 7 — TAP' : 'Puzzle 7 — TOCA'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: solved ? Colors.white : Colors.black)),
                  ]),
                ),
              ),
              if (solved)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 18)),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                      child: Text(isEn ? 'VILLAGE PLAN — 10:10 · Puzzle 7' : 'PLANO DE LA VILLA — 10:10 · Puzzle 7', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                    ),
                    const SizedBox(height: 6),
                    Text(isEn ? 'Tap to play the exclusive Villa puzzle!' : '¡Toca para jugar el puzzle exclusivo de la Villa!', style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // Borde verde si resuelto
              if (solved)
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 3), borderRadius: BorderRadius.circular(14)))),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlazaCenter extends StatelessWidget {
  final bool isEn;
  final bool solved;
  final VoidCallback onTap;
  const _PlazaCenter({required this.isEn, required this.solved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(60),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: solved ? Colors.green : Colors.amber, width: 3), boxShadow: [BoxShadow(color: (solved ? Colors.green : Colors.amber).withValues(alpha: 0.35), blurRadius: 10)]),
                child: ClipOval(child: Image.asset('assets/mapa/Plaza_torre.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: const Color(0xFFFFF3CD), child: const Icon(Icons.location_city, color: Colors.brown)))),
              ),
              if (solved)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 16)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: solved ? Colors.green : Colors.amber, borderRadius: BorderRadius.circular(20)),
            child: Text(isEn ? (solved ? 'TOWER · SOLVED ✓' : 'TOWER · Puzzle 8 — TAP') : (solved ? 'TORRE · RESUELTO ✓' : 'TORRE · Puzzle 8 — TOCA'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: solved ? Colors.white : Colors.black)),
          ),
        ],
      ),
    );
  }
}

class _AlleyCard extends StatelessWidget {
  final int index;
  final String name;
  final String asset;
  final bool isEn;
  final bool solved;
  final VoidCallback onTap;

  const _AlleyCard({required this.index, required this.name, required this.asset, required this.isEn, required this.solved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: solved ? Colors.green : Colors.amber, width: solved ? 2.5 : 1.8),
          boxShadow: solved ? [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 6)] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_,__,___)=> Container(color: Colors.brown.shade100, child: const Icon(Icons.image_not_supported, color: Colors.brown))),
              if (solved) Container(color: Colors.black.withValues(alpha: 0.18)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)])),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: solved ? Colors.green : Colors.amber, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1)),
                  child: solved ? const Icon(Icons.check, size: 16, color: Colors.white) : Text('$index', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: solved ? Colors.green : Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(6)),
                  child: Text(solved ? '✓' : 'EXCL.', style: TextStyle(color: solved ? Colors.white : Colors.amber, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(solved ? (isEn ? 'Solved — tap to replay' : 'Resuelto — toca para rejugar') : (isEn ? 'Tap for exclusive puzzle' : 'Toca para puzzle exclusivo'), style: TextStyle(color: solved ? Colors.green.shade200 : Colors.amber.shade200, fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
