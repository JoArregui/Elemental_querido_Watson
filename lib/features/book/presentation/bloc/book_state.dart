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
  final int totalexperiencia;
  final bool? lastAnswerCorrect;
  final int failedAttemptsOnPage;
  final Set<String> branchedPuzzleIds;
  final bool lastWasAlternative;

  const BookLoaded({
    required this.book,
    required this.pages,
    required this.currentIndex,
    required this.solvedPuzzleIds,
    required this.totalexperiencia,
    this.lastAnswerCorrect,
    this.failedAttemptsOnPage = 0,
    this.branchedPuzzleIds = const {},
    this.lastWasAlternative = false,
  });

  BookPage get currentPage => pages[currentIndex];
  bool get isCurrentSolved => solvedPuzzleIds.contains(currentPage.puzzle.id);
  int get solvedCount => solvedPuzzleIds.length;
  double get progress => pages.isEmpty ? 0 : solvedCount / pages.length;

  /// Navegación libre: todas las páginas están accesibles para lectura.
  /// La recompensa (experiencia) solo se gana si se resuelve el acertijo,
  /// pero nunca se bloquea el avance de la historia.
  bool isPageUnlocked(int index) {
    if (index < 0 || index >= pages.length) return false;
    return true;
  }

  /// Se puede avanzar siempre que no sea la última página.
  /// Resolver da experiencia; saltar deja esos experiencia sin ganar.
  bool get canGoNext => currentIndex < pages.length - 1;

  /// Solo hay recompensa si la página actual está resuelta.
  bool get canGoNextWithReward => canGoNext && isCurrentSolved;

  bool get canGoPrevious => currentIndex > 0;
  bool get isLastPage => pages.isNotEmpty && currentIndex == pages.length - 1;
  bool get isFirstPage => currentIndex == 0;

  /// Puntuación máxima si todo se resolviera.
  int get maxPossibleexperiencia =>
      pages.fold(0, (sum, p) => sum + p.puzzle.experiencia);

  int get missedexperiencia => maxPossibleexperiencia - totalexperiencia;

  // A3: bloqueo tras 3 fallos
  bool get isBlockedByAttempts => failedAttemptsOnPage >= 3;
  bool get canAttempt => !isCurrentSolved && !isBlockedByAttempts;

  /// Libro completamente resuelto al 100% (todos los experiencia conseguidos).
  bool get isFullyCompleted =>
      pages.isNotEmpty && solvedPuzzleIds.length == pages.length;

  // C2: finales ramificados por % XP
  double get completionRate => maxPossibleexperiencia == 0 ? 0 : totalexperiencia / maxPossibleexperiencia;
  String get endingTier {
    if (isFullyCompleted) return 'perfect';
    if (completionRate >= 0.7) return 'good';
    if (completionRate >= 0.4) return 'half';
    return 'low';
  }

  /// Compatibilidad: ahora distingue entre lectura completa y 100% aciertos.
  /// Para el flujo de celebración final usamos isFullyCompleted, pero
  /// cualquier lector puede terminar la historia con puntuación parcial.
  bool get isBookCompleted => isFullyCompleted;

  BookLoaded copyWith({
    StoryBook? book,
    List<BookPage>? pages,
    int? currentIndex,
    Set<String>? solvedPuzzleIds,
    int? totalexperiencia,
    bool? Function()? lastAnswerCorrect,
    int? failedAttemptsOnPage,
    Set<String>? branchedPuzzleIds,
    bool? lastWasAlternative,
  }) {
    return BookLoaded(
      book: book ?? this.book,
      pages: pages ?? this.pages,
      currentIndex: currentIndex ?? this.currentIndex,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
      totalexperiencia: totalexperiencia ?? this.totalexperiencia,
      lastAnswerCorrect:
          lastAnswerCorrect != null ? lastAnswerCorrect() : this.lastAnswerCorrect,
      failedAttemptsOnPage: failedAttemptsOnPage ?? this.failedAttemptsOnPage,
      branchedPuzzleIds: branchedPuzzleIds ?? this.branchedPuzzleIds,
      lastWasAlternative: lastWasAlternative ?? this.lastWasAlternative,
    );
  }

  @override
  List<Object?> get props => [
        book,
        pages,
        currentIndex,
        solvedPuzzleIds,
        totalexperiencia,
        lastAnswerCorrect,
        failedAttemptsOnPage,
        branchedPuzzleIds,
        lastWasAlternative,
      ];
}

class BookError extends BookState {
  final String message;
  const BookError(this.message);
  @override
  List<Object?> get props => [message];
}
