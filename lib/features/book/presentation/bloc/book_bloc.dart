import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/locale_service.dart';
import '../../data/datasources/book_local_data_source.dart';
import '../../data/repositories/book_progress_repository.dart';
import '../../domain/entities/book_page.dart';
import '../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import 'book_event.dart';
import 'book_state.dart';

/// Lector de un libro concreto (etapa). El progreso se guarda en
/// [BookProgressRepository] para que sobreviva al volver a la biblioteca.
class BookBloc extends Bloc<BookEvent, BookState> {
  final BookLocalDataSource dataSource;
  final BookProgressRepository progress;

  BookBloc({required this.dataSource, required this.progress})
      : super(const BookInitial()) {
    on<LoadBookEvent>((event, emit) async {
      emit(const BookLoading());
      try {
        final book = await dataSource.getBook(event.bookId);
        final start = event.initialPage.clamp(0, book.pages.length - 1);
        final solved = progress.solvedFor(book.id);
        // Navegación libre: se respeta la última posición guardada,
        // aunque la página anterior no esté resuelta. Avanzar sin
        // resolver solo deja de sumar experiencia.
        await progress.saveLastPosition(bookId: book.id, pageIndex: start);
        emit(BookLoaded(
          book: book,
          pages: book.pages,
          currentIndex: start,
          solvedPuzzleIds: solved,
          totalexperiencia: progress.experienciaFor(book.id),
        ));
      } catch (_) {
        emit(const BookError('No se pudo abrir el libro. Inténtalo de nuevo.'));
      }
    });

    on<GoToPageEvent>((event, emit) async {
      final s = state;
      if (s is BookLoaded) {
        if (event.pageIndex < 0 || event.pageIndex >= s.pages.length) return;
        // Navegación libre: cualquier página es accesible.
        await progress.saveLastPosition(
            bookId: s.book.id, pageIndex: event.pageIndex);
        emit(s.copyWith(
          currentIndex: event.pageIndex,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<NextPageEvent>((event, emit) async {
      final s = state;
      if (s is BookLoaded) {
        if (!s.canGoNext) return;
        final nextIdx = s.currentIndex + 1;
        List<BookPage> pages = s.pages;
        final wasBranched = s.branchedPuzzleIds.contains(s.currentPage.puzzle.id);
        if (wasBranched && nextIdx < s.pages.length) {
          try {
            final branchId = _branchIdFor(s.currentPage.puzzle.id);
            final puzzleDs = GetIt.I.get<PuzzleLocalDataSource>();
            final branchPuzzle = await puzzleDs.getPuzzle(branchId);
            final nextPage = s.pages[nextIdx];
            final locale = GetIt.I.get<LocaleService>().value.languageCode;
            final altStory = _branchStoryFor(s.currentPage.puzzle.id, locale);
            final altTitle = _branchTitleFor(s.currentPage.puzzle.id, locale);
            final altPage = nextPage.copyWith(
              puzzle: branchPuzzle,
              storyText: altStory ?? nextPage.storyText,
              storyTitle: altTitle ?? nextPage.storyTitle,
            );
            pages = List<BookPage>.from(s.pages);
            pages[nextIdx] = altPage;
          } catch (_) {}
        }
        await progress.saveLastPosition(
            bookId: s.book.id, pageIndex: nextIdx);
        emit(s.copyWith(
          pages: pages,
          currentIndex: nextIdx,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<PreviousPageEvent>((event, emit) async {
      final s = state;
      if (s is BookLoaded) {
        if (s.currentIndex == 0) return;
        await progress.saveLastPosition(
            bookId: s.book.id, pageIndex: s.currentIndex - 1);
        emit(s.copyWith(
          currentIndex: s.currentIndex - 1,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<SubmitPageAnswerEvent>((event, emit) async {
      final s = state;
      if (s is BookLoaded) {
        if (s.isBlockedByAttempts) return;
        final puzzle = s.currentPage.puzzle;
        final isCorrect = puzzle.checkAnswer(event.answer);
        if (isCorrect) {
          // A1: penalización -5 XP por pista usada (mín 1 XP) + A2 bonus tiempo +30%
          final penalty = (event.hintsUsed * 5).clamp(0, puzzle.experiencia - 1);
          var awarded = (puzzle.experiencia - penalty).clamp(1, 999);
          if (event.timedBonus) awarded = (awarded * 1.3).round().clamp(1, 999);
          // Si es puzzle ramificado 101-112, también cuenta como secreto 18
          final isBranchSecret = RegExp(r'^(10[1-9]|11[0-2])$').hasMatch(puzzle.id);
          if (isBranchSecret) {
            await progress.markSecretSolved(puzzleId: puzzle.id, experiencia: 0);
          }
          await progress.markSolved(
            bookId: s.book.id,
            puzzleId: puzzle.id,
            experiencia: awarded,
            collectibleId: s.currentPage.collectibleId,
          );
          final updated = progress.solvedFor(s.book.id);
          emit(s.copyWith(
            solvedPuzzleIds: updated,
            totalexperiencia: progress.experienciaFor(s.book.id),
            lastAnswerCorrect: () => true,
          ));
        } else {
          final nextFailed = s.failedAttemptsOnPage + 1;
          final isSecondFail = nextFailed == 2;
          final newBranched = isSecondFail ? {...s.branchedPuzzleIds, puzzle.id} : s.branchedPuzzleIds;
          emit(s.copyWith(
            lastAnswerCorrect: () => false,
            failedAttemptsOnPage: nextFailed,
            branchedPuzzleIds: newBranched,
          ));
        }
      }
    });

    on<ClearPageResultEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        emit(s.copyWith(lastAnswerCorrect: () => null));
      }
    });

    on<ResetBookEvent>((event, emit) async {
      final s = state;
      if (s is BookLoaded) {
        await progress.resetBook(s.book.id);
        await progress.saveLastPosition(bookId: s.book.id, pageIndex: 0);
        emit(s.copyWith(
          currentIndex: 0,
          solvedPuzzleIds: <String>{},
          totalexperiencia: 0,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });
  }

  String _branchIdFor(String failedId) {
    const map = {
      'B05': '101', 'B10': '102', '007': '103', '005': '104', 'C05': '105', 'O05': '106',
      'T08': '107', 'A06': '108', 'B22': '109', 'B25': '110', '009': '111', '029': '112',
    };
    return map[failedId] ?? '101';
  }

  String? _branchStoryFor(String failedId, String locale) {
    final isEn = locale == 'en';
    const esMap = {
      'B05': 'Watson intervino tras tus dos fallos en el friso: encontró un pasadizo lateral que no habíamos visto. La historia toma un atajo secreto y el siguiente enigma es distinto.',
      'B10': 'Tras fallar los cofres dos veces, Watson notó una marca de tiza que indicaba el cofre verde. El siguiente capítulo cambia y Holmes te mira con complicidad.',
      '007': 'Dos fallos pesando monedas: Watson recordó la técnica de 3 grupos y abrió una balanza alternativa. La marea del caso gira.',
      '005': 'Fallaste dos veces los interruptores: Watson propuso usar el calor residual y la historia se bifurca hacia un sótano distinto.',
      'C05': 'Tras dos fallos en los triángulos, Watson dibujó la figura en el vaho y apareció un nuevo acertijo de máscaras.',
      'O05': 'Dos fallos en la balanza: Vega sacó pesas de 3 kg y la historia del observatorio se nubla con un nuevo reto.',
      'T08': 'Fallaste el rubí dos veces: Watson encontró una carta del revisor y el tren toma una vía alternativa.',
      'A06': 'Dos fallos en el rosetón: el hermano vidriero susurró otra pista y la galería susurra un nombre distinto.',
      'B22': 'Fallaste el candado dos veces: Watson recordó la pista del 6 y la historia del diario se reescribe con un código nuevo.',
      'B25': 'Dos fallos en el mosaico: el suelo crujió y reveló un mosaico alternativo de 4x4.',
      '009': 'Dos fallos con las edades: Watson recontó y la marea del contrabando trae un acertijo de familia distinto.',
      '029': 'Dos fallos con las huellas: Watson midió de nuevo y el oso resulta ser otro; la pista cambia.',
    };
    const enMap = {
      'B05': 'Watson stepped in after your two failures on the frieze: he found a side passage we had missed. The story takes a secret shortcut and the next riddle is different.',
      'B10': 'After failing the chests twice, Watson noticed a chalk mark pointing to the green chest. The next chapter shifts and Holmes gives you a knowing glance.',
      '007': 'Two failures weighing coins: Watson recalled the 3-group technique and opened an alternative scale. The tide of the case turns.',
      '005': 'You failed the switches twice: Watson suggested using residual heat and the story branches to a different basement.',
      'C05': 'After two failures on triangles, Watson sketched the figure in the steam and a new mask riddle appeared.',
      'O05': 'Two failures on the scale: Vega brought out 3kg weights and the observatory story clouds with a new challenge.',
      'T08': 'You failed the ruby twice: Watson found the conductor letter and the train takes an alternative track.',
      'A06': 'Two failures on the rose window: the glazier brother whispered another clue and the gallery whispers a different name.',
      'B22': 'You failed the diary lock twice: Watson recalled the clue about 6 and the diary story rewrites with a new code.',
      'B25': 'Two failures on the mosaic: the floor creaked and revealed an alternative 4x4 mosaic.',
      '009': 'Two failures with ages: Watson recounted and the smuggling tide brings a different family riddle.',
      '029': 'Two failures with footprints: Watson re-measured and the bear turns out to be another; the clue changes.',
    };
    return isEn ? enMap[failedId] : esMap[failedId];
  }

  String? _branchTitleFor(String failedId, String locale) {
    final isEn = locale == 'en';
    const esMap = {
      'B05': 'Atajo de Watson',
      'B10': 'El cofre verde',
      '007': 'Balanza alternativa',
      '005': 'Sótano distinto',
      'C05': 'Máscara alternativa',
      'O05': 'Noche nublada',
      'T08': 'Vía alternativa',
      'A06': 'Vidriera distinta',
      'B22': 'Código nuevo',
      'B25': 'Mosaico 4x4',
      '009': 'Familia alternativa',
      '029': 'Huella distinta',
    };
    const enMap = {
      'B05': 'Watson Shortcut',
      'B10': 'The Green Chest',
      '007': 'Alternative Scale',
      '005': 'Different Basement',
      'C05': 'Alternative Mask',
      'O05': 'Cloudy Night',
      'T08': 'Alternative Track',
      'A06': 'Different Stained Glass',
      'B22': 'New Code',
      'B25': '4x4 Mosaic',
      '009': 'Alternative Family',
      '029': 'Different Print',
    };
    return isEn ? enMap[failedId] : esMap[failedId];
  }
}
