import 'package:equatable/equatable.dart';
import 'board_tile.dart';

class GameBoardState extends Equatable {
  final String playerName;
  final List<BoardTile> tiles;
  final int currentPosition;
  final int totalPicarats;
  final int? lastDiceRoll;
  final List<String> solvedPuzzleIds;

  const GameBoardState({
    required this.playerName,
    required this.tiles,
    required this.currentPosition,
    required this.totalPicarats,
    this.lastDiceRoll,
    required this.solvedPuzzleIds,
  });

  GameBoardState copyWith({
    String? playerName,
    List<BoardTile>? tiles,
    int? currentPosition,
    int? totalPicarats,
    int? lastDiceRoll,
    List<String>? solvedPuzzleIds,
  }) {
    return GameBoardState(
      playerName: playerName ?? this.playerName,
      tiles: tiles ?? this.tiles,
      currentPosition: currentPosition ?? this.currentPosition,
      totalPicarats: totalPicarats ?? this.totalPicarats,
      lastDiceRoll: lastDiceRoll ?? this.lastDiceRoll,
      solvedPuzzleIds: solvedPuzzleIds ?? this.solvedPuzzleIds,
    );
  }

  @override
  List<Object?> get props => [
        playerName,
        tiles,
        currentPosition,
        totalPicarats,
        lastDiceRoll,
        solvedPuzzleIds,
      ];
}