import 'package:equatable/equatable.dart';

class Puzzle extends Equatable {
  final String id;
  final String title;
  final String statement;
  final int Picarats;
  final String correctAnswer;
  final String hintText;

  const Puzzle({
    required this.id,
    required this.title,
    required this.statement,
    required this.Picarats,
    required this.correctAnswer,
    required this.hintText,
  });

  @override
  List<Object?> get props => [id, title, statement, Picarats, correctAnswer, hintText];
}