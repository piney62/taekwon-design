import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/auth/application/providers.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/coach/presentation/screens/coach_screen.dart';
import '../../features/dojo/presentation/instructor_dojo_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/learn/presentation/learn_screen.dart';
import '../../features/pose_analysis/presentation/pose_analysis_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';

class _RouterNotifier extends ChangeNotifier {
  bool _isLoading = true;
  bool _isRegistered = false;

  bool get isLoading => _isLoading;
  bool get isRegistered => _isRegistered;

  void update(AuthState state) {
    final changed =
        _isLoading != state.isLoading || _isRegistered != state.isRegistered;
    _isLoading = state.isLoading;
    _isRegistered = state.isRegistered;
    if (changed) notifyListeners();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier();

  ref.listen<AuthState>(authControllerProvider, (_, next) {
    notifier.update(next);
  });

  // Initialize with current state
  notifier.update(ref.read(authControllerProvider));

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      if (notifier.isLoading) return null;
      final isOnRegister = state.fullPath == AppRoutes.register;
      if (!notifier.isRegistered && !isOnRegister) return AppRoutes.register;
      if (notifier.isRegistered && isOnRegister) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.poseAnalysis,
                builder: (context, state) => const PoseAnalysisScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.journal,
                builder: (context, state) => const _JournalOrDojoScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.coach,
        builder: (context, state) => const CoachScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});

class _JournalOrDojoScreen extends ConsumerWidget {
  const _JournalOrDojoScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstructor = ref.watch(
      authControllerProvider.select((s) => s.isInstructor),
    );
    return isInstructor ? const InstructorDojoScreen() : const JournalScreen();
  }
}
