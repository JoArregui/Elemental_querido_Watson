import 'package:equatable/equatable.dart';

enum TileType { puzzle, start, bonus, penalty }

class BoardTile extends Equatable {
  final int index;
  final TileType type;
  final String? puzzleId;
  final String description;

  const BoardTile({
    required this.index,
    required this.type,
    this.puzzleId,
    required this.description,
  });

  @override
  List<Object?> get props => [index, type, puzzleId, description];
}