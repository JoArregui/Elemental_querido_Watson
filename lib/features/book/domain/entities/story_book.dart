import 'package:equatable/equatable.dart';
import 'book_page.dart';

/// Un libro de la biblioteca = una etapa del juego.
/// Cada libro tiene su propia historia y sus propios acertijos.
class StoryBook extends Equatable {
  final String id;
  final int stage; // 1, 2, 3...
  final String title;
  final String subtitle;
  final String description;
  final String coverKey; // 'clock', 'lighthouse', 'masks', 'observatory'
  final int colorValue; // Color de la portada
  final List<BookPage> pages;

  const StoryBook({
    required this.id,
    required this.stage,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.coverKey,
    required this.colorValue,
    required this.pages,
  });

  int get pageCount => pages.length;

  int get totalexperiencia =>
      pages.fold(0, (sum, p) => sum + p.puzzle.experiencia);

  @override
  List<Object?> get props =>
      [id, stage, title, subtitle, description, coverKey, colorValue, pages];
}
