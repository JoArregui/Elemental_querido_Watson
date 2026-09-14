import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object?> get props => [];
}

class LoadLibraryEvent extends LibraryEvent {
  const LoadLibraryEvent();
}

class RefreshLibraryEvent extends LibraryEvent {
  const RefreshLibraryEvent();
}

class ResetAllProgressEvent extends LibraryEvent {
  const ResetAllProgressEvent();
}
