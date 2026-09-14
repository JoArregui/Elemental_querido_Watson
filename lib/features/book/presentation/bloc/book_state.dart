import 'package:equatable/equatable.dart';
import '../../domain/entities/book_page.dart';
import '../../domain/entities/story_book.dart';

abstract class BookState extends Equatable {
  const BookState();
  @override
  List<Object?> get props => [];
}

class BookInitial extends BookState {
  const BookInitial();
}

class BookLoading extends BookState {
  const BookLoading();
}

class BookLoaded extends BookState {
  final StoryBook book;
  final List<BookPage> pages;
  final int currentIndex;
  final Set<String> solvedPuzzleIds;
  final int totalIndicios;
  final bool? lastAnswerCorrect;
  final int failedAttemptsOnPage;

  const BookLoaded({
    required this.book,
    required this.pages,
    required this.currentIndex,
    required this.solvedPuzzleIds,
    required this.totalIndicios,
    this.lastAnswerCorrect,
    this.failedAttemptsOnPage = 0,
  });

  BookPage get currentPage => pages[currentIndex];
  bool get isCurrentSolved => solvedPuzzleIds.contains(currentPage.puzzle.id);
  int get solvedCount => solvedPuzzleIds.length;
  double get progress => pages.isEmpty ? 0 : solvedCount / pages.length;

  /// Página desbloqueada si es la primera o la anterior está resuelta.
  bool isPageUnlocked(int index) {
    if (index == 0) return true;
    if (index < 0 || index >= pages.length) return false;
    return solvedPuzzleIds.contains(pages[index - 1].puzzle.id);
  }

  bool get canGoNext =>
      currentIndex < pages.length - 1 && isCurrentSolved;

  bool get isBookCompleted =>
      pages.isNotEmpty && solvedPuzzleIds.length == pages.length;

  BookLoaded copyWith({
    StoryBook? book,
    List<BookPage>? pages,
    int? currentIndex,
    Set<String>? solvedPuzzleIds,
    int? totalIndicios,
    bool? Function()? lastAnswerCorrect,
    int? failedAttemptsOnPage,
  }) {
    return BookLoaded(
      book: book ?? this.book,
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
      totalIndicios: totalIndicios ?? this.totalIndicios,
      lastAnswerCorrect:
          lastAnswerCorrect != null ? lastAnswerCorrect() : this.lastAnswerCorrect,
      failedAttemptsOnPage:
          failedAttemptsOnPage ?? this.failedAttemptsOnPage,
    );
  }

  @override
  List<Object?> get props => [
        book,
        pages,
        currentIndex,
        solvedPuzzleIds,
        totalIndicios,
        lastAnswerCorrect,
        failedAttemptsOnPage,
      ];
}

class BookError extends BookState {
  final String message;
  const BookError(this.message);
  @override
  List<Object?> get props => [message];
}
