import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/board_tile.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import 'puzzle_page.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        title: const Text('Tablero del Profesor Layton', style: TextStyle(color: Colors.amber)),
        backgroundColor: const Color(0xFF1A1009),
      ),
      body: BlocConsumer<BoardBloc, BoardState>(
        listener: (context, state) {
          if (state is BoardReady && state.triggerPuzzleId != null) {
            final puzzleId = state.triggerPuzzleId!;
            
            // Cargar puzle en PuzzleBloc y navegar
            context.read<PuzzleBloc>().add(LoadPuzzleEvent(puzzleId));
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<PuzzleBloc>(),
                  child: const PuzzlePage(),
                ),
              ),
            ).then((_) {
              // Limpiar disparador al volver
              context.read<BoardBloc>().add(PuzzleSolvedOnBoardEvent(
                puzzleId: puzzleId,
                picaratsEarned: 0,
              ));
            });
          }
        },
        builder: (context, state) {
          if (state is BoardLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is BoardReady) {
            final board = state.boardState;

            return Column(
              children: [
                // Marcador superior
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1A1009),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Picarats totales: ${board.totalPicarats}',
                        style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Posición: ${board.currentPosition + 1} / ${board.tiles.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Cuadrícula del Tablero
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: board.tiles.length,
                    itemBuilder: (context, index) {
                      final tile = board.tiles[index];
                      final bool isPlayerHere = board.currentPosition == index;

                      Color tileColor = const Color(0xFFFFF3CD);
                      if (tile.type == TileType.start) tileColor = Colors.lightBlue.shade100;
                      if (tile.type == TileType.bonus) tileColor = Colors.green.shade200;
                      if (tile.type == TileType.penalty) tileColor = Colors.red.shade200;

                      return Container(
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPlayerHere ? Colors.orangeAccent : Colors.amber,
                            width: isPlayerHere ? 3 : 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '#${tile.index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Icon(
                                  _getTileIcon(tile.type),
                                  size: 18,
                                  color: Colors.brown,
                                ),
                              ],
                            ),
                            if (isPlayerHere)
                              const Positioned(
                                top: 2,
                                right: 2,
                                child: Icon(Icons.person, color: Colors.deepOrange, size: 20),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Área inferior de lanzamiento de dado
                Container(
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF1A1009),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (board.lastDiceRoll != null)
                        Text(
                          'Último dado: 🎲 ${board.lastDiceRoll}',
                          style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.casino),
                        label: const Text('Lanzar Dado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          context.read<BoardBloc>().add(RollDiceEvent());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is BoardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getTileIcon(TileType type) {
    switch (type) {
      case TileType.start:
        return Icons.flag;
      case TileType.bonus:
        return Icons.add_circle;
      case TileType.penalty:
        return Icons.remove_circle;
      case TileType.puzzle:
        return Icons.extension;
    }
  }
}