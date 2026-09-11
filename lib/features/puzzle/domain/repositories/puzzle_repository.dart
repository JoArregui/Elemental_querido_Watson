import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/puzzle.dart';

abstract class PuzzleRepository {
  Future<Either<Failure, Puzzle>> getPuzzleById(String id);
  Future<Either<Failure, List<Puzzle>>> getAllPuzzles();
  Future<Either<Failure, bool>> validateAnswer(String puzzleId, String answer);
}