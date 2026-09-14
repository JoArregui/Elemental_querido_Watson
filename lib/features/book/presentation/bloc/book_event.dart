import 'package:equatable/equatable.dart';

abstract class BookEvent extends Equatable {
  const BookEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookEvent extends BookEvent {
  final String bookId;
  const LoadBookEvent(this.bookId);

  @override
  List<Object?> get props => [bookId];
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
  const SubmitPageAnswerEvent(this.answer);
  @override
  List<Object?> get props => [answer];
}

class ClearPageResultEvent extends BookEvent {
  const ClearPageResultEvent();
}

class ResetBookEvent extends BookEvent {
  const ResetBookEvent();
}
