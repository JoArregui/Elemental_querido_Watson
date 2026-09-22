import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/widgets/responsive.dart';
import '../../domain/entities/story_book.dart';
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
      // Al volver, refresca el progreso de la estantería.
      // ignore: use_build_context_synchronously
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
          // Selector idioma ES/EN
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
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 8 : 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '⭐ $total · $rank',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black, fontSize: isPhone ? 11 : 12),
                ),
              );
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

    return Opacity(
      opacity: unlocked ? 1.0 : 0.75,
      child: Card(
        color: const Color(0xFFFFF3CD),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: completed ? Colors.green.shade700 : Colors.amber,
              width: completed ? 2.5 : 1.5),
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
                        return Row(
                          children: [
                            ...List.generate(3, (i) => Icon(
                                  i < stars ? Icons.star : Icons.star_border,
                                  size: 13,
                                  color: i < stars ? Colors.amber.shade700 : Colors.brown.shade300,
                                )),
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
