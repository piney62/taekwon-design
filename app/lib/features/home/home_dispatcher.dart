import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_settings.dart';
import 'instructor_home_screen.dart';
import 'student_home_screen.dart';

/// Picks the right Home screen based on the current role.
class HomeDispatcher extends ConsumerWidget {
  const HomeDispatcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appSettingsProvider.select((s) => s.role));
    return role == UserRole.instructor
        ? const InstructorHomeScreen()
        : const StudentHomeScreen();
  }
}
