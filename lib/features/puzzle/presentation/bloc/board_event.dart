import 'package:equatable/equatable.dart';

abstract class BoardEvent extends Equatable {
  const BoardEvent();

  @override
  List<Object?> get props => [];
}

class InitBoardEvent extends BoardEvent {
  final String playerName;

  const InitBoardEvent(this.playerName);

  @override
  List<Object?> get props => [playerName];
}

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