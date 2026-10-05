import 'package:flutter/material.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/l10n/app_localizations.dart';
import '../../data/repositories/book_progress_repository.dart';

/// Página de Colección a pantalla completa.
///
/// Sustituye al antiguo AlertDialog con 114 Image.asset creados de golpe
/// (6 recompensas + 18 secretos + 90 coleccionables + estrellas azules).
/// Ese diálogo decodificaba ~100MB de JPG a resolución completa en el
/// hilo de UI: en móviles modernos con densidad xxhdpi/xxxhdpi se
/// congelaba y parecía que "no se abría", mientras que en un modelo
/// antiguo de baja resolución sí llegaba a abrir.
///
/// Esta página:
/// - Separa el contenido en pestañas (solo se construye lo visible).
/// - Usa GridView perezoso (no shrinkWrap dentro de ScrollView).
/// - Usa thumbnails con cacheWidth para no decodificar el JPG completo.
class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  static const Map<String, String> _secretAssetNames = {
    '101': 'Vagon_bifurcado.jpg',
    '102': 'Susurro.jpg',
    '103': 'Ruta_alternativa.jpg',
    '104': 'Observatorio_nublado.jpg',
    '105': 'Observatorio.jpg',
    '106': 'Nota_alternativa.jpg',
    '107': 'Nebelheim.jpg',
    '108': 'Mascara_distinta.jpg',
    '109': 'Final_ramificado.jpg',
    '110': 'Faro_alternativo.jpg',
    '111': 'Faro.jpg',
    '112': 'Expreso.jpg',
    '113': 'Cripta_alternativa.jpg',
    '114': 'Coleccionable_perdido.jpg',
    '115': 'Carnaval.jpg',
    '116': 'Brujula_rota.jpg',
    '117': 'Atajo_de_Watson.jpg',
    '118': 'Abadia.jpg',
  };

  static final List<Map<String, Object>> _rewardData = [
    {'id': 'nebelheim', 'icon': Icons.schedule, 'label': 'Nebelheim'},
    {'id': 'lighthouse', 'icon': Icons.sailing, 'label': 'Faro'},
    {'id': 'carnival', 'icon': Icons.celebration, 'label': 'Carnaval'},
    {'id': 'observatory', 'icon': Icons.star, 'label': 'Observatorio'},
    {'id': 'train', 'icon': Icons.train, 'label': 'Expreso'},
    {'id': 'abbey', 'icon': Icons.account_balance, 'label': 'Abadía'},
  ];

  static final List<Color> _rewardColors = [
    Color(0xFF4E342E),
    Color(0xFF0D47A1),
    Color(0xFF6A1B9A),
    Color(0xFF1A237E),
    Color(0xFF3E2723),
    Color(0xFF3E2723),
  ];

  String _collectibleAsset(String id) {
    // nebelheim-1..6 son jpg, el resto png (coincide con assets/).
    final isJpg =
        id.startsWith('nebelheim-') && _jpgCollectibles.contains(id);
    return 'assets/rewards/collectibles/$id.${isJpg ? 'jpg' : 'png'}';
  }

  static final Set<String> _jpgCollectibles = {
    for (int i = 1; i <= 6; i++) 'nebelheim-$i',
  };

  static List<String> _allCollectibles() { return <String>[
        for (int i = 1; i <= 30; i++) 'nebelheim-$i',
        for (int i = 1; i <= 10; i++) 'lighthouse-$i',
        for (int i = 1; i <= 10; i++) 'carnival-$i',
        for (int i = 1; i <= 10; i++) 'observatory-$i',
        for (int i = 1; i <= 15; i++) 'train-$i',
        for (int i = 1; i <= 15; i++) 'abbey-$i',
      ]; }

  void _showImagePreview(
      BuildContext context, String asset, String title, Widget fallback) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => fallback,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close,
                    color: Colors.white, size: 28),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// Thumbnail ligero: decodifica a ~200px en vez del JPG completo (~1MB).
  Widget _thumb({
    required String asset,
    required bool unlocked,
    required Widget fallback,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: unlocked ? onTap : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox.expand(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                // Clave del arreglo: no decodificar a resolución completa.
                cacheWidth: 200,
                errorBuilder: (_, _, _) => fallback,
              ),
            ),
            if (!unlocked)
              Container(
                color: Colors.black54,
                child: const Icon(Icons.lock,
                    size: 18, color: Colors.white70),
              ),
            if (unlocked)
              const Positioned(
                right: 3,
                bottom: 3,
                child: Icon(Icons.zoom_in,
                    size: 15, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = di.sl<BookProgressRepository>();
    final collected = repo.collectibles;
    final allSecrets = repo.secrets;
    final allSolved = repo.allSolvedIds;
    final secretIds = List.generate(18, (i) => '${101 + i}');
    final secretsSolved = secretIds
        .where((id) => allSecrets.contains(id) || allSolved.contains(id))
        .length;
    final rewards = repo.rewardsUnlocked;
    final isHolmes = repo.isHolmesRank;
    final isEn =
        AppLocalizations.of(context).locale.languageCode == 'en';
    final allCollectibles = _allCollectibles();

    final title = isEn
        ? 'Collection ${collected.length}/90 · $secretsSolved/18 secrets'
        : 'Colección ${collected.length}/90 · $secretsSolved/18 secretos';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF2C1A0E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1009),
          iconTheme: const IconThemeData(color: Colors.amber),
          title: Text(title,
              style: const TextStyle(color: Colors.amber, fontSize: 14)),
          bottom: TabBar(
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            isScrollable: true,
            tabs: [
              Tab(text: isEn ? 'Rewards' : 'Recompensas'),
              Tab(text: isEn ? 'Secrets $secretsSolved/18' : 'Secretos $secretsSolved/18'),
              Tab(text: isEn ? 'Collectibles ${collected.length}/90' : 'Colecc. ${collected.length}/90'),
              const Tab(text: '★'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // — Recompensas —
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.55,
              ),
              itemCount: _rewardData.length,
              itemBuilder: (_, i) {
                final r = _rewardData[i];
                final unlocked = rewards.contains(r['id']);
                final holmesFrame = isHolmes && unlocked;
                final asset = 'assets/rewards/${r['id']}.jpg';
                final color = _rewardColors[i];
                return Container(
                  decoration: BoxDecoration(
                    color: unlocked ? Colors.white : Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: holmesFrame
                          ? Colors.amber.shade700
                          : (unlocked
                              ? Colors.amber
                              : Colors.brown.shade300),
                      width: holmesFrame ? 3 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _thumb(
                            asset: asset,
                            unlocked: unlocked,
                            fallback: Container(
                                color: color,
                                child: Icon(r['icon'] as IconData,
                                    color: Colors.amber.shade200)),
                            onTap: () => _showImagePreview(
                              context,
                              asset,
                              r['label'] as String,
                              Container(
                                  color: color,
                                  child: Icon(r['icon'] as IconData,
                                      color: Colors.amber.shade200,
                                      size: 80)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(r['label'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: unlocked
                                  ? Colors.brown.shade800
                                  : Colors.brown.shade400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center),
                      Text(
                          unlocked
                              ? (isEn ? '✔ Unlocked' : '✔ Desbloqueada')
                              : '🔒',
                          style: const TextStyle(fontSize: 9)),
                    ],
                  ),
                );
              },
            ),
            // — Secretos —
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.85,
              ),
              itemCount: 18,
              itemBuilder: (_, i) {
                final id = secretIds[i];
                final solved = allSecrets.contains(id) ||
                    allSolved.contains(id);
                final asset =
                    'assets/rewards/secrets/${_secretAssetNames[id] ?? '$id.png'}';
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: solved
                          ? Colors.amber.shade700
                          : Colors.brown.shade300,
                      width: solved ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: _thumb(
                      asset: asset,
                      unlocked: solved,
                      fallback: Container(
                          color: Colors.brown.shade100,
                          child: Icon(Icons.auto_awesome,
                              size: 18,
                              color: Colors.amber.shade700)),
                      onTap: () => _showImagePreview(
                        context,
                        asset,
                        '${isEn ? 'Secret' : 'Secreto'} $id',
                        Container(
                            color: Colors.brown.shade100,
                            child: Icon(Icons.auto_awesome,
                                size: 80,
                                color: Colors.amber.shade700)),
                      ),
                    ),
                  ),
                );
              },
            ),
            // — Coleccionables —
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.85,
              ),
              itemCount: allCollectibles.length,
              itemBuilder: (_, i) {
                final id = allCollectibles[i];
                final hasIt = collected.contains(id);
                final asset = _collectibleAsset(id);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasIt
                          ? Colors.amber.shade700
                          : Colors.brown.shade200,
                      width: hasIt ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: _thumb(
                      asset: asset,
                      unlocked: hasIt,
                      fallback: Container(
                          color: Colors.amber.shade100,
                          child: Icon(Icons.emoji_events,
                              size: 18,
                              color: Colors.brown.shade700)),
                      onTap: () => _showImagePreview(
                        context,
                        asset,
                        id,
                        Container(
                            color: Colors.amber.shade100,
                            child: Icon(Icons.emoji_events,
                                size: 80,
                                color: Colors.brown.shade700)),
                      ),
                    ),
                  ),
                );
              },
            ),
            // — Estrellas azules —
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: _rewardData.length,
              itemBuilder: (_, i) {
                final r = _rewardData[i];
                final earned = repo.hasBlueStar(r['id'] as String);
                return Container(
                  decoration: BoxDecoration(
                    color: earned ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: earned
                          ? Colors.blue.shade700
                          : Colors.blue.shade200,
                      width: earned ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            earned ? Icons.star : Icons.star_border,
                            size: 34,
                            color: earned
                                ? Colors.blue.shade700
                                : Colors.blue.shade200,
                          ),
                          if (!earned)
                            const Icon(Icons.lock,
                                size: 14, color: Colors.brown),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r['label'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: earned
                                  ? Colors.blue.shade900
                                  : Colors.brown.shade400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(
                        earned ? '★' : (isEn ? 'Missing' : 'Pendiente'),
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: earned
                                ? Colors.blue.shade700
                                : Colors.brown.shade400),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
