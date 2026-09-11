import 'package:get_it/get_it.dart';
import 'features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'features/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'features/puzzle/domain/repositories/puzzle_repository.dart';
import 'features/puzzle/domain/usecases/generate_board.dart';
import 'features/puzzle/domain/usecases/get_all_puzzles.dart';
import 'features/puzzle/domain/usecases/get_puzzle.dart';
import 'features/puzzle/presentation/bloc/board_bloc.dart';
import 'features/puzzle/presentation/bloc/puzzle_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => PuzzleBloc(
        getPuzzle: sl(),
        getAllPuzzles: sl(),
      ));

  sl.registerFactory(() => BoardBloc(
        generateBoard: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetPuzzle(sl()));
  sl.registerLazySingleton(() => GetAllPuzzles(sl()));
  sl.registerLazySingleton(() => GenerateBoard());

  // Repository
  sl.registerLazySingleton<PuzzleRepository>(
    () => PuzzleRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PuzzleLocalDataSource>(
    () => PuzzleLocalDataSourceImpl(),
  );
}