import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/board_bloc.dart';
import '../bloc/board_event.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_event.dart';
import '../bloc/puzzle_state.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final TextEditingController _answerController = TextEditingController();
  bool _hasAutomatedReturn = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _returnToBoard({required String puzzleId, required int picaratsEarned}) {
    if (!mounted) return;
    context.read<BoardBloc>().add(
          PuzzleSolvedOnBoardEvent(
            puzzleId: puzzleId,
            picaratsEarned: picaratsEarned,
          ),
        );
    Navigator.of(context).pop();
  }

  void _scheduleAutomaticReturn({required String puzzleId, required int picaratsEarned}) {
    if (_hasAutomatedReturn) return;
    _hasAutomatedReturn = true;

    // Espera 2.5 segundos para mostrar el mensaje de resultado antes de regresar
    Future.delayed(const Duration(milliseconds: 2500), () {
      _returnToBoard(puzzleId: puzzleId, picaratsEarned: picaratsEarned);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        title: const Text('Profesor Layton - Acertijo', style: TextStyle(color: Colors.amber)),
        backgroundColor: const Color(0xFF1A1009),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<PuzzleBloc, PuzzleState>(
        builder: (context, state) {
          if (state is PuzzleLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is PuzzleLoaded || state is PuzzleAnswerResult) {
            final puzzle = (state as dynamic).puzzle;
            final bool? isCorrect = state is PuzzleAnswerResult ? (state as PuzzleAnswerResult).isCorrect : null;

            if (isCorrect != null) {
              _scheduleAutomaticReturn(
                puzzleId: puzzle.id,
                picaratsEarned: isCorrect ? puzzle.Picarats : 0,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          puzzle.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Picarats: ${puzzle.Picarats}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.brown),
                        ),
                        const Divider(color: Colors.amber),
                        Text(
                          puzzle.statement,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isCorrect == null) ...[
                    TextField(
                      controller: _answerController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Introduce tu respuesta',
                        labelStyle: TextStyle(color: Colors.amber),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        context.read<PuzzleBloc>().add(
                              SubmitAnswerEvent(
                                puzzleId: puzzle.id,
                                answer: _answerController.text,
                              ),
                            );
                      },
                      child: const Text('Responder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  if (isCorrect != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isCorrect
                                ? '¡Correcto! Has ganado ${puzzle.Picarats} Picarats.'
                                : 'Respuesta incorrecta. No has conseguido Picarats.',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Regresando al tablero...',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is PuzzleError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          return const Center(child: Text('Cargando puzle...', style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }
}