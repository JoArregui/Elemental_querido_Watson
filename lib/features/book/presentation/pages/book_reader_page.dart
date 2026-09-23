import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../injection_container.dart' as di;
import '../../data/services/tts_service.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/book_state.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/responsive.dart';
import '../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../widgets/puzzle_card.dart';
import '../widgets/solved_celebration.dart';

/// Lector de un libro-etapa con efecto de pasar páginas.
class BookReaderPage extends StatefulWidget {
  final String bookId;
  final int initialPage;
  const BookReaderPage(
      {super.key, required this.bookId, this.initialPage = 0});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  late final PageController _pageController;
  bool _syncing = false;
  bool _isReading = false;
  bool _mirror = false;
  bool _isTimed = false;
  int _secondsLeft = 0;
  double _textScale = 1.0;
  TtsService? _tts;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    // Banda sonora por libro (placeholder)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AudioService>().playForBook(widget.bookId);
    });
  }

  @override
  void dispose() {
    _isReading = false;
    unawaited(_tts?.stop());
    unawaited(di.sl<AudioService>().stop());
    _pageController.dispose();
    super.dispose();
  }

  TtsService _ttsService() {
    final svc = _tts ??= di.sl<TtsService>();
    svc.onComplete = () {
      if (mounted) setState(() => _isReading = false);
      unawaited(di.sl<AudioService>().duck(false));
    };
    return svc;
  }

  /// Lee en voz alta la página actual (historia + acertijo).
  Future<void> _toggleReading(BookLoaded state) async {
    if (_isReading) {
      await _stopReading();
      return;
    }
    final page = state.currentPage;
    final text = '${page.storyTitle}. ${page.storyText} '
        'Acertijo de la página ${page.pageNumber}: '
        '${page.puzzle.title}. ${page.puzzle.statement}';
    setState(() => _isReading = true);
    unawaited(di.sl<AudioService>().duck(true));
    await _ttsService().speak(text);
  }

  Future<void> _stopReading() async {
    if (!_isReading && _tts == null) return;
    setState(() => _isReading = false);
    unawaited(di.sl<AudioService>().duck(false));
    await _ttsService().stop();
  }

  void _cycleTextScale() {
    setState(() {
      _textScale = _textScale >= 1.6
          ? 1.0
          : _textScale >= 1.3
              ? 1.6
              : 1.3;
    });
  }

  void _goTo(int index, BookLoaded state) {
    if (index < 0 || index >= state.pages.length) return;
    // Navegación libre: cualquier página es accesible.
    context.read<BookBloc>().add(GoToPageEvent(index));
  }

  void _goToFirst(BookLoaded state) {
    if (state.isFirstPage) return;
    context.read<BookBloc>().add(const GoToPageEvent(0));
  }

  void _confirmSkip(BuildContext context, BookLoaded state) {
    final experiencia = state.currentPage.puzzle.experiencia;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3CD),
        title: Text(l10n.tr('skipConfirmTitle')),
        content: Text(l10n.tr('skipConfirmBody', {'xp': '$experiencia'})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(l10n.tr('keepTrying')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade800,
              foregroundColor: Colors.amber,
            ),
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<BookBloc>().add(const NextPageEvent());
            },
            child: Text(l10n.tr('skipAnyway')),
          ),
        ],
      ),
    );
  }

  void _showFinalSummary(BuildContext context, BookLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF3CD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: _summaryContent(context, state),
        ),
      ),
    );
  }

  Widget _summaryContent(BuildContext context, BookLoaded state) {
    final missed = state.missedexperiencia;
    final max = state.maxPossibleexperiencia;
    final isPerfect = state.isFullyCompleted;
    // C2: 3 finales por % XP
    final tier = state.endingTier;
    final String endingTitle;
    final String endingQuote;
    if (tier == 'perfect') {
      endingTitle = '¡Fin del libro perfecto!';
      endingQuote = state.book.stage == 1
          ? 'La torre de Nebelheim vuelve a latir. Holmes cierra su violín y yo sonrío: "Todo caso digno termina… con otro misterio".'
          : '"${state.book.title}" queda resuelto. Holmes enciende su pipa: "Es elemental, querido Watson".';
    } else if (tier == 'good') {
      endingTitle = '¡Caso resuelto!';
      endingQuote = 'Holmes asiente: "Buen trabajo, Watson. Quedaron cabos sueltos, pero el misterio principal está resuelto".';
    } else if (tier == 'half') {
      endingTitle = '¡Libro terminado!';
      endingQuote = 'Watson anota: "Avanzamos, pero varios enigmas nos vencieron. Volveremos con más pistas".';
    } else {
      endingTitle = '¡Historia completada!';
      endingQuote = 'Holmes guarda la lupa: "Leímos la historia, mas los acertijos nos superaron. Reinténtalos para el final verdadero".';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Imagen de recompensa (assets/rewards/<bookId>.png) si 100% o completado
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/rewards/${state.book.id}.png', width: 140, height: 140, fit: BoxFit.cover, errorBuilder: (_,__,___) => Icon(tier == 'perfect' ? Icons.auto_stories : tier == 'good' ? Icons.menu_book : Icons.book_outlined, size: 56, color: tier == 'perfect' ? Colors.green.shade700 : Colors.brown)),
        ),
        const SizedBox(height: 8),
        Text(
          endingTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          endingQuote,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        if (tier == 'perfect') Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.shade700)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events, size: 16, color: Colors.brown), const SizedBox(width: 6), Text(AppLocalizations.of(context).locale.languageCode=='en' ? 'Reward image unlocked!' : '¡Imagen de recompensa desbloqueada!', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown))]),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isPerfect ? Colors.green.shade100 : Colors.amber.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isPerfect ? Colors.green.shade700 : Colors.amber.shade800,
                width: 2),
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context).tr('xpScore', {'xp': '${state.totalexperiencia}', 'max': '$max'}),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).tr('solvedOf', {'solved': '${state.solvedCount}', 'total': '${state.pages.length}'}),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (!isPerfect) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppLocalizations.of(context).locale.languageCode == 'en'
                        ? 'You missed $missed XP for not solving ${state.pages.length - state.solvedCount} puzzle(s). Retry for 100%!'
                        : 'Te faltaron $missed ${AppLocalizations.of(context).tr('xp')} por no resolver ${state.pages.length - state.solvedCount} acertijo(s). ¡Reinténtalos para el 100%!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.brown, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Perfect score! You proved to be a great detective.' : '¡Puntuación perfecta! Has demostrado ser un gran detective.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800, foregroundColor: Colors.amber),
              icon: const Icon(Icons.local_library),
              label: const Text('Volver a la biblioteca',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              icon: const Icon(Icons.gavel),
              label: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Final Deduction' : 'Deducción final',
                  style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: () async {
                Navigator.pop(context);
                final deduceId = {'nebelheim':'113','lighthouse':'114','carnival':'115','observatory':'116','train':'117','abbey':'118'}[state.book.id] ?? '113';
                try {
                  final p = await di.sl<PuzzleLocalDataSource>().getPuzzle(deduceId);
                  if (!context.mounted) return;
                  final repo = di.sl<BookProgressRepository>();
                  final alreadySolved = repo.secrets.contains(deduceId) || repo.allSolvedIds.contains(deduceId);
                  if (!context.mounted) return;
                  showDialog(context: context, builder: (dCtx) {
                    int failedAttempts = 0;
                    bool? lastCorrect;
                    bool solved = alreadySolved;
                    return StatefulBuilder(builder: (c, setSt) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFFFFF3CD),
                        title: Row(children: [const Icon(Icons.gavel, color: Colors.brown), const SizedBox(width: 8), Expanded(child: Text(p.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))]),
                        content: SingleChildScrollView(child: PuzzleCard(
                          puzzle: p,
                          isSolved: solved,
                          lastAnswerCorrect: lastCorrect,
                          failedAttempts: failedAttempts,
                          onSubmit: (ans, hints) async {
                            if (solved) return;
                            final ok = p.checkAnswer(ans);
                            if (ok) {
                              final penalty = (hints * 5).clamp(0, p.experiencia - 1);
                              final awarded = (p.experiencia - penalty).clamp(1, 999);
                              await repo.markSecretSolved(puzzleId: deduceId, experiencia: awarded);
                              FeedbackService().success(); FeedbackService().celebrate();
                              setSt(() { solved = true; lastCorrect = true; });
                              if (c.mounted) ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(c).tr('correctXp', {'xp':'$awarded'})} · ${AppLocalizations.of(c).locale.languageCode=='en'?'Secret unlocked!':'¡Secreto desbloqueado!'}')));
                            } else {
                              FeedbackService().error();
                              setSt(() { failedAttempts++; lastCorrect = false; });
                            }
                          },
                        )),
                        actions: [TextButton(onPressed: ()=> Navigator.pop(dCtx), child: Text(solved ? (AppLocalizations.of(c).locale.languageCode=='en'?'Close':'Cerrar') : AppLocalizations.of(c).tr('cancel')))],
                      );
                    });
                  });
                } catch (_) {}
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.first_page),
              label: const Text('Ir al inicio',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: () {
                Navigator.pop(context);
                context.read<BookBloc>().add(const GoToPageEvent(0));
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book),
              label: const Text('Releer página a página',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: () {
                Navigator.pop(context);
                context.read<BookBloc>().add(const GoToPageEvent(0));
              },
            ),
            const SizedBox(height: 8),
            if (!isPerfect)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, foregroundColor: Colors.black),
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar acertijos pendientes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                onPressed: () {
                  Navigator.pop(context);
                  // Lleva a la primera no resuelta
                  final idx = state.pages.indexWhere(
                      (p) => !state.solvedPuzzleIds.contains(p.puzzle.id));
                  if (idx >= 0) context.read<BookBloc>().add(GoToPageEvent(idx));
                },
              ),
            if (isPerfect)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, foregroundColor: Colors.black),
                icon: const Icon(Icons.refresh),
                label: const Text('Empezar de nuevo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<BookBloc>().add(const ResetBookEvent());
                },
              ),
          ],
        ),
      ],
    );
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
            Text(AppLocalizations.of(context).tr('indexTitle'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
                '${state.solvedCount} / ${state.pages.length} ${AppLocalizations.of(context).tr('solved')} · ${AppLocalizations.of(context).tr('xpScore', {'xp': '${state.totalexperiencia}', 'max': '${state.maxPossibleexperiencia}'})}',
                style: const TextStyle(color: Colors.brown)),
            if (state.missedexperiencia > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  AppLocalizations.of(context).locale.languageCode == 'en'
                      ? 'Solve pending and earn +${state.missedexperiencia} ⭐!'
                      : '¡Resuelve los pendientes y gana +${state.missedexperiencia} ⭐!',
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.pages.length,
                itemBuilder: (_, i) {
                  final solved =
                      state.solvedPuzzleIds.contains(state.pages[i].puzzle.id);
                  final current = i == state.currentIndex;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _goTo(i, state);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: solved
                            ? Colors.green.shade200
                            : current
                                ? Colors.amber
                                : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: current ? Colors.brown.shade900 : Colors.brown,
                          width: current ? 2.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('${i + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (solved)
                            const Positioned(
                              right: 2,
                              bottom: 2,
                              child: Icon(Icons.check_circle,
                                  size: 10, color: Colors.green),
                            ),
                        ],
                      ),
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
            final l10n = AppLocalizations.of(context);
            final title = state is BookLoaded ? state.book.title : l10n.tr('openingBook');
            final subtitle = state is BookLoaded
                ? l10n.tr('bookStage', {'stage': '${state.book.stage}', 'count': '${state.pages.length}'})
                : l10n.tr('aBookOfPuzzles');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.amber, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<BookBloc, BookState>(
            builder: (context, state) {
              if (state is! BookLoaded) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page, color: Colors.amber),
                    tooltip: AppLocalizations.of(context).tr('goToStart'),
                    onPressed: state.isFirstPage ? null : () => _goToFirst(state),
                  ),
                  IconButton(
                    icon: Icon(_mirror ? Icons.flip : Icons.flip_outlined, color: Colors.amber),
                    tooltip: _mirror ? 'Modo normal' : 'Modo espejo',
                    onPressed: () => setState(() => _mirror = !_mirror),
                  ),
                  IconButton(
                    icon: const Icon(Icons.format_size, color: Colors.amber),
                    tooltip: AppLocalizations.of(context).tr('hint') == 'Pista' ? 'Tamaño de letra' : 'Font size',
                    onPressed: _cycleTextScale,
                  ),
                  IconButton(
                    icon: Icon(_isReading ? Icons.stop_circle : Icons.volume_up,
                        color: Colors.amber),
                    tooltip: _isReading ? 'Detener audiolibro' : 'Escuchar página (audiolibro)',
                    onPressed: () => _toggleReading(state),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.amber),
                    tooltip: 'Índice',
                    onPressed: () => _showIndex(context, state),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocListener<BookBloc, BookState>(
        listenWhen: (prev, curr) =>
            curr is BookLoaded && curr.lastAnswerCorrect != null &&
            (prev is! BookLoaded || prev.lastAnswerCorrect != curr.lastAnswerCorrect),
        listener: (context, state) {
          if (state is BookLoaded) {
            if (state.lastAnswerCorrect == true) {
              FeedbackService().success();
            } else if (state.lastAnswerCorrect == false) {
              FeedbackService().error();
            }
          }
        },
        child: BlocConsumer<BookBloc, BookState>(
        listenWhen: (a, b) =>
            b is BookLoaded &&
            (a is! BookLoaded || (b.currentIndex != (a).currentIndex)),
        listener: (context, state) {
          if (state is BookLoaded && _pageController.hasClients) {
            unawaited(_stopReading());
            _syncing = true;
            _pageController
                .animateToPage(
              state.currentIndex,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
            )
                .then((_) => _syncing = false);
          }
        },
        builder: (context, state) {
          if (state is BookInitial || state is BookLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }
          if (state is BookError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookBloc>()
                        .add(LoadBookEvent(widget.bookId, initialPage: widget.initialPage)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is! BookLoaded) return const SizedBox.shrink();

          // Solo el 100% dispara la vista de celebración completa automática.
          if (state.isFullyCompleted) return _completedView(context, state);

          return Column(
            children: [
              _progressHeader(state),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  onPageChanged: (i) {
                    if (_syncing) return;
                    // Navegación libre: deslizamiento sin bloqueo.
                    context.read<BookBloc>().add(GoToPageEvent(i));
                  },
                  itemBuilder: (context, index) {
                    final isCurrent = index == state.currentIndex;
                    // Efecto libro: escala + sombra según distancia.
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (ctx, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index).abs().clamp(0.0, 1.0);
                        } else if (!isCurrent) {
                          value = 1.0;
                        } else {
                          value = 0.0;
                        }
                        final scale = 1 - (value * 0.06);
                        final opacity = isCurrent || !_pageController.position.haveDimensions
                            ? 1.0
                            : 0.85;
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(scale: scale, child: child),
                        );
                      },
                      child: _bookSheet(context, state, index, isCurrent),
                    );
                  },
                ),
              ),
              _bottomBar(context, state),
            ],
          );
        },
      ),
      ),
          // Celebración de 3,2 s al resolver el acertijo de la página.
          BlocBuilder<BookBloc, BookState>(
            builder: (context, state) {
              if (state is BookLoaded &&
                  state.lastAnswerCorrect == true &&
                  state.isCurrentSolved) {
                final page = state.currentPage;
                return SolvedCelebration(
                  pageNumber: page.pageNumber,
                  pageCount: state.pages.length,
                  experiencia: page.puzzle.experiencia,
                  onDone: () => context.read<BookBloc>().add(const ClearPageResultEvent()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _progressHeader(BookLoaded state) {
    final max = state.maxPossibleexperiencia;
    return ResponsiveCenter(
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1A1009),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).tr('pageOf', {'current': '${state.currentIndex + 1}', 'total': '${state.pages.length}'}),
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⭐ ${state.totalexperiencia} / $max',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.solvedCount} ${AppLocalizations.of(context).tr('solved')}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              if (state.missedexperiencia > 0)
                Flexible(
                  child: Text(
                    AppLocalizations.of(context).tr('gainXpIfSolve', {'xp': '${state.currentPage.puzzle.experiencia}'}),
                    style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else if (state.isCurrentSolved)
                Text(AppLocalizations.of(context).tr('gainedXp'),
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );
  }

  /// Hoja del libro: historia arriba, acertijo al final. Responsive: ancho máx y centrado.
  Widget _bookSheet(BuildContext context, BookLoaded state, int index, bool isCurrent) {
    final page = state.pages[index];
    final solved = state.solvedPuzzleIds.contains(page.puzzle.id);
    final isLast = index == state.pages.length - 1;
    return ResponsiveCenter(
      maxWidth: Responsive.bookSheetMaxWidth(context),
      child: Container(
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
        padding: EdgeInsets.all(Responsive.isPhone(context) ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (page.collectibleId != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events, size: 14, color: Colors.brown), const SizedBox(width: 6), Text('Coleccionable ${page.collectibleId}', style: const TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold))]),
              ),
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
              style: TextStyle(
                fontSize: 21 * _textScale,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'serif',
              ),
            ),
            const Divider(color: Colors.amber, thickness: 1.5),
            Text(
              page.storyText,
              style: TextStyle(
                fontSize: 15 * _textScale,
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
                AppLocalizations.of(context).tr('bookSheetPuzzle', {'num': '${page.pageNumber}'}),
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Transform(
              alignment: Alignment.center,
              transform: _mirror ? Matrix4.diagonal3Values(-1, 1, 1) : Matrix4.identity(),
              child: PuzzleCard(
                puzzle: page.puzzle,
                isSolved: solved,
                textScale: _textScale,
                lastAnswerCorrect: isCurrent ? state.lastAnswerCorrect : null,
                failedAttempts: isCurrent ? state.failedAttemptsOnPage : 0,
                onSubmit: (answer, hintsUsed) {
                  if (isCurrent) {
                    final bonus = _isTimed && _secondsLeft > 60;
                    context.read<BookBloc>().add(SubmitPageAnswerEvent(answer, hintsUsed: hintsUsed, timedBonus: bonus));
                    if (bonus && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Time bonus +30% XP!' : '¡Bonus tiempo +30% XP!')));
                  }
                },
              ),
            ),
            if (isCurrent) ...[
              if (!isLast && solved)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(AppLocalizations.of(context).tr('passPage'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => context.read<BookBloc>().add(const NextPageEvent()),
                  ),
                ),
              if (!isLast && !solved) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.brown, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).tr('dareAndGain2', {'xp': '${page.puzzle.experiencia}'}),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.brown.shade800,
                    side: BorderSide(color: Colors.brown.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: Text(AppLocalizations.of(context).tr('continueWithoutSolving'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _confirmSkip(context, state),
                ),
                // Atajo discreto para seguir intentando: no hace nada, solo recuerda el premio
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context).tr('hint')}: ${AppLocalizations.of(context).tr('hintUse')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.brown.shade600, fontStyle: FontStyle.italic),
                ),
              ],
              if (isLast) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                if (!solved)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade700),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.brown, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).tr('lastPageUnsolved', {'xp': '${page.puzzle.experiencia}'}),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade800,
                    foregroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.emoji_events),
                  label: Text(
                      solved ? AppLocalizations.of(context).tr('viewFinalSummary') + ' ⭐' : AppLocalizations.of(context).tr('viewFinalWithXp', {'xp': '${state.totalexperiencia}', 'max': '${state.maxPossibleexperiencia}'}),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _showFinalSummary(context, state),
                ),
                if (!solved) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Intentar acertijo final'),
                    onPressed: () {},
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, BookLoaded state) {
    final canPrev = state.canGoPrevious;
    final isSolved = state.isCurrentSolved;
    return ResponsiveCenter(
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: const Color(0xFF1A1009),
      child: Row(
        children: [
          // Ir al inicio
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                side: const BorderSide(color: Colors.amber),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: const Icon(Icons.first_page, size: 18),
              label: Text(AppLocalizations.of(context).tr('start'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              onPressed: state.isFirstPage ? null : () => context.read<BookBloc>().add(const GoToPageEvent(0)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                side: const BorderSide(color: Colors.amber),
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(AppLocalizations.of(context).tr('back'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
              onPressed: canPrev ? () => context.read<BookBloc>().add(const PreviousPageEvent()) : null,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${state.currentIndex + 1}/${state.pages.length}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          // Siguiente / Saltar / Ver final
          Expanded(
            flex: 2,
            child: state.isLastPage
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade800,
                      foregroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.emoji_events, size: 16),
                    label: Text(AppLocalizations.of(context).tr('viewEnd'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onPressed: () => _showFinalSummary(context, state),
                  )
                : isSolved
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(AppLocalizations.of(context).tr('next'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        onPressed: () => context.read<BookBloc>().add(const NextPageEvent()),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade300,
                          foregroundColor: Colors.brown.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.skip_next, size: 16),
                        label: Text(AppLocalizations.of(context).tr('skip'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        onPressed: () => _confirmSkip(context, state),
                      ),
          ),
        ],
      ),
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
              const Icon(Icons.auto_stories, size: 64, color: Colors.brown),
              const SizedBox(height: 12),
              const Text(
                '¡Fin del libro!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).locale.languageCode == 'en'
                    ? (state.book.stage == 1
                        ? 'Nebelheim tower ticks again. Holmes closes his violin and I smile: "Every worthy case ends… with another mystery".'
                        : '"${state.book.title}" solved. Holmes lights his pipe: "Elementary, my dear Watson".')
                    : (state.book.stage == 1
                        ? 'La torre de Nebelheim vuelve a latir. Holmes cierra su violín y yo sonrío: "Todo caso digno termina… con otro misterio".'
                        : '"${state.book.title}" queda resuelto. Holmes enciende su pipa: "Es elemental, querido Watson".'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade800, width: 2),
                ),
                child: Text(
                  '⭐ ${state.totalexperiencia} ${AppLocalizations.of(context).tr('xp')} · ${state.solvedCount}/${state.pages.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).locale.languageCode == 'en' ? 'Perfect score! You solved all puzzles.' : '¡Puntuación perfecta! Has resuelto todos los acertijos.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade800, foregroundColor: Colors.amber),
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
                    label: const Text('Releer', maxLines: 1, overflow: TextOverflow.ellipsis),
                    onPressed: () => context.read<BookBloc>().add(const GoToPageEvent(0)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Empezar de nuevo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    onPressed: () => context.read<BookBloc>().add(const ResetBookEvent()),
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
