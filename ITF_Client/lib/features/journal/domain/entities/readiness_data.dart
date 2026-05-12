class ReadinessData {
  const ReadinessData({
    this.sparringCheck = false,
    this.breakingCheck = false,
    this.theoryTestPassed = false,
  });

  final bool sparringCheck;
  final bool breakingCheck;
  final bool theoryTestPassed;

  ReadinessData copyWith({
    bool? sparringCheck,
    bool? breakingCheck,
    bool? theoryTestPassed,
  }) =>
      ReadinessData(
        sparringCheck: sparringCheck ?? this.sparringCheck,
        breakingCheck: breakingCheck ?? this.breakingCheck,
        theoryTestPassed: theoryTestPassed ?? this.theoryTestPassed,
      );

  factory ReadinessData.fromJson(Map<String, dynamic> json) => ReadinessData(
        sparringCheck: json['sparring_check'] as bool? ?? false,
        breakingCheck: json['breaking_check'] as bool? ?? false,
        theoryTestPassed: json['theory_test_passed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'sparring_check': sparringCheck,
        'breaking_check': breakingCheck,
        'theory_test_passed': theoryTestPassed,
      };
}
