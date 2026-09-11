import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/board_tile.dart';
import '../../domain/usecases/generate_board.dart';
import 'board_event.dart';
import 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final GenerateBoard generateBoard;

  BoardBloc({required this.generateBoard}) : super(BoardWelcomeState()) {
    on<InitBoardEvent>((event, emit) async {
      emit(BoardLoading());
      final result = await generateBoard(
        GenerateBoardParams(playerName: event.playerName),
      );
      result.fold(
        (failure) => emit(const BoardError('Error al crear el tablero')),
        (boardState) => emit(
          BoardReady(
            boardState: boardState,
          ),
        ),
      );
    });

    on<RollDiceEvent>((event, emit) {
      if (state is BoardReady) {
        final current = (state as BoardReady).boardState;
        final maxIndex = current.tiles.length - 1;

        if (current.currentPosition >= maxIndex) {
          emit(BoardFinished(current));
          return;
        }

        final diceValue = Random().nextInt(6) + 1;
        int newPos = current.currentPosition + diceValue;

        if (newPos >= maxIndex) {
          newPos = maxIndex;
        }

        final targetTile = current.tiles[newPos];
        int updatedPicarats = current.totalPicarats;
        String? puzzleToTrigger;

        if (targetTile.type == TileType.bonus) {
          updatedPicarats += 10;
        } else if (targetTile.type == TileType.penalty) {
          updatedPicarats = max(0, updatedPicarats - 5);
        } else if (targetTile.type == TileType.puzzle) {
          if (!current.solvedPuzzleIds.contains(targetTile.puzzleId)) {
            puzzleToTrigger = targetTile.puzzleId;
          }
        }

        final updatedBoardState = current.copyWith(
          currentPosition: newPos,
          totalPicarats: updatedPicarats,
          lastDiceRoll: diceValue,
        );

        emit(BoardReady(
          boardState: updatedBoardState,
          triggerPuzzleId: puzzleToTrigger,
        ));
      }
    });

    on<PuzzleSolvedOnBoardEvent>((event, emit) {
      if (state is BoardReady) {
        final current = (state as BoardReady).boardState;
        final solvedList = List<String>.from(current.solvedPuzzleIds);
        if (!solvedList.contains(event.puzzleId)) {
          solvedList.add(event.puzzleId);
        }

        final updatedBoardState = current.copyWith(
          totalPicarats: current.totalPicarats + event.picaratsEarned,
          solvedPuzzleIds: solvedList,
        );

        final maxIndex = current.tiles.length - 1;
        if (current.currentPosition >= maxIndex) {
          emit(BoardFinished(updatedBoardState));
        } else {
          emit(BoardReady(boardState: updatedBoardState, triggerPuzzleId: null));
        }
      }
    });
  }
}