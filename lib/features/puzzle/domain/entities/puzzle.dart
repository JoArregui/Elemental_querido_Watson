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
  final int experiencia;
  final String correctAnswer;
  final String hintText;
  final List<String> hints;
  final PuzzleType type;
  final List<String> options;
  final String? visualKind;
  final String? visualPayload;

  const Puzzle({
    required this.id,
    required this.title,
    required this.statement,
    required this.experiencia,
    required this.correctAnswer,
    required this.hintText,
    this.hints = const [],
    this.type = PuzzleType.textInput,
    this.options = const [],
    this.visualKind,
    this.visualPayload,
  });

  /// Pistas progresivas: si `hints` está poblado se usa, si no fallback a `hintText` (compat FASE 1).
  List<String> get allHints => hints.isNotEmpty ? hints : [hintText];
  String hintForLevel(int level) {
    final list = allHints;
    if (list.isEmpty) return hintText;
    return list[level.clamp(0, list.length - 1)];
  }

  bool get isVisual => type == PuzzleType.visualChoice || visualKind != null;
  bool get hasOptions => options.isNotEmpty;

  // A2: dificultad derivada de XP para curva adaptativa
  String get difficulty {
    if (experiencia >= 40) return 'hard';
    if (experiencia >= 25) return 'medium';
    return 'easy';
  }

  // B: rango detective derivado del total global se calcula fuera

  /// Normaliza respuestas para comparar (minúsculas, sin espacios extra).
  bool checkAnswer(String answer) {
    return correctAnswer.trim().toLowerCase() ==
        answer.trim().toLowerCase();
  }

  @override
  List<Object?> get props =>
      [id, title, statement, experiencia, correctAnswer, hintText, hints, type, options, visualKind, visualPayload];
}