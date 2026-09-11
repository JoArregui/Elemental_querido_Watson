import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/board_tile.dart';
import '../entities/game_board_state.dart';

class GenerateBoard implements UseCase<GameBoardState, NoParams> {
  @override
  Future<Either<Failure, GameBoardState>> call(NoParams params) async {
    try {
      final Random random = Random();
      final List<BoardTile> tiles = [];

      // Generar 30 casillas combinando los 40 puzles disponibles
      tiles.add(const BoardTile(
        index: 0,
        type: TileType.start,
        description: 'Salida',
      ));

      for (int i = 1; i < 30; i++) {
        // Asignar aleatoriamente uno de los 40 puzles (ID entre 001 y 040)
        final int puzzleNumber = random.nextInt(40) + 1;
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

      final initialState = GameBoardState(
        playerName: '',
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