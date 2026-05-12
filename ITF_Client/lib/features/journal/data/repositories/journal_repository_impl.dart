import '../../../../core/network/backend_client.dart';
import '../../domain/entities/training_session.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/repositories/journal_repository.dart';

class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl(this._client);

  final BackendClient _client;

  @override
  Future<List<TrainingSession>> loadAll() async {
    final data = await _client.getSessions();
    return data.map(_fromServer).toList();
  }

  @override
  Future<void> add(TrainingSession session) async {
    await _client.addSession({
      'session_date': _dateOnly(session.date),
      'duration_minutes': session.durationMinutes,
      'training_type': session.type.name,
      'score': session.score,
      'notes': session.notes,
      'is_auto_saved': false,
      'instructor_comment': '',
      'pattern_name': session.patternName,
      'selected_movements': session.selectedMovements.join(','),
    });
  }

  @override
  Future<void> update(TrainingSession session) async {
    await _client.updateSession(int.parse(session.id), {
      'session_date': _dateOnly(session.date),
      'duration_minutes': session.durationMinutes,
      'training_type': session.type.name,
      'score': session.score,
      'notes': session.notes,
      'pattern_name': session.patternName,
      'selected_movements': session.selectedMovements.join(','),
    });
  }

  @override
  Future<void> delete(String id) async {
    await _client.deleteSession(int.parse(id));
  }

  TrainingSession _fromServer(Map<String, dynamic> json) {
    final movStr = json['selected_movements'] as String? ?? '';
    final movements = movStr.isEmpty
        ? <int>[]
        : movStr.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
    return TrainingSession(
      id: json['id'].toString(),
      date: DateTime.parse(json['session_date'] as String),
      durationMinutes: json['duration_minutes'] as int,
      type: TrainingType.values.firstWhere(
        (t) => t.name == json['training_type'],
        orElse: () => TrainingType.other,
      ),
      score: json['score'] as int,
      notes: json['notes'] as String? ?? '',
      isAutoSaved: json['is_auto_saved'] as bool? ?? false,
      instructorComment: json['instructor_comment'] as String? ?? '',
      patternName: json['pattern_name'] as String? ?? '',
      selectedMovements: movements,
    );
  }

  String _dateOnly(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
