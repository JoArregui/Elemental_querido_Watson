import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/book/data/datasources/book_local_data_source.dart';
import '../../features/book/data/repositories/book_progress_repository.dart';
import '../../features/book/data/repositories/daily_puzzle_repository.dart';
import 'postal_service.dart';

class SyncService {
  String _rankFor(int total, bool isEn) {
    if (total >= 1500) return 'Holmes';
    if (total >= 800) return 'Watson';
    if (total >= 300) return isEn ? 'Investigator' : 'Investigador';
    return isEn ? 'Apprentice' : 'Aprendiz';
  }

  String generatePostalText(BookProgressRepository progress, DailyPuzzleRepository daily, int streak, String locale) {
    final isEn = locale == 'en';
    final total = progress.totalexperiencia();
    final rewards = progress.rewardsUnlocked.length;
    final collectibles = progress.collectiblesCount;
    final secrets = progress.secretsCount;
    final rank = _rankFor(total, isEn);
    if (isEn) {
      return 'Elemental, my dear Watson — Case Postal\nRank: $rank · $total XP\nCollection: $collectibles/90 · Secrets: $secrets/18 · Rewards: $rewards/6\nStreak: $streak days 🔥\n${DateTime.now().toIso8601String().split('T').first}\n#ElementalWatson';
    }
    return 'Elemental, querido Watson — Postal del caso\nRango: $rank · $total XP\nColección: $collectibles/90 · Secretos: $secrets/18 · Recompensas: $rewards/6\nRacha: $streak días 🔥\n${DateTime.now().toIso8601String().split('T').first}\n#ElementalWatson';
  }

  /// Comparte la postal de verdad: anverso + reverso como imágenes + texto.
  /// Si falla el render, comparte al menos el texto como antes.
  Future<void> sharePostal(BookProgressRepository progress, DailyPuzzleRepository daily, String locale) async {
    final isEn = locale == 'en';
    final streak = await daily.getStreak();
    final text = generatePostalText(progress, daily, streak, locale);
    final subject =
        isEn ? 'My Watson case postal' : 'Mi postal del caso Watson';
    try {
      final books = await GetIt.I.get<BookLocalDataSource>().getLibrary();
      final book = progress.lastBookId == null
          ? books.first
          : books.firstWhere((b) => b.id == progress.lastBookId,
              orElse: () => books.first);
      final total = progress.totalexperiencia();
      final postal = PostalService();
      final front = await postal.renderFront(
        bookTitle: book.title,
        bookSubtitle: book.subtitle,
        bookStage: book.stage,
        bookColor: Color(book.colorValue),
        totalXp: total,
        rank: _rankFor(total, isEn),
        isEn: isEn,
      );
      final back = await postal.renderBack(
        rank: _rankFor(total, isEn),
        totalXp: total,
        bookTitle: book.title,
        bookStage: book.stage,
        solved: progress.solvedCount(book.id),
        pageCount: book.pageCount,
        bookXp: progress.experienciaFor(book.id),
        collectibles: progress.collectiblesCount,
        secrets: progress.secretsCount,
        blueStars: progress.blueStarsCount,
        rewards: progress.rewardsUnlocked.length,
        streak: streak,
        date: DateTime.now().toIso8601String().split('T').first,
        isEn: isEn,
      );
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(front,
              name: 'postal_anverso.png', mimeType: 'image/png'),
          XFile.fromData(back,
              name: 'postal_reverso.png', mimeType: 'image/png'),
        ],
        text: text,
        subject: subject,
      ));
    } catch (_) {
      await Share.share(text, subject: subject);
    }
  }

  Future<String> exportElemental() async {
    final prefs = await SharedPreferences.getInstance();
    final data = <String, dynamic>{};
    for (final k in prefs.getKeys()) {
      data[k] = prefs.get(k);
    }
    // meta
    data['_export_version'] = 1;
    data['_export_date'] = DateTime.now().toIso8601String();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/elemental_${DateTime.now().toIso8601String().split('T').first}.elemental.json');
    await file.writeAsString(jsonStr);
    if (kDebugMode) debugPrint('SyncService: exported ${file.path}');
    return file.path;
  }

  Future<void> shareExport() async {
    final path = await exportElemental();
    final file = XFile(path);
    await Share.shareXFiles([file], text: 'Mi partida Elemental, querido Watson — .elemental');
  }

}
