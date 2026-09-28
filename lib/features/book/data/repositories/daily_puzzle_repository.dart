import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../puzzle/data/datasources/puzzle_local_data_source.dart';

/// B piloto: Puzzle diario + racha. Sin backend, determinista por fecha.
class DailyPuzzleRepository {
  static const _dateKey = 'daily_date';
  static const _puzzleIdKey = 'daily_puzzle_id';
  static const _streakKey = 'daily_streak';
  static const _lastSolvedDateKey = 'daily_last_solved';
  static const _attemptsKey = 'daily_attempts';
  static const _attemptsDateKey = 'daily_attempts_date';
  static const maxDailyAttempts = 3;

  String? _todayId;
  String? _todayDate;

  Future<String> getTodayPuzzleId(PuzzleLocalDataSource ds) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final storedDate = prefs.getString(_dateKey);
    final storedId = prefs.getString(_puzzleIdKey);
    if (storedDate == today && storedId != null) {
      _todayDate = today;
      _todayId = storedId;
      return storedId;
    }
    // Determinista por fecha para que todos vean el mismo hoy
    final all = await ds.getAllPuzzles();
    final seed = today.hashCode;
    final idx = Random(seed).nextInt(all.length);
    final picked = all[idx].id;
    await prefs.setString(_dateKey, today);
    await prefs.setString(_puzzleIdKey, picked);
    // Nuevo día: reinicia los 3 intentos del reto diario.
    await prefs.setInt(_attemptsKey, 0);
    await prefs.setString(_attemptsDateKey, today);
    _todayDate = today;
    _todayId = picked;
    return picked;
  }

  /// Intentos fallidos de hoy (0..3). Se reinicia cada día.
  Future<int> getTodayAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    if (prefs.getString(_attemptsDateKey) != today) {
      await prefs.setInt(_attemptsKey, 0);
      await prefs.setString(_attemptsDateKey, today);
      return 0;
    }
    return prefs.getInt(_attemptsKey) ?? 0;
  }

  Future<int> getRemainingAttempts() async {
    final used = await getTodayAttempts();
    return (maxDailyAttempts - used).clamp(0, maxDailyAttempts);
  }

  /// Registra un fallo y devuelve los intentos restantes (0..2).
  Future<int> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    var used = prefs.getInt(_attemptsKey) ?? 0;
    if (prefs.getString(_attemptsDateKey) != today) used = 0;
    used = (used + 1).clamp(0, maxDailyAttempts);
    await prefs.setInt(_attemptsKey, used);
    await prefs.setString(_attemptsDateKey, today);
    return (maxDailyAttempts - used).clamp(0, maxDailyAttempts);
  }

  /// true si ya ha agotado los 3 intentos de hoy sin acertar.
  Future<bool> isTodayBlocked() async {
    if (await isTodaySolved()) return false;
    final used = await getTodayAttempts();
    return used >= maxDailyAttempts;
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<bool> isTodaySolved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSolvedDateKey) == _todayString();
  }

  Future<void> markTodaySolved() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final last = prefs.getString(_lastSolvedDateKey);
    if (last == today) return;
    final yesterday = _yesterdayString();
    int streak = prefs.getInt(_streakKey) ?? 0;
    if (last == yesterday) {
      streak += 1;
    } else if (last == null || last != today) {
      // si no es racha consecutiva, reinicia a 1 (o 0 si nunca)
      streak = last == null ? 1 : 1;
      // si hubo hueco >1 día, también 1
      if (last != null && last != yesterday) streak = 1;
    }
    await prefs.setInt(_streakKey, streak);
    await prefs.setString(_lastSolvedDateKey, today);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
  String _yesterdayString() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2,'0')}-${y.day.toString().padLeft(2,'0')}';
  }
}
