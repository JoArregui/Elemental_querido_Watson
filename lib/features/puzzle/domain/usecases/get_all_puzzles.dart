import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class GetAllPuzzles implements UseCase<List<Puzzle>, NoParams> {
  final PuzzleRepository repository;

  GetAllPuzzles(this.repository);

  @override
  Future<Either<Failure, List<Puzzle>>> call(NoParams params) async {
    return await repository.getAllPuzzles();
  }
}