import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';
import 'puzzle_page.dart';

class PuzzleListPage extends StatelessWidget {
  const PuzzleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        title: const Text('Índice de Puzles', style: TextStyle(color: Colors.amber)),
        backgroundColor: const Color(0xFF1A1009),
      ),
      body: BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) {
          if (state is PuzzleLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is PuzzleListLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.puzzles.length,
              itemBuilder: (context, index) {
                final puzzle = state.puzzles[index];
                return Card(
                  color: const Color(0xFFFFF3CD),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.amber, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Text(
                        puzzle.id,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      puzzle.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Text('Valor: ${puzzle.Picarats} Picarats'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.brown),
                    onTap: () {
                      context.read<PuzzleBloc>().add(LoadPuzzleEvent(puzzle.id));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<PuzzleBloc>(),
                            child: const PuzzlePage(),
                          ),
                        ),
                      ).then((_) {
                        context.read<PuzzleBloc>().add(LoadPuzzleListEvent());
                      });
                    },
                  ),
                );
              },
            );
          } else if (state is PuzzleError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}