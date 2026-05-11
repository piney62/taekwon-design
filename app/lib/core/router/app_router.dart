import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analyze/analyze_entry_screen.dart';
import '../../features/analyze/analyze_history_screen.dart';
import '../../features/analyze/analyze_result_screen.dart';
import '../../features/dojang/dojang_main_screen.dart';
import '../../features/dojang/student_detail_screen.dart';
import '../../features/home/home_dispatcher.dart';
import '../../features/journal/all_records_screen.dart';
import '../../features/journal/belt_progress_screen.dart';
import '../../features/journal/journal_main_screen.dart';
import '../../features/journal/weak_points_screen.dart';
import '../../features/me/me_screen.dart';
import '../../features/onboarding/account_screen.dart';
import '../../features/patterns/coach_screen.dart';
import '../../features/patterns/history_screen.dart';
import '../../features/patterns/pattern_detail_screen.dart';
import '../../features/patterns/patterns_main_screen.dart';
import '../../features/patterns/tenets_screen.dart';
import '../../features/patterns/terminology_screen.dart';
import '../../features/onboarding/login_screen.dart';
import '../../features/onboarding/profile_setup_screen.dart';
import '../../features/onboarding/role_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/welcome_screen.dart';
import '../../features/shell/main_shell.dart';
import '../providers/app_settings.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(Ref ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final settings = ref.read(appSettingsProvider);
      final loc = state.matchedLocation;
      final isOnboarding =
          loc.startsWith('/splash') || loc.startsWith('/welcome') || loc.startsWith('/onboarding');

      if (!settings.onboardingComplete && !isOnboarding) return '/splash';
      if (settings.onboardingComplete && isOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/role',
        builder: (_, _) => const RoleScreen(),
      ),
      GoRoute(
        path: '/onboarding/account',
        builder: (_, _) => const AccountScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding/login',
        builder: (_, _) => const LoginScreen(),
      ),

      // Main 5-tab shell
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootKey,
        builder: (context, state, navShell) => MainShell(navShell: navShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomeDispatcher(),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analyze',
              builder: (_, _) => const AnalyzeEntryScreen(prefill: true),
              routes: [
                GoRoute(
                  path: 'result',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const AnalyzeResultScreen(),
                ),
                GoRoute(
                  path: 'history',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const AnalyzeHistoryScreen(),
                ),
              ],
            ),
          ]),
          // Tab 3: Journal (student) OR Dojang (instructor) — picked at runtime.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tab3',
              builder: (_, _) => const _Tab3Dispatcher(),
              routes: [
                GoRoute(
                  path: 'all-records',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const AllRecordsScreen(),
                ),
                GoRoute(
                  path: 'weak-points',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const WeakPointsScreen(),
                ),
                GoRoute(
                  path: 'belt-progress',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const BeltProgressScreen(),
                ),
                GoRoute(
                  path: 'student/:id',
                  parentNavigatorKey: _rootKey,
                  builder: (_, state) => StudentDetailScreen(
                    studentName: (state.pathParameters['id'] ?? 'Student')
                        .replaceAll('-', ' '),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/patterns',
              builder: (_, _) => const PatternsMainScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  parentNavigatorKey: _rootKey,
                  builder: (_, state) => PatternDetailScreen(
                    patternNumber:
                        int.tryParse(state.pathParameters['id'] ?? '1') ?? 1,
                  ),
                ),
                GoRoute(
                  path: 'terminology',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const TerminologyScreen(),
                ),
                GoRoute(
                  path: 'tenets',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const TenetsScreen(),
                ),
                GoRoute(
                  path: 'history',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const HistoryScreen(),
                ),
                GoRoute(
                  path: 'coach',
                  parentNavigatorKey: _rootKey,
                  builder: (_, _) => const CoachScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/me',
              builder: (_, _) => const MeScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

class _Tab3Dispatcher extends ConsumerWidget {
  const _Tab3Dispatcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(appSettingsProvider.select((s) => s.role));
    if (role == UserRole.instructor) {
      return const DojangMainScreen();
    }
    return const JournalMainScreen();
  }
}

final routerProvider = Provider<GoRouter>((ref) => createRouter(ref));
