import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/story_book.dart';
import '../bloc/book_bloc.dart';
import '../bloc/book_event.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import 'book_reader_page.dart';

/// Home: biblioteca con un libro por etapa.
/// Cada libro tiene su propia historia y sus propios acertijos.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  IconData _coverIcon(String key) {
    switch (key) {
      case 'clock':
        return Icons.schedule;
      case 'lighthouse':
        return Icons.sailing;
      case 'masks':
        return Icons.celebration;
      case 'observatory':
        return Icons.star;
      case 'train':
        return Icons.train;
      case 'abbey':
        return Icons.account_balance;
      default:
        return Icons.menu_book;
    }
  }

  void _openBook(BuildContext context, LibraryLoaded state, int index,
      {int initialPage = 0}) {
    final book = state.books[index];
    if (!state.isBookUnlocked(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'La etapa ${book.stage} se desbloquea al completar "${state.books[index - 1].title}".'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => di.sl<BookBloc>()
            ..add(LoadBookEvent(book.id, initialPage: initialPage)),
          child: BookReaderPage(
              bookId: book.id, initialPage: initialPage),
        ),
      ),
    ).then((_) {
      // Al volver, refresca el progreso de la estantería.
      // ignore: use_build_context_synchronously
      context.read<LibraryBloc>().add(const RefreshLibraryEvent());
    });
  }

  Future<void> _confirmNewGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF3CD),
        title: const Text('¿Empezar una nueva partida?'),
        content: const Text(
          'Se borrará todo el progreso guardado: acertijos resueltos, indicios y la última posición. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Borrar y empezar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<LibraryBloc>().add(const ResetAllProgressEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partida nueva: la biblioteca vuelve a empezar.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1009),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Elemental, querido Watson',
                style: TextStyle(color: Colors.amber, fontSize: 18)),
            Text('Biblioteca de casos · cada libro es una etapa',
                style: TextStyle(color: Colors.white54, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.amber),
            tooltip: 'Opciones de partida',
            color: const Color(0xFFFFF3CD),
            onSelected: (value) {
              if (value == 'new_game') _confirmNewGame(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'new_game',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Nueva partida'),
                  ],
                ),
              ),
            ],
          ),
          BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final total =
                  state is LibraryLoaded ? state.totalIndicios : 0;
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '⭐ $total',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryInitial || state is LibraryLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }
          if (state is LibraryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LibraryBloc>()
                        .add(const LoadLibraryEvent()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is! LibraryLoaded) return const SizedBox.shrink();

          return Column(
            children: [
              if (state.hasSave && state.resumeBook != null)
                _continueCard(context, state),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    final unlocked = state.isBookUnlocked(index);
                    final solved = state.solvedFor(book.id);
                    final completed =
                        state.completedBookIds.contains(book.id);
                    return _bookCard(context, state, index, book,
                        unlocked, solved, completed);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Retoma la partida guardada donde se dejó.
  Widget _continueCard(BuildContext context, LibraryLoaded state) {
    final book = state.resumeBook!;
    final page = (state.lastPageIndex + 1).clamp(1, book.pageCount);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.play_circle_fill, size: 28),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Continuar partida',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(
              '${book.title} · Pág. $page/${book.pageCount}',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onPressed: () {
          final index =
              state.books.indexWhere((b) => b.id == book.id);
          if (index < 0) return;
          _openBook(context, state, index,
              initialPage: state.lastPageIndex);
        },
      ),
    );
  }

  Widget _bookCard(
    BuildContext context,
    LibraryLoaded state,
    int index,
    StoryBook book,
    bool unlocked,
    int solved,
    bool completed,
  ) {
    final coverColor = Color(book.colorValue);
    final progress =
        book.pageCount == 0 ? 0.0 : solved / book.pageCount;

    return Opacity(
      opacity: unlocked ? 1.0 : 0.75,
      child: Card(
        color: const Color(0xFFFFF3CD),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: completed ? Colors.green.shade700 : Colors.amber,
              width: completed ? 2.5 : 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openBook(context, state, index),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Lomo / portada
              Container(
                width: 96,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: coverColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    bottomLeft: Radius.circular(11),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ETAPA ${book.stage}',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Icon(_coverIcon(book.coverKey),
                        size: 44, color: Colors.amber.shade200),
                    const SizedBox(height: 10),
                    Text(
                      '${book.pageCount} págs.',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Ficha del libro
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        book.subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.description,
                        style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black87,
                            height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.brown.shade100,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                                  completed
                                      ? Colors.green
                                      : Colors.amber.shade700),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              completed
                                  ? '✔ Completado · $solved/${book.pageCount}'
                                  : '$solved/${book.pageCount} acertijos',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: completed
                                      ? Colors.green.shade800
                                      : Colors.brown.shade700,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!unlocked)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.lock,
                                  size: 18, color: Colors.grey),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.brown),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
