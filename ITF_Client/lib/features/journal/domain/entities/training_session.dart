import 'training_type.dart';

class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.type,
    required this.score,
    this.notes = '',
    this.isAutoSaved = false,
    this.instructorComment = '',
    this.patternName = '',
    this.selectedMovements = const [],
  });

  final String id;
  final DateTime date;
  final int durationMinutes;
  final TrainingType type;
  final int score; // 1–5
  final String notes;
  final bool isAutoSaved;
  final String instructorComment;
  final String patternName;
  final List<int> selectedMovements;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'type': type.name,
        'score': score,
        'notes': notes,
        'isAutoSaved': isAutoSaved,
        'instructorComment': instructorComment,
        'patternName': patternName,
      };

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      TrainingSession(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['durationMinutes'] as int,
        type: TrainingType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => TrainingType.other,
        ),
        score: json['score'] as int,
        notes: json['notes'] as String? ?? '',
        isAutoSaved: json['isAutoSaved'] as bool? ?? false,
        instructorComment: json['instructorComment'] as String? ?? '',
        patternName: json['patternName'] as String? ?? '',
        selectedMovements: _parseMovements(json['selectedMovements'] as String? ?? ''),
      );

  static List<int> _parseMovements(String s) {
    if (s.isEmpty) return [];
    return s.split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();
  }

  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
