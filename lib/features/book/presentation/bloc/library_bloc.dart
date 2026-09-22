import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/book_local_data_source.dart';
import '../../data/repositories/book_progress_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

/// Biblioteca: lista de libros-etapa con su progreso y bloqueos.
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final BookLocalDataSource dataSource;
  final BookProgressRepository progress;

  LibraryBloc({required this.dataSource, required this.progress})
      : super(const LibraryInitial()) {
    on<LoadLibraryEvent>((event, emit) async {
      emit(const LibraryLoading());
      await _load(emit);
    });
    on<RefreshLibraryEvent>((event, emit) async {
      await _load(emit);
    });
    on<ResetAllProgressEvent>((event, emit) async {
      await progress.resetAll();
      await _load(emit);
    });
  }

  Future<void> _load(Emitter<LibraryState> emit) async {
    try {
      final books = await dataSource.getLibrary();
      final solvedCounts = <String, int>{};
      final completed = <String>{};
      final experiencia = <String, int>{};
      for (final b in books) {
        solvedCounts[b.id] = progress.solvedCount(b.id);
        experiencia[b.id] = progress.experienciaFor(b.id);
        if (progress.isBookCompleted(b.id, b.pageCount)) {
          completed.add(b.id);
        }
      }
      emit(LibraryLoaded(
        books: books,
        solvedCounts: solvedCounts,
        completedBookIds: completed,
        experienciaPerBook: experiencia,
        totalexperiencia: progress.totalexperiencia(),
        lastBookId: progress.lastBookId,
        lastPageIndex: progress.lastPageIndex,
        hasSave: progress.hasSave,
      ));
    } catch (_) {
      emit(const LibraryError('No se pudo abrir la biblioteca.'));
    }
  }
}
