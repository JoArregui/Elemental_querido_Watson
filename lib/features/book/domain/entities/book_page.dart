import 'package:equatable/equatable.dart';
import '../../../puzzle/domain/entities/puzzle.dart';

/// Una página del libro: historia + 1 acertijo al final.
class BookPage extends Equatable {
  final int pageNumber;
  final String chapterTitle;
  final String chapterLabel;
  final String storyTitle;
  final String storyText;
  final Puzzle puzzle;
  final String? collectibleId;
  final String? watsonNote; // diario manuscrito 2 variantes por rama

  const BookPage({
    required this.pageNumber,
    required this.chapterTitle,
    required this.chapterLabel,
    required this.storyTitle,
    required this.storyText,
    required this.puzzle,
    this.collectibleId,
    this.watsonNote,
  });

  BookPage copyWith({Puzzle? puzzle, String? storyText, String? storyTitle, String? watsonNote}) {
    return BookPage(
      pageNumber: pageNumber,
      chapterTitle: chapterTitle,
      chapterLabel: chapterLabel,
      storyTitle: storyTitle ?? this.storyTitle,
      storyText: storyText ?? this.storyText,
      puzzle: puzzle ?? this.puzzle,
      collectibleId: collectibleId,
      watsonNote: watsonNote ?? this.watsonNote,
    );
  }

  @override
  List<Object?> get props =>
      [pageNumber, chapterTitle, chapterLabel, storyTitle, storyText, puzzle, collectibleId];
}
