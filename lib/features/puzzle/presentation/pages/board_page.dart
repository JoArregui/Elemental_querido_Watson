import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/board_tile.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/board_state.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import 'puzzle_page.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
              context.read<BoardBloc>().add(PuzzleSolvedOnBoardEvent(
                    puzzleId: puzzleId,
                    picaratsEarned: 0,
                  ));
            });
          }
        },
        builder: (context, state) {
          if (state is BoardWelcomeState) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_pin, size: 64, color: Colors.brown),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Bienvenido al Desafío!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Introduce tu nombre para registrar tu puntuación final de Picarats.',
                        style: TextStyle(fontSize: 14, color: Colors.brown),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Jugador',
                          labelStyle: TextStyle(color: Colors.brown),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Comenzar Aventura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final name = _nameController.text.trim();
                          context.read<BoardBloc>().add(InitBoardEvent(name));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is BoardLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is BoardFinished) {
            final board = state.boardState;
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text(
                        '¡Enhorabuena, ${board.playerName}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Has completado el tablero con un total de:',
                        style: TextStyle(fontSize: 15, color: Colors.brown),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade800, width: 2),
                        ),
                        child: Text(
                          '${board.totalPicarats} Picarats',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Nueva Partida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _nameController.clear();
                          context.read<BoardBloc>().add(const InitBoardEvent(''));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (state is BoardReady) {
            final board = state.boardState;
            final isAtEnd = board.currentPosition >= board.tiles.length - 1;

            return Column(
              children: [
                // Marcador superior
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1A1009),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              board.playerName,
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Picarats: ${board.totalPicarats}',
                              style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF1A1009),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (board.lastDiceRoll != null)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Último dado: 🎲 ${board.lastDiceRoll}',
                              style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAtEnd ? Colors.grey : Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.casino),
                        label: Text(
                          isAtEnd ? 'Fin del Recorrido' : 'Lanzar Dado',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: isAtEnd
                            ? null
                            : () {
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