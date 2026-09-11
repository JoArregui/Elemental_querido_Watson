import 'package:equatable/equatable.dart';
import '../../domain/entities/puzzle.dart';

abstract class PuzzleState extends Equatable {
  const PuzzleState();

  @override
  List<Object?> get props => [];
}

class PuzzleInitial extends PuzzleState {}
class PuzzleLoading extends PuzzleState {}

class PuzzleListLoaded extends PuzzleState {
  final List<Puzzle> puzzles;
  const PuzzleListLoaded(this.puzzles);

  @override
  List<Object?> get props => [puzzles];
}

class PuzzleLoaded extends PuzzleState {
  final Puzzle puzzle;
  const PuzzleLoaded(this.puzzle);

  @override
  List<Object?> get props => [puzzle];
}

class PuzzleAnswerResult extends PuzzleState {
  final bool isCorrect;
  final Puzzle puzzle;
  const PuzzleAnswerResult({required this.isCorrect, required this.puzzle});

  @override
  List<Object?> get props => [isCorrect, puzzle];
}

class PuzzleError extends PuzzleState {
  final String message;
  const PuzzleError(this.message);

  @override
  List<Object?> get props => [message];
}