import 'package:shared_preferences/shared_preferences.dart';

/// Progreso del jugador persistido en el dispositivo.
/// Permite guardar la partida, retomarla en otro momento
/// o empezar una nueva desde cero.
class BookProgressRepository {
  static const _solvedPrefix = 'progress_solved_';
  static const _experienciaPrefix = 'progress_picarats_';
  static const _lastBookKey = 'progress_last_book';
  static const _lastPageKey = 'progress_last_page';

  final Map<String, Set<String>> _solvedByBook = {};
  final Map<String, int> _experienciaByBook = {};
  String? _lastBookId;
  int _lastPageIndex = 0;
  bool _ready = false;

  /// Carga la partida guardada (si existe). Llamar una vez al arrancar.
  Future<void> init() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _lastBookId = prefs.getString(_lastBookKey);
    _lastPageIndex = prefs.getInt(_lastPageKey) ?? 0;

    for (final key in prefs.getKeys()) {
      if (key.startsWith(_solvedPrefix)) {
        final bookId = key.substring(_solvedPrefix.length);
        _solvedByBook[bookId] =
            Set<String>.from(prefs.getStringList(key) ?? const []);
      } else if (key.startsWith(_experienciaPrefix)) {
        final bookId = key.substring(_experienciaPrefix.length);
        _experienciaByBook[bookId] = prefs.getInt(key) ?? 0;
      }
    }
    _ready = true;
  }

  // ── Lecturas (síncronas, desde memoria) ──

  Set<String> solvedFor(String bookId) {
    return Set<String>.from(_solvedByBook[bookId] ?? const {});
  }

  int experienciaFor(String bookId) => _experienciaByBook[bookId] ?? 0;

  int totalexperiencia() =>
      _experienciaByBook.values.fold(0, (a, b) => a + b);

  bool isBookCompleted(String bookId, int pageCount) {
    return (_solvedByBook[bookId]?.length ?? 0) >= pageCount &&
        pageCount > 0;
  }

  int solvedCount(String bookId) => _solvedByBook[bookId]?.length ?? 0;

  /// ¿Hay alguna partida empezada (con al menos un acertijo resuelto)?
  bool get hasSave =>
      _solvedByBook.values.any((s) => s.isNotEmpty);

  String? get lastBookId => _lastBookId;
  int get lastPageIndex => _lastPageIndex;

  // ── Escrituras (persisten en el dispositivo) ──

  /// Devuelve true si el acertijo se resolvía por primera vez.
  Future<bool> markSolved({
    required String bookId,
    required String puzzleId,
    required int experiencia,
  }) async {
    final solved = _solvedByBook.putIfAbsent(bookId, () => <String>{});
    if (solved.contains(puzzleId)) return false;
    solved.add(puzzleId);
    _experienciaByBook[bookId] = experienciaFor(bookId) + experiencia;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        '$_solvedPrefix$bookId', solved.toList());
    await prefs.setInt(
        '$_experienciaPrefix$bookId', _experienciaByBook[bookId]!);
    return true;
  }

  /// Recuerda dónde estaba el jugador para poder retomarlo.
  Future<void> saveLastPosition({
    required String bookId,
    required int pageIndex,
  }) async {
    _lastBookId = bookId;
    _lastPageIndex = pageIndex;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBookKey, bookId);
    await prefs.setInt(_lastPageKey, pageIndex);
  }

  Future<void> resetBook(String bookId) async {
    _solvedByBook.remove(bookId);
    _experienciaByBook.remove(bookId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_solvedPrefix$bookId');
    await prefs.remove('$_experienciaPrefix$bookId');
  }

  /// Nueva partida: borra todo el progreso y la última posición.
  Future<void> resetAll() async {
    _solvedByBook.clear();
    _experienciaByBook.clear();
    _lastBookId = null;
    _lastPageIndex = 0;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_solvedPrefix) ||
          key.startsWith(_experienciaPrefix) ||
          key == _lastBookKey ||
          key == _lastPageKey) {
        await prefs.remove(key);
      }
    }
  }
}
