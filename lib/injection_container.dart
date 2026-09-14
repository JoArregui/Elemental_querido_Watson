import 'package:get_it/get_it.dart';
import 'features/book/data/datasources/book_local_data_source.dart';
import 'features/book/data/repositories/book_progress_repository.dart';
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

  // Data sources
  sl.registerLazySingleton<PuzzleLocalDataSource>(
    () => PuzzleLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(classicPuzzles: sl()),
  );
}