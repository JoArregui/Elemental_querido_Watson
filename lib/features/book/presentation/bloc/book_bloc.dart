import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/book_local_data_source.dart';
import '../../data/repositories/book_progress_repository.dart';
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
        await progress.saveLastPosition(
            bookId: s.book.id, pageIndex: s.currentIndex + 1);
        emit(s.copyWith(
          currentIndex: s.currentIndex + 1,
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
          // A1: penalización -5 XP por pista usada (mín 1 XP)
          final penalty = (event.hintsUsed * 5).clamp(0, puzzle.experiencia - 1);
          final awarded = (puzzle.experiencia - penalty).clamp(1, 999);
          await progress.markSolved(
            bookId: s.book.id,
            puzzleId: puzzle.id,
            experiencia: awarded,
          );
          final updated = progress.solvedFor(s.book.id);
          emit(s.copyWith(
            solvedPuzzleIds: updated,
            totalexperiencia: progress.experienciaFor(s.book.id),
            lastAnswerCorrect: () => true,
          ));
        } else {
          emit(s.copyWith(
            lastAnswerCorrect: () => false,
            failedAttemptsOnPage: s.failedAttemptsOnPage + 1,
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
}
