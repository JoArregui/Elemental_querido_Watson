import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookEvent extends BookEvent {
  final String bookId;
  final int initialPage;
  const LoadBookEvent(this.bookId, {this.initialPage = 0});

  @override
  List<Object?> get props => [bookId, initialPage];
}

class GoToPageEvent extends BookEvent {
  final int pageIndex;
  const GoToPageEvent(this.pageIndex);
  @override
  List<Object?> get props => [pageIndex];
}

class NextPageEvent extends BookEvent {
  const NextPageEvent();
}

class PreviousPageEvent extends BookEvent {
  const PreviousPageEvent();
}

class SubmitPageAnswerEvent extends BookEvent {
  final String answer;
  final int hintsUsed; // A1: 0..3, penaliza -5 por pista
  final bool timedBonus; // A2: bonus +30% si resuelve rápido
  final int elapsedSeconds; // D1: tiempo real en la página, alimenta "tiempo medio"
  const SubmitPageAnswerEvent(this.answer, {this.hintsUsed = 0, this.timedBonus = false, this.elapsedSeconds = 0});
  @override
  List<Object?> get props => [answer, hintsUsed, timedBonus, elapsedSeconds];
}

class ClearPageResultEvent extends BookEvent {
  const ClearPageResultEvent();
}

class ResetBookEvent extends BookEvent {
  const ResetBookEvent();
}
