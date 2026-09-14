import '../../domain/entities/puzzle.dart';

class PuzzleModel extends Puzzle {
  const PuzzleModel({
    required super.id,
    required super.title,
    required super.statement,
    required super.Picarats,
    required super.correctAnswer,
    required super.hintText,
    super.type = PuzzleType.textInput,
    super.options = const [],
    super.visualKind,
    super.visualPayload,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    return PuzzleModel(
      id: json['id'],
      title: json['title'],
      statement: json['statement'],
      Picarats: json['picarats'],
      correctAnswer: json['correctAnswer'],
      hintText: json['hintText'],
      type: PuzzleType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'textInput'),
        orElse: () => PuzzleType.textInput,
      ),
      options: List<String>.from(json['options'] ?? const []),
      visualKind: json['visualKind'],
      visualPayload: json['visualPayload'],
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
      'type': type.name,
      'options': options,
      'visualKind': visualKind,
      'visualPayload': visualPayload,
    };
  }
}