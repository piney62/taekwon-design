import '../entities/training_session.dart';

abstract class JournalRepository {
  Future<List<TrainingSession>> loadAll();

  Future<void> add(TrainingSession session);

  Future<void> update(TrainingSession session);

  Future<void> delete(String id);
}
