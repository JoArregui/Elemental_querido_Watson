import 'package:equatable/equatable.dart';
import '../../../puzzle/domain/entities/puzzle.dart';

/// Una página del libro: historia + 1 acertijo al final.
class BookPage extends Equatable {
  final int pageNumber; // 1..30
  final String chapterTitle;
  final String chapterLabel; // Ej: "Capítulo 1"
  final String storyTitle;
  final String storyText;
  final Puzzle puzzle;

  const BookPage({
    required this.pageNumber,
    required this.chapterTitle,
    required this.chapterLabel,
    required this.storyTitle,
    required this.storyText,
    required this.puzzle,
  });

  @override
  List<Object?> get props =>
      [pageNumber, chapterTitle, chapterLabel, storyTitle, storyText, puzzle];
}
