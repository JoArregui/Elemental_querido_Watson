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
import '../../../../core/services/reading_mode_service.dart';
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
  bool _isPaused = false;
  bool _mirror = false;
  bool _isTimed = false;
  int _secondsLeft = 0;
  double _textScale = 1.0;
  TtsService? _tts;
  // C3: resaltado de palabra y oración
  int _highlightStart = -1;
  int _highlightEnd = -1;
  int _currentSentence = 0;
  String _ttsFullText = '';
  StreamSubscription? _ttsProgressSub;
  StreamSubscription? _ttsSentenceSub;
  // Clave del último acertijo final ya celebrado con la finish_page (evita reabrirla).
  String? _finishShownKey;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.sl<AudioService>().playForBook(widget.bookId);
    });
  }

  @override
  void dispose() {
    _isReading = false;
    _isPaused = false;
    unawaited(_tts?.stop());
    unawaited(di.sl<AudioService>().stop());
    _ttsProgressSub?.cancel();
    _ttsSentenceSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  TtsService _ttsService() {
    final svc = _tts ??= di.sl<TtsService>();
    svc.onComplete = () {
      if (mounted) {
        setState(() {
          _isReading = false;
          _isPaused = false;
          _highlightStart = -1;
          _highlightEnd = -1;
          _currentSentence = 0;
        });
      }
      unawaited(di.sl<AudioService>().duck(false));
    };
    // C3: suscribirse una sola vez al stream de progreso
    _ttsProgressSub ??= svc.progress.listen((p) {
      if (!mounted || !_isReading) return;
      setState(() {
        _highlightStart = p.start;
        _highlightEnd = p.end;
      });
    });
    _ttsSentenceSub ??= svc.sentenceIndex.listen((idx) {
      if (!mounted || !_isReading) return;
      setState(() => _currentSentence = idx);
    });
    return svc;
  }

  /// Lee en voz alta la página actual (historia + acertijo) con resaltado + pausa por frase (C3).
  Future<void> _toggleReading(BookLoaded state) async {
    if (_isReading) {
      if (_isPaused) {
        await _resumeReading();
      } else {
        await _pauseReading();
      }
      return;
    }
    final page = state.currentPage;
    final text = '${page.storyTitle}. ${page.storyText} '
        'Acertijo de la página ${page.pageNumber}: '
        '${page.puzzle.title}. ${page.puzzle.statement}';
    _ttsFullText = text;
    setState(() {
      _isReading = true;
      _isPaused = false;
      _highlightStart = -1;
      _highlightEnd = -1;
      _currentSentence = 0;
    });
    unawaited(di.sl<AudioService>().duck(true));
    await _ttsService().speakWithHighlight(text, pausePerSentence: true);
  }

  Future<void> _pauseReading() async {
    setState(() => _isPaused = true);
    await _ttsService().pause();
  }

  Future<void> _resumeReading() async {
    setState(() => _isPaused = false);
    await _ttsService().resume();
  }

  Future<void> _stopReading() async {
    if (!_isReading && _tts == null) return;
    setState(() {
      _isReading = false;
      _isPaused = false;
      _highlightStart = -1;
      _highlightEnd = -1;
      _currentSentence = 0;
    });
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

  // ── C3: helpers de resaltado palabra / pausa por frase ──

  List<String> _splitSentencesLocal(String text) {
    final pattern = RegExp(r'[^.!?]+[.!?]+|[^.!?]+$');
    return pattern.allMatches(text).map((m) => m.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
  }

  Widget _buildHighlightedTitle(dynamic page, bool isCurrent) {
    final baseStyle = TextStyle(fontSize: 21 * _textScale, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'serif');
    if (!isCurrent || !_isReading || _ttsFullText.isEmpty) {
      return Text(page.storyTitle, style: baseStyle);
    }
    final sentences = _splitSentencesLocal(_ttsFullText);
    final cur = (_currentSentence >= 0 && _currentSentence < sentences.length) ? sentences[_currentSentence] : '';
    // Si la oración actual pertenece al título, resaltarla
    final title = page.storyTitle as String;
    final isTitleSentence = cur.isNotEmpty && (title.contains(cur) || cur.contains(title) || title == cur.replaceAll(RegExp(r'[.!?]$'), '').trim());
    if (!isTitleSentence) return Text(title, style: baseStyle);
    // Resaltar título con fondo ámbar claro + borde
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.shade700)),
      child: _buildWordHighlightedRichText(title, cur, baseStyle),
    );
  }

  Widget _buildHighlightedStory(dynamic page, bool isCurrent) {
    final baseStyle = TextStyle(fontSize: 15 * _textScale, height: 1.55, color: Colors.black87);
    final story = page.storyText as String;
    if (!isCurrent || !_isReading || _ttsFullText.isEmpty) {
      return Text(story, style: baseStyle, textAlign: TextAlign.justify);
    }
    final sentences = _splitSentencesLocal(_ttsFullText);
    final cur = (_currentSentence >= 0 && _currentSentence < sentences.length) ? sentences[_currentSentence] : '';
    if (cur.isEmpty || !story.contains(cur) && !cur.contains(story.substring(0, (20).clamp(0, story.length)))) {
      // Fallback: la frase actual no es de la historia (puede ser acertijo); mostrar historia normal + barra se encarga
      return Text(story, style: baseStyle, textAlign: TextAlign.justify);
    }
    // Resaltar la oración actual dentro de la historia
    // Buscar índices de cur dentro de story (aprox)
    final idx = story.indexOf(cur);
    if (idx == -1) {
      // Intento fuzzy: buscar primeras 20 chars
      final probe = cur.substring(0, cur.length.clamp(0, 30)).trim();
      final pIdx = story.indexOf(probe);
      if (pIdx == -1) return Text(story, style: baseStyle, textAlign: TextAlign.justify);
      // Resaltar probe
      return _buildSentenceHighlightedRichText(story, pIdx, pIdx + probe.length, baseStyle);
    }
    return _buildSentenceHighlightedRichText(story, idx, idx + cur.length, baseStyle);
  }

  Widget _buildSentenceHighlightedRichText(String full, int s, int e, TextStyle base) {
    final before = full.substring(0, s);
    final sentence = full.substring(s, e.clamp(0, full.length));
    final after = e < full.length ? full.substring(e) : '';
    // Dentro de la oración, resaltar palabra actual si coincide
    Widget sentenceWidget;
    if (_highlightStart >= 0 && _highlightEnd > _highlightStart) {
      final sentences = _splitSentencesLocal(_ttsFullText);
      final cur = (_currentSentence >= 0 && _currentSentence < sentences.length) ? sentences[_currentSentence] : '';
      final wStart = _highlightStart.clamp(0, cur.length);
      final wEnd = _highlightEnd.clamp(0, cur.length);
      if (wStart < wEnd && wStart < sentence.length) {
        final relStart = wStart;
        final relEnd = wEnd.clamp(0, sentence.length);
        // Mapear word dentro de sentence (si cur == sentence, índices coinciden)
        final sBefore = sentence.substring(0, relStart.clamp(0, sentence.length));
        final sWord = sentence.substring(relStart.clamp(0, sentence.length), relEnd);
        final sAfter = sentence.substring(relEnd.clamp(0, sentence.length));
        sentenceWidget = RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(style: base, children: [
            TextSpan(text: sBefore, style: base.copyWith(backgroundColor: Colors.amber.shade200)),
            TextSpan(text: sWord, style: base.copyWith(backgroundColor: Colors.amber.shade600, color: Colors.white, fontWeight: FontWeight.bold)),
            TextSpan(text: sAfter, style: base.copyWith(backgroundColor: Colors.amber.shade200)),
          ]),
        );
      } else {
        sentenceWidget = Text(sentence, style: base.copyWith(backgroundColor: Colors.amber.shade200));
      }
    } else {
      sentenceWidget = Text(sentence, style: base.copyWith(backgroundColor: Colors.amber.shade200));
    }
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(style: base, children: [
        TextSpan(text: before),
        WidgetSpan(child: Container(padding: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(4)), child: sentenceWidget)),
        TextSpan(text: after),
      ]),
    );
  }

  Widget _buildWordHighlightedRichText(String text, String sentence, TextStyle base) {
    if (_highlightStart < 0 || _highlightEnd <= _highlightStart) {
      return Text(text, style: base.copyWith(backgroundColor: Colors.amber.shade200));
    }
    final wStart = _highlightStart.clamp(0, sentence.length);
    final wEnd = _highlightEnd.clamp(0, sentence.length);
    if (wStart >= wEnd) return Text(text, style: base.copyWith(backgroundColor: Colors.amber.shade200));
    final word = sentence.substring(wStart, wEnd);
    final idx = text.indexOf(word);
    if (idx == -1) return Text(text, style: base.copyWith(backgroundColor: Colors.amber.shade200));
    final before = text.substring(0, idx);
    final after = text.substring(idx + word.length);
    return RichText(
      text: TextSpan(style: base, children: [
        TextSpan(text: before, style: base.copyWith(backgroundColor: Colors.amber.shade200)),
        TextSpan(text: word, style: base.copyWith(backgroundColor: Colors.brown.shade700, color: Colors.amber, fontWeight: FontWeight.bold)),
        TextSpan(text: after, style: base.copyWith(backgroundColor: Colors.amber.shade200)),
      ]),
    );
  }

  Widget _buildNarrationBar(dynamic page) {
    final sentences = _splitSentencesLocal(_ttsFullText);
    final cur = (_currentSentence >= 0 && _currentSentence < sentences.length) ? sentences[_currentSentence] : '';
    final total = sentences.length;
    final isPausedLabel = _isPaused ? '⏸ Pausado' : '🔊 Leyendo';
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: Colors.brown.shade800, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.amber.shade700)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)), child: Text('$isPausedLabel · ${_currentSentence + 1}/$total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown))),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: total == 0 ? 0 : (_currentSentence + 1) / total, minHeight: 6, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber)))),
          const SizedBox(width: 8),
          GestureDetector(onTap: () => _stopReading(), child: const Icon(Icons.stop, size: 18, color: Colors.amber)),
        ]),
        if (cur.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(cur, style: const TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
          if (_highlightStart >= 0 && _highlightEnd > _highlightStart)
            Padding(padding: const EdgeInsets.only(top: 2), child: Text('Palabra: "${cur.substring(_highlightStart.clamp(0, cur.length), _highlightEnd.clamp(0, cur.length))}"', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
        const SizedBox(height: 4),
        Text('Pausa automática de 0,65 s entre frases · toca ⏸ para pausar y ▶ para reanudar', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  /// Modo exigente activo: hay que acertar para pasar de página.
  bool get _isStrict {
    try {
      return di.sl<ReadingModeService>().isStrict;
    } catch (_) {
      return false;
    }
  }

  /// Primera página con acertijo sin resolver (límite de avance en modo exigente).
  int _firstUnsolvedIndex(BookLoaded state) {
    final idx = state.pages.indexWhere(
        (p) => !state.solvedPuzzleIds.contains(p.puzzle.id));
    return idx == -1 ? state.pages.length - 1 : idx;
  }

  /// En modo exigente, las páginas más allá del primer acertijo sin resolver están bloqueadas.
  bool _isPageLocked(BookLoaded state, int index) =>
      _isStrict && index > _firstUnsolvedIndex(state);

  void _showStrictLockedMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${AppLocalizations.of(context).tr('strictLocked')} 🔒',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Abre la finish_page tras acertar el último acertijo.
  /// Espera a que termine la celebración (~3,2 s) y solo la muestra una vez
  /// por acertijo; si el lector ya no está en esa página, no hace nada.
  void _scheduleFinishSheet(BookLoaded state) {
    final key = '${state.book.id}:${state.currentPage.puzzle.id}';
    if (_finishShownKey == key) return;
    _finishShownKey = key;
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      final s = context.read<BookBloc>().state;
      if (s is BookLoaded &&
          s.book.id == state.book.id &&
          s.isLastPage &&
          s.isCurrentSolved) {
        _showFinalSummary(context, s);
      }
    });
  }

  void _goTo(int index, BookLoaded state) {
    if (index < 0 || index >= state.pages.length) return;
    // Modo exigente: no se puede saltar más allá del primer acertijo sin resolver.
    if (_isPageLocked(state, index)) {
      _showStrictLockedMessage();
      return;
    }
    // Navegación libre: cualquier página es accesible.
    context.read<BookBloc>().add(GoToPageEvent(index));
  }

  void _goToFirst(BookLoaded state) {
    if (state.isFirstPage) return;
    context.read<BookBloc>().add(const GoToPageEvent(0));
  }

  void _confirmSkip(BuildContext context, BookLoaded state) {
    // Modo exigente: saltar está deshabilitado, hay que acertar para pasar.
    if (_isStrict) {
      _showStrictLockedMessage();
      return;
    }
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

  void _showFinalSummary(BuildContext parentContext, BookLoaded state) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF3CD),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: _summaryContent(sheetContext, parentContext, state),
        ),
      ),
    );
  }

  Widget _summaryContent(BuildContext sheetContext, BuildContext parentContext, BookLoaded state) {
    // sheetContext para UI (AppLocalizations, ScaffoldMessenger), parentContext para Bloc/Navigator
    final context = sheetContext;
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
        const SizedBox(height: 10),
        // Estrella azul del Acertijo Final (sin XP): se muestra ganada o pendiente.
        Builder(builder: (ctx) {
          final hasStar =
              di.sl<BookProgressRepository>().hasBlueStar(state.book.id);
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hasStar ? Colors.blue.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: hasStar
                      ? Colors.blue.shade700
                      : Colors.blue.shade200,
                  width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star,
                    size: 20,
                    color: hasStar
                        ? Colors.blue.shade700
                        : Colors.blue.shade200),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    hasStar
                        ? AppLocalizations.of(ctx).tr('blueStarEarned')
                        : AppLocalizations.of(ctx).tr('blueStarLocked'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasStar
                            ? Colors.blue.shade900
                            : Colors.brown),
                  ),
                ),
              ],
            ),
          );
        }),
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
                Navigator.pop(sheetContext);
                if (parentContext.mounted) Navigator.of(parentContext).pop();
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              icon: const Icon(Icons.description),
              label: Text(AppLocalizations.of(sheetContext).tr('viewFinalSummary'),
                  style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: () {
                Navigator.pop(sheetContext);
                if (parentContext.mounted) {
                  _showBookStats(parentContext, state);
                }
              },
            ),
            const SizedBox(height: 8),
            Builder(builder: (btnCtx) {
              final starEarned = di
                  .sl<BookProgressRepository>()
                  .hasBlueStar(state.book.id);
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black),
                icon: starEarned
                    ? Icon(Icons.star, color: Colors.blue.shade700)
                    : const Icon(Icons.gavel),
                label: Text(
                    "${AppLocalizations.of(sheetContext).locale.languageCode == "en" ? "Final Deduction" : "Acertijo Final"}${starEarned ? " ★" : ""}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                onPressed: () async {
                  Navigator.pop(sheetContext);
                  final deduceId = {
                    'nebelheim': '113',
                    'lighthouse': '114',
                    'carnival': '115',
                    'observatory': '116',
                    'train': '117',
                    'abbey': '118'
                  }[state.book.id] ??
                      '113';
                  try {
                    final p = await di
                        .sl<PuzzleLocalDataSource>()
                        .getPuzzle(deduceId);
                    if (!parentContext.mounted) return;
                    final repo = di.sl<BookProgressRepository>();
                    final alreadySolved =
                        repo.secrets.contains(deduceId) ||
                            repo.allSolvedIds.contains(deduceId) ||
                            repo.hasBlueStar(state.book.id);
                    // Migración: quien ya lo resolvió cuando daba XP también recibe la estrella.
                    if (alreadySolved &&
                        !repo.hasBlueStar(state.book.id)) {
                      await repo.markBlueStar(state.book.id);
                    }
                    if (!parentContext.mounted) return;
                    showDialog(
                        context: parentContext,
                        builder: (dCtx) {
                          int failedAttempts = 0;
                          bool? lastCorrect;
                          bool solved = alreadySolved;
                          return StatefulBuilder(builder: (c, setSt) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color(0xFFFFF3CD),
                              title: Row(children: [
                                Icon(Icons.gavel,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(p.title,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.bold)))
                              ]),
                              content: SingleChildScrollView(
                                  child: PuzzleCard(
                                puzzle: p,
                                isSolved: solved,
                                lastAnswerCorrect: lastCorrect,
                                failedAttempts: failedAttempts,
                                // Recompensa: estrella azul, sin XP.
                                blueStarReward: true,
                                onSubmit: (ans, hints) async {
                                  if (solved) return;
                                  final ok = p.checkAnswer(ans);
                                  if (ok) {
                                    // Sin XP: el Acertijo Final otorga la estrella azul.
                                    await repo.markSecretSolved(
                                        puzzleId: deduceId,
                                        experiencia: 0);
                                    await repo.markBlueStar(
                                        state.book.id);
                                    FeedbackService().success();
                                    FeedbackService().celebrate();
                                    setSt(() {
                                      solved = true;
                                      lastCorrect = true;
                                    });
                                    if (c.mounted) {
                                      ScaffoldMessenger.of(c)
                                          .showSnackBar(SnackBar(
                                              content: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star,
                                              color: Colors
                                                  .blue.shade700),
                                          const SizedBox(
                                              width: 8),
                                          Flexible(
                                              child: Text(
                                            '${AppLocalizations.of(c).tr('blueStarEarned')} ★',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold),
                                          )),
                                        ],
                                      )));
                                    }
                                  } else {
                                    FeedbackService().error();
                                    setSt(() {
                                      failedAttempts++;
                                      lastCorrect = false;
                                    });
                                  }
                                },
                              )),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dCtx),
                                    child: Text(solved
                                        ? (AppLocalizations.of(c)
                                                    .locale
                                                    .languageCode ==
                                                'en'
                                            ? 'Close'
                                            : 'Cerrar')
                                        : AppLocalizations.of(c)
                                            .tr('cancel')))
                              ],
                            );
                          });
                        });
                  } catch (_) {}
                },
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, foregroundColor: Colors.black),
              icon: const Icon(Icons.refresh),
              label: const Text('Empezar de nuevo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              onPressed: () {
                final bloc = parentContext.read<BookBloc>();
                Navigator.pop(sheetContext);
                bloc.add(const ResetBookEvent());
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Estadísticas del libro actual: se abren desde "Ver resumen" de la finish_page.
  void _showBookStats(BuildContext parentContext, BookLoaded state) {
    final isEn =
        AppLocalizations.of(parentContext).locale.languageCode == 'en';
    final repo = di.sl<BookProgressRepository>();
    final ids = state.pages.map((p) => p.puzzle.id).toList();
    final attempts =
        ids.fold<int>(0, (sum, id) => sum + (repo.attemptsPerPuzzle[id] ?? 0));
    final successes =
        ids.fold<int>(0, (sum, id) => sum + (repo.successPerPuzzle[id] ?? 0));
    final rate = attempts == 0 ? null : successes / attempts;
    final hints =
        ids.fold<int>(0, (sum, id) => sum + (repo.hintsPerPuzzle[id] ?? 0));
    final times = ids
        .map((id) => repo.timePerPuzzle[id] ?? 0)
        .where((v) => v > 0)
        .toList();
    final avgTime =
        times.isEmpty ? null : times.reduce((a, b) => a + b) ~/ times.length;
    final hasStar = repo.hasBlueStar(state.book.id);
    String fmtTime(int s) =>
        s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';
    showDialog(
      context: parentContext,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3CD),
        title: Row(children: [
          const Icon(Icons.bar_chart, color: Colors.brown),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEn
                  ? '${state.book.title} · Stats'
                  : '${state.book.title} · Estadísticas',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bookStatRow(
                Icons.star,
                Colors.amber.shade700,
                isEn ? 'Score' : 'Puntuación',
                '⭐ ${state.totalexperiencia}/${state.maxPossibleexperiencia} XP',
              ),
              _bookStatRow(
                Icons.emoji_events,
                Colors.green.shade700,
                isEn ? 'Solved' : 'Acertijos',
                '${state.solvedCount}/${state.pages.length}',
              ),
              _bookStatRow(
                Icons.percent,
                Colors.blue.shade700,
                isEn ? 'Success rate' : 'Tasa de acierto',
                rate == null
                    ? '—'
                    : '${(rate * 100).toStringAsFixed(1)}% ($successes/$attempts)',
              ),
              _bookStatRow(
                Icons.timer,
                Colors.orange.shade700,
                isEn ? 'Avg time / puzzle' : 'Tiempo medio',
                avgTime == null ? '—' : fmtTime(avgTime),
              ),
              _bookStatRow(
                Icons.lightbulb,
                Colors.brown,
                isEn ? 'Hints used' : 'Pistas usadas',
                '$hints',
              ),
              _bookStatRow(
                Icons.star,
                hasStar ? Colors.blue.shade700 : Colors.blue.shade200,
                isEn ? 'Blue star' : 'Estrella azul',
                hasStar
                    ? (isEn ? 'Earned ★' : 'Conseguida ★')
                    : (isEn ? 'Missing' : 'Pendiente'),
              ),
              if (state.missedexperiencia > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    isEn
                        ? 'You missed ${state.missedexperiencia} XP. Retry pending puzzles for 100%!'
                        : 'Te faltaron ${state.missedexperiencia} XP. ¡Reintenta los pendientes para el 100%!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.brown,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(isEn ? 'Close' : 'Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _bookStatRow(
      IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
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
                  // Modo exigente: páginas más allá del primer acertijo sin resolver, bloqueadas.
                  final locked = _isPageLocked(state, i);
                  return GestureDetector(
                    onTap: () {
                      if (locked) {
                        _showStrictLockedMessage();
                        return;
                      }
                      Navigator.pop(context);
                      _goTo(i, state);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: locked
                            ? Colors.blue.shade50
                            : solved
                                ? Colors.green.shade200
                                : current
                                    ? Colors.amber
                                    : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: locked
                              ? Colors.blue.shade300
                              : current
                                  ? Colors.brown.shade900
                                  : Colors.brown,
                          width: current ? 2.5 : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text('${i + 1}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: locked
                                      ? Colors.blue.shade300
                                      : Colors.black)),
                          if (solved)
                            const Positioned(
                              right: 2,
                              bottom: 2,
                              child: Icon(Icons.check_circle,
                                  size: 10, color: Colors.green),
                            ),
                          if (locked)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Icon(Icons.lock,
                                  size: 10,
                                  color: Colors.blue.shade400),
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
                  // C3: audiolibro con pausa por frase y resaltado — icono cambia según estado
                  IconButton(
                    icon: Icon(
                        _isReading ? (_isPaused ? Icons.play_arrow : Icons.pause) : Icons.volume_up,
                        color: Colors.amber),
                    tooltip: _isReading
                        ? (_isPaused ? 'Reanudar audiolibro' : 'Pausar audiolibro')
                        : 'Escuchar página (audiolibro)',
                    onPressed: () => _toggleReading(state),
                  ),
                  if (_isReading)
                    IconButton(
                      icon: const Icon(Icons.stop_circle, color: Colors.amber),
                      tooltip: 'Detener audiolibro',
                      onPressed: () => _stopReading(),
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
              // Al acertar el último acertijo se abre sola la finish_page.
              if (state.isLastPage && state.isCurrentSolved) {
                _scheduleFinishSheet(state);
              }
            } else if (state.lastAnswerCorrect == false) {
              FeedbackService().error();
            }
            // Si se deja de estar resuelto (p. ej. empezar de nuevo),
            // se permite volver a celebrar la finish_page al resolver.
            if (!state.isCurrentSolved) _finishShownKey = null;
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

          return Column(
            children: [
              _progressHeader(state),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.pages.length,
                  onPageChanged: (i) {
                    if (_syncing) return;
                    // Modo exigente: el deslizamiento no puede superar
                    // el primer acertijo sin resolver (rebote + aviso).
                    if (_isPageLocked(state, i)) {
                      _showStrictLockedMessage();
                      _syncing = true;
                      _pageController
                          .animateToPage(
                        state.currentIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      )
                          .then((_) => _syncing = false);
                      return;
                    }
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
            // C3: título con resaltado de frase actual si está leyendo esta página
            _buildHighlightedTitle(page, isCurrent),
            const Divider(color: Colors.amber, thickness: 1.5),
            // C3: historia con resaltado de palabra y pausa por frase
            _buildHighlightedStory(page, isCurrent),
            // C3: barra de narración — frase actual / progreso palabra
            if (isCurrent && _isReading) _buildNarrationBar(page),
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
                // Modo exigente: sin botón de saltar; hay que acertar para pasar.
                if (_isStrict)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock,
                            color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${AppLocalizations.of(context).tr('modeStrict')} · ${AppLocalizations.of(context).tr('strictLocked')}',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
              ],
              if (isLast && !solved)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
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
                ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, BookLoaded state) {
    final canPrev = state.canGoPrevious;
    // Actual = siguiente a la última con acertijo resuelto (primer no resuelto)
    int actualIndex = state.pages.indexWhere((p) => !state.solvedPuzzleIds.contains(p.puzzle.id));
    if (actualIndex == -1) actualIndex = state.pages.length - 1;
    final isOnActual = state.currentIndex == actualIndex;
    final canGoActual = !isOnActual && actualIndex >= 0 && actualIndex < state.pages.length;
    return ResponsiveCenter(
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: const Color(0xFF1A1009),
      child: Row(
        children: [
          // Ir al inicio — fix blanco en página 1: deshabilitado visible ámbar atenuado
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber,
                disabledForegroundColor: Colors.amber.withValues(alpha: 0.35),
                side: const BorderSide(color: Colors.amber),
                disabledBackgroundColor: Colors.transparent,
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
                disabledForegroundColor: Colors.amber.withValues(alpha: 0.35),
                side: const BorderSide(color: Colors.amber),
                disabledBackgroundColor: Colors.transparent,
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
          // Siguiente / Saltar — en la última página ya no hay botón Ver final:
          // al acertar el último acertijo la finish_page se abre sola.
          // Si quedan pendientes, se ofrece ir al primero pendiente.
          Expanded(
            flex: 2,
            child: state.isLastPage
                ? (canGoActual
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade700,
                          foregroundColor: Colors.amber,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        icon:
                            const Icon(Icons.my_location, size: 14),
                        label: Text(
                            AppLocalizations.of(context).tr('actual'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        onPressed: () => context
                            .read<BookBloc>()
                            .add(GoToPageEvent(actualIndex)),
                      )
                    : const SizedBox.shrink())
                : Row(
                    children: [
                      Expanded(
                        child: Builder(builder: (btnCtx) {
                          // Modo exigente sin resolver: candado con aviso en vez de Saltar.
                          final strictLocked =
                              _isStrict && !state.isCurrentSolved;
                          return ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: strictLocked
                                  ? Colors.blue.shade100
                                  : (state.isCurrentSolved
                                      ? Colors.amber
                                      : Colors.amber.shade300),
                              foregroundColor: strictLocked
                                  ? Colors.blue.shade900
                                  : (state.isCurrentSolved
                                      ? Colors.black
                                      : Colors.brown.shade900),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6),
                            ),
                            icon: Icon(
                                strictLocked
                                    ? Icons.lock
                                    : (state.isCurrentSolved
                                        ? Icons.arrow_forward
                                        : Icons.skip_next),
                                size: 14),
                            label: Text(
                                strictLocked
                                    ? AppLocalizations.of(context)
                                        .tr('locked')
                                    : (state.isCurrentSolved
                                        ? AppLocalizations.of(context)
                                            .tr('next')
                                        : AppLocalizations.of(context)
                                            .tr('skip')),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            onPressed: strictLocked
                                ? () => _showStrictLockedMessage()
                                : (state.isCurrentSolved
                                    ? () => context
                                        .read<BookBloc>()
                                        .add(const NextPageEvent())
                                    : () =>
                                        _confirmSkip(context, state)),
                          );
                        }),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canGoActual ? Colors.brown.shade700 : Colors.brown.shade700.withValues(alpha: 0.4),
                            foregroundColor: Colors.amber,
                            disabledForegroundColor: Colors.amber.withValues(alpha: 0.4),
                            disabledBackgroundColor: Colors.brown.shade700.withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                          ),
                          icon: const Icon(Icons.my_location, size: 14),
                          label: Text(AppLocalizations.of(context).tr('actual'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          onPressed: canGoActual ? () => context.read<BookBloc>().add(GoToPageEvent(actualIndex)) : null,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
