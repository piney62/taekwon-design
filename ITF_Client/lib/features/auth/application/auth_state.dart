class AuthState {
  const AuthState({
    this.isLoading = true,
    this.isLoggedIn = false,
    this.username = '',
    this.displayName = '',
    this.role = 'student',
    this.dojoConnected = false,
    this.instructorName = '',
    this.homeworkText = '',
    this.joinedAt,
    this.dojoName = '',
    this.danRank = '',
    this.dojoPlan = 'free',
    this.studentPlan = 'free',
    this.trainingStartYear,
    this.avatarUrl = '',
  });

  final bool isLoading;
  final bool isLoggedIn;
  final String username;
  final String displayName;
  final String role; // 'student' | 'instructor'
  final bool dojoConnected;
  final String instructorName;
  final String homeworkText;
  final DateTime? joinedAt;
  // instructor fields
  final String dojoName;
  final String danRank;
  final String dojoPlan;
  // student fields
  final String studentPlan;
  final int? trainingStartYear;
  final String avatarUrl;

  bool get isRegistered => isLoggedIn;
  bool get isInstructor => role == 'instructor';

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? username,
    String? displayName,
    String? role,
    bool? dojoConnected,
    String? instructorName,
    String? homeworkText,
    DateTime? joinedAt,
    String? dojoName,
    String? danRank,
    String? dojoPlan,
    String? studentPlan,
    int? trainingStartYear,
    String? avatarUrl,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        dojoConnected: dojoConnected ?? this.dojoConnected,
        instructorName: instructorName ?? this.instructorName,
        homeworkText: homeworkText ?? this.homeworkText,
        joinedAt: joinedAt ?? this.joinedAt,
        dojoName: dojoName ?? this.dojoName,
        danRank: danRank ?? this.danRank,
        dojoPlan: dojoPlan ?? this.dojoPlan,
        studentPlan: studentPlan ?? this.studentPlan,
        trainingStartYear: trainingStartYear ?? this.trainingStartYear,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}
