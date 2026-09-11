import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_all_puzzles.dart';
import '../../domain/usecases/get_puzzle.dart';
import 'puzzle_event.dart';
import 'puzzle_state.dart';

class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  final GetPuzzle getPuzzle;
  final GetAllPuzzles getAllPuzzles;

  PuzzleBloc({
    required this.getPuzzle,
    required this.getAllPuzzles,
  }) : super(PuzzleInitial()) {
    on<LoadPuzzleListEvent>((event, emit) async {
      emit(PuzzleLoading());
      final result = await getAllPuzzles(NoParams());
      result.fold(
        (failure) => emit(const PuzzleError('Error al cargar la lista de puzles')),
        (puzzles) => emit(PuzzleListLoaded(puzzles)),
      );
    });

    on<LoadPuzzleEvent>((event, emit) async {
      emit(PuzzleLoading());
      final result = await getPuzzle(GetPuzzleParams(id: event.id));
      result.fold(
        (failure) => emit(const PuzzleError('Error al cargar el puzle')),
        (puzzle) => emit(PuzzleLoaded(puzzle)),
      );
    });

    on<SubmitAnswerEvent>((event, emit) async {
      if (state is PuzzleLoaded || state is PuzzleAnswerResult) {
        final currentPuzzle = (state as dynamic).puzzle;
        final isCorrect = currentPuzzle.correctAnswer.trim().toLowerCase() == event.answer.trim().toLowerCase();
        emit(PuzzleAnswerResult(isCorrect: isCorrect, puzzle: currentPuzzle));
      }
    });
  }
}