import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/widgets/responsive.dart';
import '../../../../core/services/accessibility_service.dart';
import '../../../../core/services/reading_mode_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../data/repositories/daily_puzzle_repository.dart';
import '../../domain/entities/story_book.dart';
import 'map_page.dart';
import 'stats_page.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../widgets/daily_banner.dart';
import 'book_reader_page.dart';

/// Home: biblioteca con un libro por etapa.
/// Cada libro tiene su propia historia y sus propios acertijos.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  IconData _coverIcon(String key) {
    switch (key) {
      case 'clock':
        return Icons.schedule;
      case 'lighthouse':
        return Icons.sailing;
      case 'masks':
        return Icons.celebration;
      case 'observatory':
        return Icons.star;
      case 'train':
        return Icons.train;
      case 'abbey':
        return Icons.account_balance;
      default:
        return Icons.menu_book;
    }
  }

  void _openBook(BuildContext context, LibraryLoaded state, int index,
      {int initialPage = 0}) {
    final l10n = AppLocalizations.of(context);
    final book = state.books[index];
    if (!state.isBookUnlocked(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tr('lockedStage', {'stage': '${book.stage}', 'title': state.books[index - 1].title})),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<BookBloc>()
            ..add(LoadBookEvent(book.id, initialPage: initialPage)),
          child: BookReaderPage(
              bookId: book.id, initialPage: initialPage),
        ),
      ),
    ).then((_) {
      if (!context.mounted) return;
      context.read<LibraryBloc>().add(const RefreshLibraryEvent());
    });
  }

  Future<void> _confirmNewGame(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3CD),
        title: Text(l10n.confirmNewGameTitle),
        content: Text(l10n.confirmNewGameBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.deleteAndStart),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<LibraryBloc>().add(const ResetAllProgressEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.newGameSnick),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showGallery(BuildContext context) {
    final repo = di.sl<BookProgressRepository>();
    final collected = repo.collectibles;
    final isHolmes = repo.isHolmesRank;
    final allSecrets = repo.secrets;
    final allSolved = repo.allSolvedIds;
    // 18 secretos = 101-112 ramificados + 113-118 deducciones
    final secretIds = List.generate(18, (i) => '${101 + i}');
    final secretsSolved = secretIds.where((id) => allSecrets.contains(id) || allSolved.contains(id)).length;
    // 90 coleccionables = 30+10+10+10+15+15
    final allCollectibles = <String>[
      for (int i = 1; i <= 30; i++) 'nebelheim-$i',
      for (int i = 1; i <= 10; i++) 'lighthouse-$i',
      for (int i = 1; i <= 10; i++) 'carnival-$i',
      for (int i = 1; i <= 10; i++) 'observatory-$i',
      for (int i = 1; i <= 15; i++) 'train-$i',
      for (int i = 1; i <= 15; i++) 'abbey-$i',
    ];
    final rewards = repo.rewardsUnlocked; // 6 libros
    final rewardData = [
      {'id':'nebelheim','icon':Icons.schedule, 'color': const Color(0xFF4E342E), 'label':'Nebelheim'},
      {'id':'lighthouse','icon':Icons.sailing, 'color': const Color(0xFF0D47A1), 'label':'Faro'},
      {'id':'carnival','icon':Icons.celebration, 'color': const Color(0xFF6A1B9A), 'label':'Carnaval'},
      {'id':'observatory','icon':Icons.star, 'color': const Color(0xFF1A237E), 'label':'Observatorio'},
      {'id':'train','icon':Icons.train, 'color': const Color(0xFF3E2723), 'label':'Expreso'},
      {'id':'abbey','icon':Icons.account_balance, 'color': const Color(0xFF3E2723), 'label':'Abadía'},
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3CD),
        title: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Collection ${collected.length}/90 · $secretsSolved/18 secrets' : 'Colección ${collected.length}/90 · $secretsSolved/18 secretos', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (isHolmes) Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade700, width: 2.5), boxShadow: [BoxShadow(color: Colors.amber.shade700.withValues(alpha: 0.3), blurRadius: 8)]), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle), child: const Icon(Icons.emoji_events, color: Colors.amber, size: 16)), const SizedBox(width: 8), Expanded(child: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Holmes golden frame unlocked! · 1500+ XP' : '¡Marco dorado Holmes desbloqueado! · 1500+ XP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown)))])),
            // — Recompensas con imagen —
            Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Rewards (images)' : 'Recompensas (imágenes)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
            const SizedBox(height: 6),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.88), itemCount: rewardData.length, itemBuilder: (_, i) {
              final r = rewardData[i];
              final unlocked = rewards.contains(r['id']);
              final holmesFrame = isHolmes && unlocked;
              final asset = 'assets/rewards/${r['id']}.png';
              return Container(
                decoration: BoxDecoration(
                  color: unlocked ? Colors.white : Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: holmesFrame ? Colors.amber.shade700 : (unlocked ? Colors.amber : Colors.brown.shade300), width: holmesFrame ? 3 : 1.5),
                  boxShadow: holmesFrame ? [BoxShadow(color: Colors.amber.withValues(alpha:0.5), blurRadius: 6)] : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset(asset, width: 72, height: 72, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(width:72,height:72,color:(r['color'] as Color),child: Icon(r['icon'] as IconData, color: Colors.amber.shade200))),
                      if (!unlocked) Container(width:72,height:72,color: Colors.black54, child: const Icon(Icons.lock, size: 22, color: Colors.white70)),
                      if (holmesFrame) Positioned(top:2,right:2,child: Container(padding:const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(Icons.emoji_events, size: 10, color: Colors.brown))),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text(r['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: unlocked ? Colors.brown.shade800 : Colors.brown.shade400), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(unlocked ? '✔ ${AppLocalizations.of(context).locale.languageCode=='en'?'Unlocked':'Desbloqueada'}' : '🔒', style: const TextStyle(fontSize: 9)),
                ]),
              );
            }),
            const SizedBox(height: 12),
            // — Secretos 18 —
            Text('${AppLocalizations.of(context).locale.languageCode == 'en' ? 'Secrets' : 'Secretos'} $secretsSolved/18', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
            const SizedBox(height: 6),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.85), itemCount: 18, itemBuilder: (_, i) {
              final id = secretIds[i];
              final solved = allSecrets.contains(id) || allSolved.contains(id);
              final asset = 'assets/rewards/secrets/$id.png';
              return Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: solved ? Colors.amber.shade700 : Colors.brown.shade300, width: solved ? 2 : 1)),
                child: ClipRRect(borderRadius: BorderRadius.circular(7), child: Stack(fit: StackFit.expand, children: [
                  Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.brown.shade100, child: Icon(Icons.lock, size: 16, color: Colors.brown.shade400))),
                  if (!solved) Container(color: Colors.black54, child: const Icon(Icons.lock, size: 16, color: Colors.white70)),
                ])),
              );
            }),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Branch (101-112) + Deduction (113-118)' : 'Ramificados (101-112) + Deducción (113-118)', style: const TextStyle(fontSize: 10, color: Colors.brown)),
            const SizedBox(height: 12),
            // — Álbum de estrellas azules (Acertijo Final, sin XP): 1 hueco por libro —
            Builder(builder: (ctx) {
              final blue = repo.blueStarsCount;
              final isEn = AppLocalizations.of(ctx).locale.languageCode == 'en';
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star,
                            size: 16,
                            color: blue > 0
                                ? Colors.blue.shade700
                                : Colors.blue.shade200),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isEn
                                ? 'Blue stars $blue/6 · Final Riddle, no XP'
                                : 'Estrellas azules $blue/6 · Acertijo Final, sin XP',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.95),
                      itemCount: rewardData.length,
                      itemBuilder: (_, i) {
                        final r = rewardData[i];
                        final earned =
                            repo.hasBlueStar(r['id'] as String);
                        return Container(
                          decoration: BoxDecoration(
                            color: earned
                                ? Colors.white
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: earned
                                    ? Colors.blue.shade700
                                    : Colors.blue.shade200,
                                width: earned ? 2 : 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    earned
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 34,
                                    color: earned
                                        ? Colors.blue.shade700
                                        : Colors.blue.shade200,
                                  ),
                                  if (!earned)
                                    const Icon(Icons.lock,
                                        size: 14,
                                        color: Colors.brown),
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
                                  earned
                                      ? '★'
                                      : (isEn
                                          ? 'Missing'
                                          : 'Pendiente'),
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: earned
                                          ? Colors.blue.shade700
                                          : Colors.brown.shade400)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            // — Coleccionables 90 —
            Text('${AppLocalizations.of(context).locale.languageCode == 'en' ? 'Collectibles' : 'Coleccionables'} ${collected.length}/90', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
            const SizedBox(height: 6),
            GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6, crossAxisSpacing: 6, mainAxisSpacing: 6, childAspectRatio: 0.85), itemCount: allCollectibles.length, itemBuilder: (_, i) {
                final id = allCollectibles[i];
                final hasIt = collected.contains(id);
                final asset = 'assets/rewards/collectibles/$id.png';
                return Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: hasIt ? Colors.amber.shade700 : Colors.brown.shade200, width: hasIt ? 2 : 1)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(7), child: Stack(fit: StackFit.expand, children: [
                    Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: hasIt ? Colors.amber.shade100 : Colors.brown.shade50, child: Icon(hasIt ? Icons.emoji_events : Icons.lock_outline, size: 14, color: hasIt ? Colors.brown : Colors.brown.shade300))),
                    if (!hasIt) Container(color: Colors.black45, child: const Icon(Icons.lock_outline, size: 14, color: Colors.white70)),
                  ])),
                );
              }),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).tr('cancel') == 'Cancelar' ? 'Cerrar' : 'Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPhone = Responsive.isPhone(context);
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appTitle,
                style: TextStyle(color: Colors.amber, fontSize: isPhone ? 16 : 18)),
            Text(l10n.appSubtitle,
                style: TextStyle(color: Colors.white54, fontSize: isPhone ? 10 : 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.amber),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: l10n.locale.languageCode == 'en' ? 'Settings' : 'Ajustes',
            onPressed: () => showDialog(context: context, builder: (_) {
              final a11y = di.sl<AccessibilityService>();
              final sync = di.sl<SyncService>();
              final progress = di.sl<BookProgressRepository>();
              final daily = di.sl<DailyPuzzleRepository>();
              final readingMode = di.sl<ReadingModeService>();
              return StatefulBuilder(builder: (c, setSt) {
                return AlertDialog(
                  backgroundColor: const Color(0xFFFFF3CD),
                  title: Text(l10n.locale.languageCode == 'en' ? 'Settings' : 'Ajustes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Alto contraste — operativo: persiste y cambia scaffold a negro
                    ValueListenableBuilder<bool>(valueListenable: a11y, builder: (_, hc, __) => SwitchListTile(
                      secondary: Icon(Icons.contrast, color: hc ? Colors.amber.shade700 : Colors.brown),
                      title: Text(l10n.locale.languageCode == 'en' ? 'High contrast' : 'Alto contraste', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(hc ? (l10n.locale.languageCode == 'en' ? 'Black background · ON' : 'Fondo negro · ACTIVADO') : (l10n.locale.languageCode == 'en' ? 'Standard theme' : 'Tema estándar'), style: const TextStyle(fontSize: 11)),
                      value: hc,
                      onChanged: (_) async { await a11y.toggleHighContrast(); setSt((){}); if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(a11y.isHighContrast ? (l10n.locale.languageCode=='en'?'High contrast ON':'Contraste alto ACTIVADO') : (l10n.locale.languageCode=='en'?'High contrast OFF':'Contraste alto DESACTIVADO')))); },
                    )),
                    const Divider(),
                    // Fuente grande — operativo: 1.0 -> 1.3 -> 1.6 via MediaQuery textScaler
                    ValueListenableBuilder<bool>(valueListenable: a11y, builder: (_, __, ___) => ListTile(
                      leading: const Icon(Icons.text_fields, color: Colors.brown),
                      title: Text('${l10n.locale.languageCode == 'en' ? 'Large font' : 'Fuente grande'} · ${a11y.fontLabel}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(l10n.locale.languageCode == 'en' ? 'Applies to all pages (MediaQuery)' : 'Se aplica a toda la app (MediaQuery)', style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.swap_horiz, size: 18),
                      onTap: () async { await a11y.cycleFontScale(); setSt((){}); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${a11y.fontLabel} · ${a11y.fontScale}x'))); },
                    )),
                    const Divider(),
                    // Modo de juego: simple (navegación libre) o exigente (hay que acertar para pasar)
                    ValueListenableBuilder<bool>(
                      valueListenable: readingMode,
                      builder: (_, strict, __) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.sports_esports, color: Colors.brown),
                            title: Text(l10n.tr('readingMode'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          RadioListTile<bool>(
                            value: false,
                            groupValue: strict,
                            dense: true,
                            activeColor: Colors.brown.shade800,
                            title: Text(l10n.tr('modeSimple'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Text(l10n.tr('modeSimpleDesc'), style: const TextStyle(fontSize: 11)),
                            onChanged: (_) async { await readingMode.setStrict(false); setSt((){}); },
                          ),
                          RadioListTile<bool>(
                            value: true,
                            groupValue: strict,
                            dense: true,
                            activeColor: Colors.brown.shade800,
                            title: Text(l10n.tr('modeStrict'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Text(l10n.tr('modeStrictDesc'), style: const TextStyle(fontSize: 11)),
                            onChanged: (_) async { await readingMode.setStrict(true); setSt((){}); },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    // Compartir postal — operativo: share_plus con texto real del progreso
                    ListTile(leading: const Icon(Icons.share, color: Colors.brown), title: Text(l10n.locale.languageCode == 'en' ? 'Share case postal' : 'Compartir postal del caso', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: Text(l10n.locale.languageCode == 'en' ? 'Rank + XP + collection via share' : 'Rango + XP + colección vía compartir', style: const TextStyle(fontSize: 11)), onTap: () async { Navigator.pop(c); await sync.sharePostal(progress, daily, l10n.locale.languageCode); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.locale.languageCode=='en'?'Postal shared!':'¡Postal compartida!'))); }),
                    // Exportar .elemental — operativo: JSON + ShareXFiles
                    ListTile(leading: const Icon(Icons.save_alt, color: Colors.brown), title: Text(l10n.locale.languageCode == 'en' ? 'Export .elemental' : 'Exportar .elemental', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: Text(l10n.locale.languageCode == 'en' ? 'JSON with all progress · share file' : 'JSON con todo el progreso · compartir archivo', style: const TextStyle(fontSize: 11)), onTap: () async { Navigator.pop(c); await sync.shareExport(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.locale.languageCode=='en'?'Exported .elemental':'Exportado .elemental'))); }),
                  ])),
                  actions: [TextButton(onPressed: ()=> Navigator.pop(c), child: Text(l10n.tr('cancel') == 'Cancelar' ? 'Cerrar' : 'Close'))],
                );
              });
            }),
          ),
          if (!isPhone) ...[
            IconButton(
              icon: const Icon(Icons.map, color: Colors.amber),
              visualDensity: VisualDensity.compact,
              tooltip: l10n.locale.languageCode == 'en' ? 'Map' : 'Mapa',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapPage(onSelect: (a) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.locale.languageCode=='en'?'Alley':'Callejón'} $a'))); }))),
            ),
            IconButton(
              icon: const Icon(Icons.collections, color: Colors.amber),
              visualDensity: VisualDensity.compact,
              tooltip: AppLocalizations.of(context).locale.languageCode == 'en' ? 'Collection' : 'Colección',
              onPressed: () => _showGallery(context),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.amber),
              visualDensity: VisualDensity.compact,
              tooltip: AppLocalizations.of(context).locale.languageCode == 'en' ? 'Statistics' : 'Estadísticas',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsPage())),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.language, color: Colors.amber),
              tooltip: l10n.selectLanguage,
              color: const Color(0xFFFFF3CD),
              onSelected: (value) async {
                final svc = di.sl<LocaleService>();
                if (value == 'es') await svc.setLocale(const Locale('es'));
                if (value == 'en') await svc.setLocale(const Locale('en'));
                if (context.mounted) context.read<LibraryBloc>().add(const LoadLibraryEvent());
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'es',
                  child: Row(
                    children: [
                      Text(di.sl<LocaleService>().value.languageCode == 'es' ? '●' : '○', style: const TextStyle(color: Colors.brown)),
                      const SizedBox(width: 8),
                      Text(l10n.spanish),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Text(di.sl<LocaleService>().value.languageCode == 'en' ? '●' : '○', style: const TextStyle(color: Colors.brown)),
                      const SizedBox(width: 8),
                      Text(l10n.english),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // En móvil: un único menú overflow para evitar overflowed
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.amber),
              tooltip: l10n.locale.languageCode == 'en' ? 'Menu' : 'Menú',
              color: const Color(0xFFFFF3CD),
              onSelected: (value) async {
                if (value == 'map') Navigator.push(context, MaterialPageRoute(builder: (_) => MapPage(onSelect: (a) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.locale.languageCode=='en'?'Alley':'Callejón'} $a'))); })));
                if (value == 'collection') _showGallery(context);
                if (value == 'stats') Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsPage()));
                if (value == 'es') { await di.sl<LocaleService>().setLocale(const Locale('es')); if (context.mounted) context.read<LibraryBloc>().add(const LoadLibraryEvent()); }
                if (value == 'en') { await di.sl<LocaleService>().setLocale(const Locale('en')); if (context.mounted) context.read<LibraryBloc>().add(const LoadLibraryEvent()); }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'map', child: Row(children: [const Icon(Icons.map, color: Colors.brown, size: 18), const SizedBox(width: 8), Text(l10n.locale.languageCode == 'en' ? 'Map' : 'Mapa')])),
                PopupMenuItem(value: 'collection', child: Row(children: [const Icon(Icons.collections, color: Colors.brown, size: 18), const SizedBox(width: 8), Text(l10n.locale.languageCode == 'en' ? 'Collection' : 'Colección')])),
                PopupMenuItem(value: 'stats', child: Row(children: [const Icon(Icons.bar_chart, color: Colors.brown, size: 18), const SizedBox(width: 8), Text(l10n.locale.languageCode == 'en' ? 'Statistics' : 'Estadísticas')])),
                const PopupMenuDivider(),
                PopupMenuItem(value: 'es', child: Row(children: [Text(di.sl<LocaleService>().value.languageCode == 'es' ? '●' : '○', style: const TextStyle(color: Colors.brown)), const SizedBox(width: 8), Text(l10n.spanish)])),
                PopupMenuItem(value: 'en', child: Row(children: [Text(di.sl<LocaleService>().value.languageCode == 'en' ? '●' : '○', style: const TextStyle(color: Colors.brown)), const SizedBox(width: 8), Text(l10n.english)])),
              ],
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.amber),
            tooltip: l10n.tr('language') == 'Idioma' ? 'Opciones de partida' : 'Game options',
            color: const Color(0xFFFFF3CD),
            onSelected: (value) {
              if (value == 'new_game') _confirmNewGame(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'new_game',
                child: Row(
                  children: [
                    const Icon(Icons.delete_forever, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.newGame),
                  ],
                ),
              ),
            ],
          ),
          BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final total =
                  state is LibraryLoaded ? state.totalexperiencia : 0;
              String rank = l10n.tr('rankApprentice');
              if (total >= 1500) rank = l10n.tr('rankHolmes');
              else if (total >= 800) rank = l10n.tr('rankWatson');
              else if (total >= 300) rank = l10n.tr('rankInvestigator');
              // En móvil: solo ⭐ total para evitar overflowed (rank en tooltip)
              final label = isPhone ? '⭐ $total' : '⭐ $total · $rank';
              final chip = Container(
                margin: const EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 12, vertical: 6),
                constraints: BoxConstraints(maxWidth: isPhone ? 72 : 220),
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: isPhone ? 11 : 12), maxLines: 1),
                ),
              );
              return isPhone
                  ? Tooltip(message: '⭐ $total · $rank', child: chip)
                  : chip;
            },
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryInitial || state is LibraryLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }
          if (state is LibraryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LibraryBloc>()
                        .add(const LoadLibraryEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is! LibraryLoaded) return const SizedBox.shrink();

          return Column(
            children: [
              const DailyBanner(),
              if (state.hasSave && state.resumeBook != null)
                _continueCard(context, state),
              Expanded(
                child: LayoutBuilder(builder: (ctx, cons) {
                  final cross = Responsive.libraryCrossAxisCount(ctx);
                  final pad = Responsive.pagePadding(ctx);
                  if (cross == 1) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, pad.bottom),
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        final unlocked = state.isBookUnlocked(index);
                        final solved = state.solvedFor(book.id);
                        final completed = state.completedBookIds.contains(book.id);
                        return _bookCard(context, state, index, book, unlocked, solved, completed);
                      },
                    );
                  }
                  return ResponsiveCenter(
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, pad.bottom),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isPhone ? 1.6 : 1.45,
                      ),
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        final unlocked = state.isBookUnlocked(index);
                        final solved = state.solvedFor(book.id);
                        final completed = state.completedBookIds.contains(book.id);
                        return _bookCard(context, state, index, book, unlocked, solved, completed);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Retoma la partida guardada donde se dejó.
  Widget _continueCard(BuildContext context, LibraryLoaded state) {
    final l10n = AppLocalizations.of(context);
    final book = state.resumeBook!;
    final page = (state.lastPageIndex + 1).clamp(1, book.pageCount);
    return ResponsiveCenter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.play_circle_fill, size: 28),
          label: Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.continueGame,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(
                  '${book.title} · ${l10n.tr('pageOf', {'current': '$page', 'total': '${book.pageCount}'})}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        onPressed: () {
          final index =
              state.books.indexWhere((b) => b.id == book.id);
          if (index < 0) return;
          _openBook(context, state, index,
              initialPage: state.lastPageIndex);
        },
      ),
      ),
    );
  }

  Widget _bookCard(
    BuildContext context,
    LibraryLoaded state,
    int index,
    StoryBook book,
    bool unlocked,
    int solved,
    bool completed,
  ) {
    final coverColor = Color(book.colorValue);
    final progress =
        book.pageCount == 0 ? 0.0 : solved / book.pageCount;

    final isHolmes = di.sl<BookProgressRepository>().isHolmesRank;
    return Opacity(
      opacity: unlocked ? 1.0 : 0.75,
      child: Card(
        color: const Color(0xFFFFF3CD),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isHolmes ? Colors.amber.shade700 : (completed ? Colors.green.shade700 : Colors.amber),
              width: isHolmes ? 3.5 : (completed ? 2.5 : 1.5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openBook(context, state, index),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Lomo / portada
              Container(
                width: 96,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${AppLocalizations.of(context).tr('stage')} ${book.stage}',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(_coverIcon(book.coverKey),
                        size: 44, color: Colors.amber.shade200),
                    const SizedBox(height: 10),
                    Text(
                      '${book.pageCount} ${AppLocalizations.of(context).tr('pages')}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Ficha del libro
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.description,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black87,
                            height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // B piloto: estrellas 1-3 por XP real
                      Builder(builder: (context) {
                        final xp = state.experienciaPerBook[book.id] ?? 0;
                        final maxXp = book.pageCount * 35;
                        final xpRate = maxXp == 0 ? progress : (xp / maxXp).clamp(0.0, 1.0);
                        int stars = 0;
                        if (progress >= 1.0) stars = 3;
                        else if (xpRate >= 0.7 || progress >= 0.7) stars = 2;
                        else if (progress > 0) stars = 1;
                        final hasBlueStar = di.sl<BookProgressRepository>().hasBlueStar(book.id);
                        return Row(
                          children: [
                            ...List.generate(3, (i) => Icon(
                                  i < stars ? Icons.star : Icons.star_border,
                                  size: 13,
                                  color: i < stars ? Colors.amber.shade700 : Colors.brown.shade300,
                                )),
                            if (hasBlueStar) ...[
                              const SizedBox(width: 4),
                              Tooltip(
                                message: AppLocalizations.of(context).tr('blueStarEarned'),
                                child: Icon(Icons.star, size: 14, color: Colors.blue.shade700),
                              ),
                            ],
                            const SizedBox(width: 4),
                            Flexible(child: Text('$xp XP', style: TextStyle(fontSize: 9, color: Colors.brown.shade600, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          ],
                        );
                      }),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.brown.shade100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  completed
                                      ? Colors.green
                                      : Colors.amber.shade700),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              completed
                                  ? '✔ ${AppLocalizations.of(context).tr('completed')} · $solved/${book.pageCount}'
                                  : '$solved/${book.pageCount} ${AppLocalizations.of(context).tr('solved')}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: completed
                                      ? Colors.green.shade800
                                      : Colors.brown.shade700,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!unlocked)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.lock,
                                  size: 18, color: Colors.grey),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.brown),
                            ),
                        ],
                      ),
                    ],
                  ),
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
