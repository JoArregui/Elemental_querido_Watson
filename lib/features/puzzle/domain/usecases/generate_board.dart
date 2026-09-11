import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/board_tile.dart';
import '../entities/game_board_state.dart';

class GenerateBoardParams extends Equatable {
  final String playerName;

  const GenerateBoardParams({this.playerName = 'Profesor'});

  @override
  List<Object?> get props => [playerName];
}

class GenerateBoard implements UseCase<GameBoardState, GenerateBoardParams> {
  @override
  Future<Either<Failure, GameBoardState>> call(GenerateBoardParams params) async {
    try {
      final Random random = Random();
      final List<BoardTile> tiles = [];

      // Casilla inicial de Salida
      tiles.add(const BoardTile(
        index: 0,
        type: TileType.start,
        description: 'Salida',
      ));

      // Mantenemos el tablero de 30 casillas
      for (int i = 1; i < 30; i++) {
        // Seleccionamos un puzle aleatorio del repertorio de 100 puzles disponibles (001 al 100)
        final int puzzleNumber = random.nextInt(100) + 1;
        final String puzzleId = puzzleNumber.toString().padLeft(3, '0');

        if (i % 7 == 0) {
          tiles.add(BoardTile(
            index: i,
            type: TileType.bonus,
            description: '+10 Picarats extra',
          ));
        } else if (i % 5 == 0) {
          tiles.add(BoardTile(
            index: i,
            type: TileType.penalty,
            description: '-5 Picarats',
          ));
        } else {
          tiles.add(BoardTile(
            index: i,
            type: TileType.puzzle,
            puzzleId: puzzleId,
            description: 'Puzle #$puzzleId',
          ));
        }
      }

      final String name = params.playerName.trim().isEmpty ? 'Profesor' : params.playerName.trim();

      final initialState = GameBoardState(
        playerName: name,
        currentPosition: 0,
        totalPicarats: 0,
        tiles: tiles,
        solvedPuzzleIds: const [],
      );

      return Right(initialState);
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}