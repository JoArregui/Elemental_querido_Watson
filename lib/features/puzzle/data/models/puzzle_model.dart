import '../../domain/entities/puzzle.dart';

class PuzzleModel extends Puzzle {
  const PuzzleModel({
    required super.id,
    required super.title,
    required super.statement,
    required super.Picarats,
    required super.correctAnswer,
    required super.hintText,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    return PuzzleModel(
      id: json['id'],
      title: json['title'],
      statement: json['statement'],
      Picarats: json['picarats'],
      correctAnswer: json['correctAnswer'],
      hintText: json['hintText'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'statement': statement,
      'picarats': Picarats,
      'correctAnswer': correctAnswer,
      'hintText': hintText,
    };
  }
}