import '../domain/entities/training_session.dart';

class JournalState {
  const JournalState({
    this.sessions = const [],
    this.isLoading = false,
  });

  final List<TrainingSession> sessions;
  final bool isLoading;

  JournalState copyWith({
    List<TrainingSession>? sessions,
    bool? isLoading,
  }) =>
      JournalState(
        sessions: sessions ?? this.sessions,
        isLoading: isLoading ?? this.isLoading,
      );
}
