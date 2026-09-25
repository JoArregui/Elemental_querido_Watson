import 'package:get_it/get_it.dart';
import 'features/book/data/datasources/book_local_data_source.dart';
import 'features/book/data/repositories/book_progress_repository.dart';
import 'features/book/data/repositories/daily_puzzle_repository.dart';
import 'core/services/accessibility_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/feedback_service.dart';
import 'core/services/locale_service.dart';
import 'core/services/reading_mode_service.dart';
import 'core/services/sync_service.dart';
import 'features/book/data/services/tts_service.dart';
import 'features/book/presentation/bloc/book_bloc.dart';
import 'features/book/presentation/bloc/library_bloc.dart';
import 'features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'features/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'features/puzzle/domain/repositories/puzzle_repository.dart';
import 'features/puzzle/domain/usecases/get_all_puzzles.dart';
import 'features/puzzle/domain/usecases/get_puzzle.dart';
import 'features/puzzle/presentation/bloc/puzzle_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => PuzzleBloc(
        getPuzzle: sl(),
        getAllPuzzles: sl(),
      ));

  sl.registerFactory(() => BookBloc(
        dataSource: sl(),
        progress: sl(),
      ));

  sl.registerFactory(() => LibraryBloc(
        dataSource: sl(),
        progress: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetPuzzle(sl()));
  sl.registerLazySingleton(() => GetAllPuzzles(sl()));

  // Repository
  sl.registerLazySingleton<PuzzleRepository>(
    () => PuzzleRepositoryImpl(localDataSource: sl()),
  );

  // Progreso persistente entre biblioteca y lector.
  // Se inicializa (carga la partida guardada) antes de registrarlo.
  final progressRepo = BookProgressRepository();
  await progressRepo.init();
  sl.registerSingleton<BookProgressRepository>(progressRepo);

  // Voz para el modo audiolibro (se inicializa al primer uso).
  sl.registerLazySingleton(() => TtsService());
  sl.registerLazySingleton(() => FeedbackService());
  sl.registerLazySingleton(() => AudioService());
  sl.registerLazySingleton(() => DailyPuzzleRepository());
  sl.registerLazySingleton(() => SyncService());
  final localeService = LocaleService();
  await localeService.init();
  sl.registerSingleton<LocaleService>(localeService);
  final a11y = AccessibilityService();
  await a11y.init();
  sl.registerSingleton<AccessibilityService>(a11y);
  final readingMode = ReadingModeService();
  await readingMode.init();
  sl.registerSingleton<ReadingModeService>(readingMode);

  // Data sources
  sl.registerLazySingleton<PuzzleLocalDataSource>(
    () => PuzzleLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(classicPuzzles: sl()),
  );
}