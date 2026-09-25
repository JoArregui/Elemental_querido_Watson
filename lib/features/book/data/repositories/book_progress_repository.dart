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
  final Set<String> _collectibles = {};
  final Set<String> _secrets = {}; // 101-112 ramificados + 113-118 deducciones = 18
  // Estrellas azules: 1 por libro al resolver su Acertijo Final (113-118).
  // No dan XP: son la recompensa del acertijo final.
  final Set<String> _blueStars = {}; // bookIds con estrella azul
  final Map<String, String> _branchChoices = {}; // pageId -> 'main'|'alt'
  final Map<String, int> _timePerPuzzle = {}; // puzzleId -> seconds
  // D1: telemetría UX
  final Map<String, int> _attemptsPerPuzzle = {}; // puzzleId -> intentos totales
  final Map<String, int> _successPerPuzzle = {}; // puzzleId -> aciertos
  final Map<String, int> _hintsPerPuzzle = {}; // puzzleId -> pistas usadas acumuladas
  int _totalSessions = 0;
  String? _lastBookId;
  int _lastPageIndex = 0;
  bool _ready = false;

  /// Recarga la partida desde el dispositivo (tras importar un .elemental).
  Future<void> reload() async {
    _solvedByBook.clear();
    _experienciaByBook.clear();
    _collectibles.clear();
    _secrets.clear();
    _blueStars.clear();
    _branchChoices.clear();
    _timePerPuzzle.clear();
    _attemptsPerPuzzle.clear();
    _successPerPuzzle.clear();
    _hintsPerPuzzle.clear();
    _totalSessions = 0;
    _lastBookId = null;
    _lastPageIndex = 0;
    _ready = false;
    await init();
  }

  /// Carga la partida guardada (si existe). Llamar una vez al arrancar.
  Future<void> init() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    _lastBookId = prefs.getString(_lastBookKey);
    _lastPageIndex = prefs.getInt(_lastPageKey) ?? 0;
    _collectibles.addAll(prefs.getStringList('collectibles') ?? const []);
    _secrets.addAll(prefs.getStringList('secrets_solved') ?? const []);
    _blueStars.addAll(prefs.getStringList('blue_stars') ?? const []);
    final branchRaw = prefs.getStringList('branchChoices') ?? const [];
    for (final e in branchRaw) { final p = e.split('='); if (p.length==2) _branchChoices[p[0]]=p[1]; }
    final timeRaw = prefs.getStringList('timePerPuzzle') ?? const [];
    for (final e in timeRaw) { final p = e.split('='); if (p.length==2) _timePerPuzzle[p[0]]=int.tryParse(p[1]) ?? 0; }
    // D1
    for (final e in prefs.getStringList('stats_attempts') ?? const []) { final p = e.split('='); if (p.length==2) _attemptsPerPuzzle[p[0]] = int.tryParse(p[1]) ?? 0; }
    for (final e in prefs.getStringList('stats_success') ?? const []) { final p = e.split('='); if (p.length==2) _successPerPuzzle[p[0]] = int.tryParse(p[1]) ?? 0; }
    for (final e in prefs.getStringList('stats_hints') ?? const []) { final p = e.split('='); if (p.length==2) _hintsPerPuzzle[p[0]] = int.tryParse(p[1]) ?? 0; }
    _totalSessions = prefs.getInt('stats_sessions') ?? 0;
    if (_totalSessions == 0 && hasSave) _totalSessions = 1;

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
  Set<String> get collectibles => Set.unmodifiable(_collectibles);
  int get collectiblesCount => _collectibles.length;
  Set<String> get secrets => Set.unmodifiable(_secrets);
  int get secretsCount => _secrets.length;
  // Estrellas azules (acertijo final, sin XP)
  Set<String> get blueStars => Set.unmodifiable(_blueStars);
  int get blueStarsCount => _blueStars.length;
  bool hasBlueStar(String bookId) => _blueStars.contains(bookId);
  // todos los puzzles resueltos (para contar 101-118 si se guardan por libro)
  Set<String> get allSolvedIds => _solvedByBook.values.expand((s) => s).toSet()..addAll(_secrets);
  // recompensas: 1 por libro completado (6 max) + marco dorado Holmes
  Set<String> get rewardsUnlocked {
    final r = <String>{};
    for (final e in _solvedByBook.entries) {
      // pageCounts conocidas: nebelheim 30, lighthouse 10, carnival 10, observatory 10, train 15, abbey 15
      const counts = {'nebelheim':30,'lighthouse':10,'carnival':10,'observatory':10,'train':15,'abbey':15};
      final needed = counts[e.key];
      if (needed != null && e.value.length >= needed) r.add(e.key);
    }
    return r;
  }
  bool get isHolmesRank => totalexperiencia() >= 1500;
  Map<String, String> get branchChoices => Map.unmodifiable(_branchChoices);
  Map<String, int> get timePerPuzzle => Map.unmodifiable(_timePerPuzzle);
  Map<String, int> get attemptsPerPuzzle => Map.unmodifiable(_attemptsPerPuzzle);
  Map<String, int> get successPerPuzzle => Map.unmodifiable(_successPerPuzzle);
  Map<String, int> get hintsPerPuzzle => Map.unmodifiable(_hintsPerPuzzle);
  int get totalSessions => _totalSessions;
  // D1: agregados
  int get totalAttempts => _attemptsPerPuzzle.values.fold(0, (a, b) => a + b);
  int get totalSuccesses => _successPerPuzzle.values.fold(0, (a, b) => a + b);
  double get successRate => totalAttempts == 0 ? 0 : totalSuccesses / totalAttempts;
  double get avgTimePerPuzzle {
    if (_timePerPuzzle.isEmpty) return 0;
    final vals = _timePerPuzzle.values.where((v) => v > 0).toList();
    if (vals.isEmpty) return 0;
    return vals.reduce((a, b) => a + b) / vals.length;
  }
  int get totalTimeSeconds => _timePerPuzzle.values.fold(0, (a, b) => a + b);
  double get avgHintsPerPuzzle {
    if (_hintsPerPuzzle.isEmpty) return 0;
    final total = _hintsPerPuzzle.values.fold(0, (a, b) => a + b);
    final count = _hintsPerPuzzle.length;
    return count == 0 ? 0 : total / count;
  }
  String get mostPlayedBookId {
    if (_solvedByBook.isEmpty) return 'nebelheim';
    String best = _solvedByBook.keys.first;
    int maxTime = 0;
    for (final e in _solvedByBook.entries) {
      int t = 0;
      for (final pid in e.value) { t += _timePerPuzzle[pid] ?? 0; }
      // peso por cantidad resuelta + tiempo
      final score = e.value.length * 100 + t;
      if (score > maxTime) { maxTime = score; best = e.key; }
    }
    return best;
  }
  int get totalSolvedPuzzles => _solvedByBook.values.fold(0, (a, b) => a + b.length) + _secrets.length;

  Future<void> recordBranch(String pageId, String choice) async {
    _branchChoices[pageId] = choice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('branchChoices', _branchChoices.entries.map((e) => '${e.key}=${e.value}').toList());
  }

  Future<void> recordTime(String puzzleId, int seconds) async {
    _timePerPuzzle[puzzleId] = seconds;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('timePerPuzzle', _timePerPuzzle.entries.map((e) => '${e.key}=${e.value}').toList());
  }

  // D1: telemetría por intento
  Future<void> recordAttempt({required String puzzleId, required bool success, int hintsUsed = 0, int seconds = 0}) async {
    _attemptsPerPuzzle[puzzleId] = (_attemptsPerPuzzle[puzzleId] ?? 0) + 1;
    if (success) _successPerPuzzle[puzzleId] = (_successPerPuzzle[puzzleId] ?? 0) + 1;
    _hintsPerPuzzle[puzzleId] = (_hintsPerPuzzle[puzzleId] ?? 0) + hintsUsed;
    if (seconds > 0) {
      // promedio incremental
      final prev = _timePerPuzzle[puzzleId] ?? 0;
      _timePerPuzzle[puzzleId] = prev == 0 ? seconds : ((prev + seconds) ~/ 2);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('stats_attempts', _attemptsPerPuzzle.entries.map((e) => '${e.key}=${e.value}').toList());
    await prefs.setStringList('stats_success', _successPerPuzzle.entries.map((e) => '${e.key}=${e.value}').toList());
    await prefs.setStringList('stats_hints', _hintsPerPuzzle.entries.map((e) => '${e.key}=${e.value}').toList());
    await prefs.setStringList('timePerPuzzle', _timePerPuzzle.entries.map((e) => '${e.key}=${e.value}').toList());
  }

  Future<void> incrementSessions() async {
    _totalSessions++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stats_sessions', _totalSessions);
  }

  /// Otorga la estrella azul de un libro (recompensa del Acertijo Final).
  /// Devuelve true si se conseguía por primera vez.
  Future<bool> markBlueStar(String bookId) async {
    if (_blueStars.contains(bookId)) return false;
    _blueStars.add(bookId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blue_stars', _blueStars.toList());
    return true;
  }

  Future<bool> markSecretSolved({required String puzzleId, required int experiencia}) async {
    if (_secrets.contains(puzzleId)) return false;
    // también registrar en solved global para allSolvedIds
    _secrets.add(puzzleId);
    // XP suma al total (usamos libro ficticio 'secrets' para no distorsionar progreso por libro)
    _experienciaByBook['secrets'] = (_experienciaByBook['secrets'] ?? 0) + experiencia;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('secrets_solved', _secrets.toList());
    await prefs.setInt('progress_picarats_secrets', _experienciaByBook['secrets']!);
    return true;
  }

  // ── Escrituras (persisten en el dispositivo) ──

  /// Devuelve true si el acertijo se resolvía por primera vez.
  Future<bool> markSolved({
    required String bookId,
    required String puzzleId,
    required int experiencia,
    String? collectibleId,
  }) async {
    final solved = _solvedByBook.putIfAbsent(bookId, () => <String>{});
    if (solved.contains(puzzleId)) return false;
    solved.add(puzzleId);
    _experienciaByBook[bookId] = experienciaFor(bookId) + experiencia;
    if (collectibleId != null) _collectibles.add(collectibleId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        '$_solvedPrefix$bookId', solved.toList());
    await prefs.setInt(
        '$_experienciaPrefix$bookId', _experienciaByBook[bookId]!);
    if (collectibleId != null) await prefs.setStringList('collectibles', _collectibles.toList());
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
    _blueStars.remove(bookId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_solvedPrefix$bookId');
    await prefs.remove('$_experienciaPrefix$bookId');
    await prefs.setStringList('blue_stars', _blueStars.toList());
  }

  /// Nueva partida: borra todo el progreso y la última posición.
  Future<void> resetAll() async {
    _solvedByBook.clear();
    _experienciaByBook.clear();
    _collectibles.clear();
    _secrets.clear();
    _blueStars.clear();
    _branchChoices.clear();
    _timePerPuzzle.clear();
    _lastBookId = null;
    _lastPageIndex = 0;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(_solvedPrefix) ||
          key.startsWith(_experienciaPrefix) ||
          key == _lastBookKey ||
          key == _lastPageKey ||
           key == 'collectibles' ||
           key == 'secrets_solved' ||
           key == 'blue_stars' ||
           key == 'branchChoices' ||
          key == 'timePerPuzzle') {
        await prefs.remove(key);
      }
    }
  }
}
