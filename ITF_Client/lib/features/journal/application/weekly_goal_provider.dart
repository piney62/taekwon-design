import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/preferences_service.dart';
import '../domain/entities/training_session.dart';
import 'providers.dart';

const _kWeeklyGoal = 'pref.weekly_goal';
const _kFocusPattern = 'pref.focus_pattern';

class WeeklyGoalData {
  const WeeklyGoalData({this.target = 3, this.focusPattern});

  final int target;
  final String? focusPattern;

  WeeklyGoalData copyWith({int? target, String? focusPattern, bool clearFocus = false}) =>
      WeeklyGoalData(
        target: target ?? this.target,
        focusPattern: clearFocus ? null : (focusPattern ?? this.focusPattern),
      );
}

class WeeklyGoalNotifier extends AsyncNotifier<WeeklyGoalData> {
  @override
  Future<WeeklyGoalData> build() async {
    final prefs = await ref.watch(preferencesServiceProvider.future);
    final target = prefs.getInt(_kWeeklyGoal) ?? 3;
    final focus = prefs.getString(_kFocusPattern);
    return WeeklyGoalData(target: target, focusPattern: focus);
  }

  Future<void> setGoal(int target) async {
    final prefs = await ref.read(preferencesServiceProvider.future);
    await prefs.setInt(_kWeeklyGoal, target);
    state = AsyncData(state.valueOrNull?.copyWith(target: target) ??
        WeeklyGoalData(target: target));
  }

  Future<void> setFocusPattern(String? pattern) async {
    final prefs = await ref.read(preferencesServiceProvider.future);
    if (pattern == null || pattern.isEmpty) {
      await prefs.remove(_kFocusPattern);
    } else {
      await prefs.setString(_kFocusPattern, pattern);
    }
    state = AsyncData(state.valueOrNull?.copyWith(
          focusPattern: pattern,
          clearFocus: pattern == null || pattern.isEmpty,
        ) ??
        WeeklyGoalData(focusPattern: pattern));
  }
}

final weeklyGoalProvider =
    AsyncNotifierProvider<WeeklyGoalNotifier, WeeklyGoalData>(
        WeeklyGoalNotifier.new);

// ── Weekly progress (computed) ────────────────────────────────────────────────

class WeeklyProgress {
  const WeeklyProgress({
    required this.target,
    required this.thisWeekCount,
    required this.streak,
    this.focusPattern,
    required this.daysLeft,
    required this.focusPatternCompleted,
  });

  final int target;
  final int thisWeekCount;
  final int streak;
  final String? focusPattern;
  final int daysLeft;
  final bool focusPatternCompleted;

  double get progressRatio =>
      target == 0 ? 0 : (thisWeekCount / target).clamp(0.0, 1.0);
  bool get goalMet => thisWeekCount >= target;
}

final weeklyProgressProvider = Provider<WeeklyProgress>((ref) {
  final goalAsync = ref.watch(weeklyGoalProvider);
  final journalState = ref.watch(journalControllerProvider);

  final goal = goalAsync.valueOrNull ?? const WeeklyGoalData();
  final sessions = journalState.sessions;

  final now = DateTime.now();
  final weekdayOffset = now.weekday - 1; // Mon=0
  final monday = DateTime(now.year, now.month, now.day - weekdayOffset);
  final sunday = monday.add(const Duration(days: 7));

  final thisWeekSessions = sessions.where((s) =>
      !s.date.isBefore(monday) && s.date.isBefore(sunday)).toList();
  final thisWeekCount = thisWeekSessions.length;

  final streak = _calcStreak(sessions, goal.target, monday);
  final daysLeft = sunday.difference(now).inDays;

  final focusCompleted = goal.focusPattern != null &&
      thisWeekSessions.any((s) =>
          s.patternName.isNotEmpty &&
          s.patternName.toLowerCase() ==
              goal.focusPattern!.toLowerCase());

  return WeeklyProgress(
    target: goal.target,
    thisWeekCount: thisWeekCount,
    streak: streak,
    focusPattern: goal.focusPattern,
    daysLeft: daysLeft,
    focusPatternCompleted: focusCompleted,
  );
});

int _calcStreak(
    List<TrainingSession> sessions, int target, DateTime thisMonday) {
  if (target == 0) return 0;
  int streak = 0;
  var weekStart = thisMonday.subtract(const Duration(days: 7));
  for (var i = 0; i < 52; i++) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final count = sessions
        .where((s) =>
            !s.date.isBefore(weekStart) && s.date.isBefore(weekEnd))
        .length;
    if (count >= target) {
      streak++;
      weekStart = weekStart.subtract(const Duration(days: 7));
    } else {
      break;
    }
  }
  return streak;
}
