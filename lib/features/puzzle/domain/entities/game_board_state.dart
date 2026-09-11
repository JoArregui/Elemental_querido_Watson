import 'package:equatable/equatable.dart';
import 'board_tile.dart';

class GameBoardState extends Equatable {
  final int currentPosition;
  final int totalPicarats;
  final List<BoardTile> tiles;
  final List<String> solvedPuzzleIds;
  final int? lastDiceRoll;

  const GameBoardState({
    required this.currentPosition,
    required this.totalPicarats,
    required this.tiles,
    required this.solvedPuzzleIds,
    this.lastDiceRoll,
  });

  GameBoardState copyWith({
    int? currentPosition,
    int? totalPicarats,
    List<BoardTile>? tiles,
    List<String>? solvedPuzzleIds,
    int? lastDiceRoll,
  }) {
    return GameBoardState(
      currentPosition: currentPosition ?? this.currentPosition,
      totalPicarats: totalPicarats ?? this.totalPicarats,
      tiles: tiles ?? this.tiles,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
      lastDiceRoll: lastDiceRoll ?? this.lastDiceRoll,
    );
  }

  @override
  List<Object?> get props => [
        currentPosition,
        totalPicarats,
        tiles,
        solvedPuzzleIds,
        lastDiceRoll,
      ];
}