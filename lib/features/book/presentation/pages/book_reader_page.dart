import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../widgets/puzzle_card.dart';

/// Lector de un libro-etapa con efecto de pasar páginas.
class BookReaderPage extends StatefulWidget {
  final String bookId;
  const BookReaderPage({super.key, required this.bookId});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late final PageController _pageController;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index, BookLoaded state) {
    if (index < 0 || index >= state.pages.length) return;
    if (!state.isPageUnlocked(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Resuelve el acertijo de esta página para desbloquear la siguiente.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    context.read<BookBloc>().add(GoToPageEvent(index));
  }

  void _showIndex(BuildContext ctx, BookLoaded state) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFFFFF3CD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Índice del libro',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
                '${state.solvedCount} / ${state.pages.length} acertijos · ${state.totalPicarats} Picarats',
                style: const TextStyle(color: Colors.brown)),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.pages.length,
                itemBuilder: (_, i) {
                  final solved = state.solvedPuzzleIds
                      .contains(state.pages[i].puzzle.id);
                  final unlocked = state.isPageUnlocked(i);
                  final current = i == state.currentIndex;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _goTo(i, state);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !unlocked
                            ? Colors.grey.shade300
                            : solved
                                ? Colors.green.shade200
                                : current
                                    ? Colors.amber
                                    : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: current
                              ? Colors.brown.shade900
                              : Colors.brown,
                          width: current ? 2.5 : 1,
                        ),
                      ),
                      child: !unlocked
                          ? const Icon(Icons.lock,
                              size: 16, color: Colors.grey)
                          : Text('${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        iconTheme: const IconThemeData(color: Colors.amber),
        title: BlocBuilder<BookBloc, BookState>(
          builder: (context, state) {
            final title = state is BookLoaded
                ? state.book.title
                : 'Abriendo el libro…';
            final subtitle = state is BookLoaded
                ? 'Etapa ${state.book.stage} · ${state.pages.length} páginas · 1 acertijo por página'
                : 'Un libro de acertijos';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.amber, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<BookBloc, BookState>(
            builder: (context, state) {
              if (state is BookLoaded) {
                return IconButton(
                  icon: const Icon(Icons.menu_book, color: Colors.amber),
                  tooltip: 'Índice',
                  onPressed: () => _showIndex(context, state),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<BookBloc, BookState>(
        listenWhen: (a, b) =>
            b is BookLoaded &&
            (a is! BookLoaded ||
                (b.currentIndex != (a).currentIndex)),
        listener: (context, state) {
          if (state is BookLoaded && _pageController.hasClients) {
            _syncing = true;
            _pageController.animateToPage(
              state.currentIndex,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
            ).then((_) => _syncing = false);
          }
        },
        builder: (context, state) {
          if (state is BookInitial || state is BookLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }
          if (state is BookError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookBloc>()
                        .add(LoadBookEvent(widget.bookId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is! BookLoaded) return const SizedBox.shrink();

          if (state.isBookCompleted) return _completedView(context, state);

          return Column(
            children: [
              _progressHeader(state),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  onPageChanged: (i) {
                    if (_syncing) return;
                    if (state.isPageUnlocked(i)) {
                      context.read<BookBloc>().add(GoToPageEvent(i));
                    } else {
                      // Rebota a la página actual si intenta colarse.
                      _syncing = true;
                      _pageController
                          .animateToPage(
                        state.currentIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                          .then((_) {
                        _syncing = false;
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Página bloqueada: resuelve el acertijo anterior.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final isCurrent = index == state.currentIndex;
                    // Efecto libro: escala + sombra según distancia.
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (ctx, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index).abs()
                              .clamp(0.0, 1.0);
                        } else if (!isCurrent) {
                          value = 1.0;
                        } else {
                          value = 0.0;
                        }
                        final scale = 1 - (value * 0.06);
                        final opacity =
                            isCurrent || !_pageController.position.haveDimensions
                                ? 1.0
                                : 0.85;
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(scale: scale, child: child),
                        );
                      },
                      child: _bookSheet(
                          context, state, index, isCurrent),
                    );
                  },
                ),
              ),
              _bottomBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _progressHeader(BookLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1A1009),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Página ${state.currentIndex + 1} / ${state.pages.length}',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ ${state.totalPicarats}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.solvedCount} acertijos resueltos',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Hoja del libro: historia arriba, acertijo al final.
  Widget _bookSheet(
      BuildContext context, BookLoaded state, int index, bool isCurrent) {
    final page = state.pages[index];
    final solved =
        state.solvedPuzzleIds.contains(page.puzzle.id);
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(3, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: Colors.brown.shade300, width: 6),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${page.chapterLabel} · ${page.chapterTitle}',
              style: TextStyle(
                  color: Colors.brown.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              page.storyTitle,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'serif',
              ),
            ),
            const Divider(color: Colors.amber, thickness: 1.5),
            Text(
              page.storyText,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.brown.shade800,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '✦  Acertijo de la página ${page.pageNumber}  ✦',
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            PuzzleCard(
              puzzle: page.puzzle,
              isSolved: solved,
              lastAnswerCorrect:
                  isCurrent ? state.lastAnswerCorrect : null,
              failedAttempts:
                  isCurrent ? state.failedAttemptsOnPage : 0,
              onSubmit: (answer) {
                if (isCurrent) {
                  context
                      .read<BookBloc>()
                      .add(SubmitPageAnswerEvent(answer));
                }
              },
            ),
            if (solved && isCurrent && index < state.pages.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Pasar la página →',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () =>
                      context.read<BookBloc>().add(const NextPageEvent()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, BookLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF1A1009),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                side: const BorderSide(color: Colors.amber),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Anterior',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: state.currentIndex == 0
                  ? null
                  : () => context
                      .read<BookBloc>()
                      .add(const PreviousPageEvent()),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${state.currentIndex + 1} / ${state.pages.length}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.canGoNext
                    ? Colors.amber
                    : Colors.grey.shade700,
                foregroundColor:
                    state.canGoNext ? Colors.black : Colors.white54,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: Icon(
                  state.isCurrentSolved
                      ? Icons.auto_stories
                      : Icons.lock,
                  size: 18),
              label: Text(
                  state.isCurrentSolved
                      ? 'Siguiente'
                      : 'Bloqueada',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              onPressed: state.canGoNext
                  ? () => context
                      .read<BookBloc>()
                      .add(const NextPageEvent())
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedView(BuildContext context, BookLoaded state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_stories,
                  size: 64, color: Colors.brown),
              const SizedBox(height: 12),
              const Text(
                '¡Fin del libro!',
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.book.stage == 1
                    ? 'La torre de Nebelheim vuelve a latir. Layton cierra el libro y Luke sonríe: "Toda historia digna termina… con otro misterio".'
                    : '"${state.book.title}" queda resuelto. Layton sonríe: "Toda historia digna termina… con otro misterio".',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.amber.shade800, width: 2),
                ),
                child: Text(
                  '⭐ ${state.totalPicarats} Picarats · ${state.solvedCount}/${state.pages.length}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade800,
                        foregroundColor: Colors.amber),
                    icon: const Icon(Icons.local_library),
                    label: const Text('Volver a la biblioteca',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Releer',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    onPressed: () => context
                        .read<BookBloc>()
                        .add(const GoToPageEvent(0)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Empezar de nuevo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onPressed: () => context
                        .read<BookBloc>()
                        .add(const ResetBookEvent()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
