import 'package:equatable/equatable.dart';

abstract class BoardEvent extends Equatable {
  const BoardEvent();

  @override
  List<Object?> get props => [];
}

class InitBoardEvent extends BoardEvent {}

class RollDiceEvent extends BoardEvent {}

class PuzzleSolvedOnBoardEvent extends BoardEvent {
  final String puzzleId;
  final int picaratsEarned;

  const PuzzleSolvedOnBoardEvent({
    required this.puzzleId,
    required this.picaratsEarned,
  });

  @override
  List<Object?> get props => [puzzleId, picaratsEarned];
}