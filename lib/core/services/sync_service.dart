import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/book/data/repositories/book_progress_repository.dart';
import '../../features/book/data/repositories/daily_puzzle_repository.dart';

class SyncService {
  String generatePostalText(BookProgressRepository progress, DailyPuzzleRepository daily, int streak, String locale) {
    final isEn = locale == 'en';
    final total = progress.totalexperiencia();
    final rewards = progress.rewardsUnlocked.length;
    final collectibles = progress.collectiblesCount;
    final secrets = progress.secretsCount;
    final rank = total >= 1500 ? 'Holmes' : total >= 800 ? 'Watson' : total >= 300 ? 'Investigador' : 'Aprendiz';
    if (isEn) {
      return 'Elemental, my dear Watson — Case Postal\nRank: $rank · $total XP\nCollection: $collectibles/90 · Secrets: $secrets/18 · Rewards: $rewards/6\nStreak: $streak days 🔥\n${DateTime.now().toIso8601String().split('T').first}\n#ElementalWatson';
    }
    return 'Elemental, querido Watson — Postal del caso\nRango: $rank · $total XP\nColección: $collectibles/90 · Secretos: $secrets/18 · Recompensas: $rewards/6\nRacha: $streak días 🔥\n${DateTime.now().toIso8601String().split('T').first}\n#ElementalWatson';
  }

  Future<void> sharePostal(BookProgressRepository progress, DailyPuzzleRepository daily, String locale) async {
    final streak = await daily.getStreak();
    final text = generatePostalText(progress, daily, streak, locale);
    await Share.share(text, subject: locale == 'en' ? 'My Watson case postal' : 'Mi postal del caso Watson');
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
