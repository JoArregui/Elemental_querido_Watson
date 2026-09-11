import 'package:equatable/equatable.dart';
import '../../domain/entities/game_board_state.dart';

abstract class BoardState extends Equatable {
  const BoardState();

  @override
  List<Object?> get props => [];
}

class BoardWelcomeState extends BoardState {}

class BoardLoading extends BoardState {}

class BoardReady extends BoardState {
  final GameBoardState boardState;
  final String? triggerPuzzleId;

  const BoardReady({
    required this.boardState,
    this.triggerPuzzleId,
  });

  @override
  List<Object?> get props => [boardState, triggerPuzzleId];
}

class BoardFinished extends BoardState {
  final GameBoardState boardState;

  const BoardFinished(this.boardState);

  @override
  List<Object?> get props => [boardState];
}

class BoardError extends BoardState {
  final String message;

  const BoardError(this.message);

  @override
  List<Object?> get props => [message];
}