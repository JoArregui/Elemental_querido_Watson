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
        emit(BookLoaded(
          book: book,
          pages: book.pages,
          currentIndex: 0,
          solvedPuzzleIds: progress.solvedFor(book.id),
          totalPicarats: progress.picaratsFor(book.id),
        ));
      } catch (_) {
        emit(const BookError('No se pudo abrir el libro. Inténtalo de nuevo.'));
      }
    });

    on<GoToPageEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        if (event.pageIndex < 0 || event.pageIndex >= s.pages.length) return;
        if (!s.isPageUnlocked(event.pageIndex)) return;
        emit(s.copyWith(
          currentIndex: event.pageIndex,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<NextPageEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        if (!s.canGoNext) return;
        emit(s.copyWith(
          currentIndex: s.currentIndex + 1,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<PreviousPageEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        if (s.currentIndex == 0) return;
        emit(s.copyWith(
          currentIndex: s.currentIndex - 1,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });

    on<SubmitPageAnswerEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        final puzzle = s.currentPage.puzzle;
        final isCorrect = puzzle.checkAnswer(event.answer);
        if (isCorrect) {
          progress.markSolved(
            bookId: s.book.id,
            puzzleId: puzzle.id,
            picarats: puzzle.Picarats,
          );
          final updated = progress.solvedFor(s.book.id);
          emit(s.copyWith(
            solvedPuzzleIds: updated,
            totalPicarats: progress.picaratsFor(s.book.id),
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

    on<ResetBookEvent>((event, emit) {
      final s = state;
      if (s is BookLoaded) {
        progress.resetBook(s.book.id);
        emit(s.copyWith(
          currentIndex: 0,
          solvedPuzzleIds: <String>{},
          totalPicarats: 0,
          lastAnswerCorrect: () => null,
          failedAttemptsOnPage: 0,
        ));
      }
    });
  }
}
