import 'package:equatable/equatable.dart';

abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object?> get props => [];
}

class LoadPuzzleListEvent extends PuzzleEvent {}

class LoadPuzzleEvent extends PuzzleEvent {
  final String id;
  const LoadPuzzleEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SubmitAnswerEvent extends PuzzleEvent {
  final String puzzleId;
  final String answer;
  const SubmitAnswerEvent({required this.puzzleId, required this.answer});

  @override
  List<Object?> get props => [puzzleId, answer];
}