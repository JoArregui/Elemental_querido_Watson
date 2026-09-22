import '../../domain/entities/puzzle.dart';

class PuzzleModel extends Puzzle {
  const PuzzleModel({
    required super.id,
    required super.title,
    required super.statement,
    required super.experiencia,
    required super.correctAnswer,
    required super.hintText,
    super.hints = const [],
    super.type = PuzzleType.textInput,
    super.options = const [],
    super.visualKind,
    super.visualPayload,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    // Compat: si existe `hints` (lista) se usa, si no fallback a hintText único
    final rawHints = json['hints'];
    final List<String> hints = rawHints is List
        ? List<String>.from(rawHints)
        : (json['hintText'] != null ? [json['hintText'] as String] : const <String>[]);
    return PuzzleModel(
      id: json['id'],
      title: json['title'],
      statement: json['statement'],
      experiencia: json['experiencia'],
      correctAnswer: json['correctAnswer'],
      hintText: json['hintText'] ?? (hints.isNotEmpty ? hints.first : ''),
      hints: hints,
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
      'experiencia': experiencia,
      'correctAnswer': correctAnswer,
      'hintText': hintText,
      'hints': hints.isNotEmpty ? hints : [hintText],
      'type': type.name,
      'options': options,
      'visualKind': visualKind,
      'visualPayload': visualPayload,
    };
  }
}