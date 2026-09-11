import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/puzzle.dart';
import '../../domain/repositories/puzzle_repository.dart';
import '../datasources/puzzle_local_data_source.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  final PuzzleLocalDataSource localDataSource;

  PuzzleRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Puzzle>> getPuzzleById(String id) async {
    try {
      final puzzleModel = await localDataSource.getPuzzle(id);
      return Right(puzzleModel);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Puzzle>>> getAllPuzzles() async {
    try {
      final puzzles = await localDataSource.getAllPuzzles();
      return Right(puzzles);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> validateAnswer(String puzzleId, String answer) async {
    try {
      final puzzleModel = await localDataSource.getPuzzle(puzzleId);
      final isCorrect = puzzleModel.correctAnswer.trim().toLowerCase() == answer.trim().toLowerCase();
      return Right(isCorrect);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}