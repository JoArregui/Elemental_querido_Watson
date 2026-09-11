import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class GetPuzzle implements UseCase<Puzzle, GetPuzzleParams> {
  final PuzzleRepository repository;

  GetPuzzle(this.repository);

  @override
  Future<Either<Failure, Puzzle>> call(GetPuzzleParams params) async {
    return await repository.getPuzzleById(params.id);
  }
}

class GetPuzzleParams extends Equatable {
  final String id;
  const GetPuzzleParams({required this.id});

  @override
  List<Object?> get props => [id];
}