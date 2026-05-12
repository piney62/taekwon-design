class WeaknessPattern {
  const WeaknessPattern({
    required this.id,
    required this.movementName,
    required this.consecutiveCount,
    required this.detectedAt,
  });

  final int id;
  final String movementName;
  final int consecutiveCount;
  final DateTime detectedAt;

  factory WeaknessPattern.fromJson(Map<String, dynamic> json) =>
      WeaknessPattern(
        id: json['id'] as int,
        movementName: json['movement_name'] as String,
        consecutiveCount: json['consecutive_count'] as int,
        detectedAt: DateTime.parse(json['detected_at'] as String),
      );
}
