import 'package:equatable/equatable.dart';

enum PuzzleType {
  textInput,
  multipleChoice,
  visualChoice,
}

class Puzzle extends Equatable {
  final String id;
  final String title;
  final String statement;
  final int Picarats;
  final String correctAnswer;
  final String hintText;
  final PuzzleType type;
  final List<String> options;
  final String? visualKind;
  final String? visualPayload;

  const Puzzle({
    required this.id,
    required this.title,
    required this.statement,
    required this.Picarats,
    required this.correctAnswer,
    required this.hintText,
    this.type = PuzzleType.textInput,
    this.options = const [],
    this.visualKind,
    this.visualPayload,
  });

  bool get isVisual => type == PuzzleType.visualChoice || visualKind != null;
  bool get hasOptions => options.isNotEmpty;

  /// Normaliza respuestas para comparar (minúsculas, sin espacios extra).
  bool checkAnswer(String answer) {
    return correctAnswer.trim().toLowerCase() ==
        answer.trim().toLowerCase();
  }

  @override
  List<Object?> get props =>
      [id, title, statement, Picarats, correctAnswer, hintText, type, options, visualKind, visualPayload];
}