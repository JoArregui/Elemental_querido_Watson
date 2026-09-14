import 'package:equatable/equatable.dart';
import '../../domain/entities/story_book.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  final List<StoryBook> books;
  final Map<String, int> solvedCounts;
  final Set<String> completedBookIds;
  final Map<String, int> indiciosPerBook;
  final int totalIndicios;
  final String? lastBookId;
  final int lastPageIndex;
  final bool hasSave;

  const LibraryLoaded({
    required this.books,
    required this.solvedCounts,
    required this.completedBookIds,
    required this.indiciosPerBook,
    required this.totalIndicios,
    required this.lastBookId,
    required this.lastPageIndex,
    required this.hasSave,
  });

  int solvedFor(String bookId) => solvedCounts[bookId] ?? 0;

  /// Libro donde continuar la partida (si existe y sigue desbloqueado).
  StoryBook? get resumeBook {
    if (lastBookId == null) return null;
    for (final b in books) {
      if (b.id == lastBookId) return b;
    }
    return null;
  }

  /// La etapa 1 siempre está abierta; el resto exige completar la anterior.
  bool isBookUnlocked(int index) {
    if (index <= 0) return true;
    if (index >= books.length) return false;
    return completedBookIds.contains(books[index - 1].id);
  }

  @override
  List<Object?> get props => [
        books,
        solvedCounts,
        completedBookIds,
        indiciosPerBook,
        totalIndicios,
        lastBookId,
        lastPageIndex,
        hasSave,
      ];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);
  @override
  List<Object?> get props => [message];
}
