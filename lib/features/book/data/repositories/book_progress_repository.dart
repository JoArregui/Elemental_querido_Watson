/// Guarda en memoria el progreso del jugador en cada libro.
/// Sobrevive a la navegación entre la biblioteca y el lector.
class BookProgressRepository {
  final Map<String, Set<String>> _solvedByBook = {};
  final Map<String, int> _picaratsByBook = {};

  Set<String> solvedFor(String bookId) {
    return Set<String>.from(_solvedByBook[bookId] ?? const {});
  }

  int picaratsFor(String bookId) => _picaratsByBook[bookId] ?? 0;

  int totalPicarats() =>
      _picaratsByBook.values.fold(0, (a, b) => a + b);

  /// Devuelve true si el acertijo se resolvía por primera vez.
  bool markSolved({
    required String bookId,
    required String puzzleId,
    required int picarats,
  }) {
    final solved = _solvedByBook.putIfAbsent(bookId, () => <String>{});
    if (solved.contains(puzzleId)) return false;
    solved.add(puzzleId);
    _picaratsByBook[bookId] = picaratsFor(bookId) + picarats;
    return true;
  }

  bool isBookCompleted(String bookId, int pageCount) {
    return (_solvedByBook[bookId]?.length ?? 0) >= pageCount &&
        pageCount > 0;
  }

  int solvedCount(String bookId) => _solvedByBook[bookId]?.length ?? 0;

  void resetBook(String bookId) {
    _solvedByBook.remove(bookId);
    _picaratsByBook.remove(bookId);
  }
}
