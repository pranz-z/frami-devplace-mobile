import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frami_mobile/core/providers/app_providers.dart';
import 'package:frami_mobile/core/theme/sketch_theme.dart';
import 'package:frami_mobile/features/auth/presentation/owner_login_screen.dart';
import 'package:frami_mobile/features/home/presentation/today_screen.dart';
import 'package:frami_mobile/features/projects/presentation/projects_list_screen.dart';
import 'package:frami_mobile/features/projects/presentation/project_detail_screen.dart';
import 'package:frami_mobile/features/kanban/presentation/kanban_board_screen.dart';
import 'package:frami_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:frami_mobile/features/focus/presentation/focus_screen.dart';
import 'package:frami_mobile/features/ai_workspace/presentation/workspace_ai_screen.dart';
import 'package:frami_mobile/features/github/presentation/github_screen.dart';
import 'package:frami_mobile/features/health/presentation/health_screen.dart';
import 'package:frami_mobile/features/goals/presentation/goals_screen.dart';
import 'package:frami_mobile/features/portfolio/presentation/public_portfolio_screen.dart';
import 'package:frami_mobile/features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isOwnerLoggedInProvider);

  return GoRouter(
    initialLocation: '/app/today',
    redirect: (context, state) {
      final loggingIn = state.uri.path == '/login';
      final isPublicPortfolio = state.uri.path.startsWith('/portfolio');

      // Public portfolio preview is reachable without login
      if (isPublicPortfolio) return null;

      // Private area requires login
      if (!isLoggedIn && !loggingIn) {
        return '/login';
      }
      if (isLoggedIn && loggingIn) {
        return '/app/today';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const OwnerLoginScreen(),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) {
          final repo = ref.watch(publicPortfolioRepositoryProvider);
          final ai = ref.watch(aiServiceProvider);
          return PublicPortfolioScreen(repository: repo, aiService: ai);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Today
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          // Branch 1: Projects
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/projects',
                builder: (context, state) => const ProjectsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? 'proj-1';
                      return ProjectDetailScreen(projectId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Calendar & Kanban
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // Branch 3: Focus
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/focus',
                builder: (context, state) => const FocusScreen(),
              ),
            ],
          ),
          // Branch 4: AI Workspace
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/ai',
                builder: (context, state) => const WorkspaceAiScreen(),
              ),
            ],
          ),
        ],
      ),
      // Standalone modal / pushed sub-routes
      GoRoute(
        path: '/app/kanban',
        builder: (context, state) => const KanbanBoardScreen(),
      ),
      GoRoute(
        path: '/app/github',
        builder: (context, state) => const GitHubScreen(),
      ),
      GoRoute(
        path: '/app/health',
        builder: (context, state) => const HealthScreen(),
      ),
      GoRoute(
        path: '/app/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/app/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _AppShell({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFocusMode = ref.watch(isFocusModeActiveProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: isFocusMode
          ? null // In Focus Mode: hide bottom nav to minimize distractions
          : Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? SketchPalette.borderDark : SketchPalette.borderSubtleLight,
                    width: 1.2,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                backgroundColor: isDark ? SketchPalette.paperCardDark : SketchPalette.paperCardLight,
                indicatorColor: SketchPalette.markerYellow.withValues(alpha: 0.5),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.wb_sunny_outlined),
                    selectedIcon: Icon(Icons.wb_sunny),
                    label: 'Today',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: 'Projects',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Calendar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timer_outlined),
                    selectedIcon: Icon(Icons.timer),
                    label: 'Focus',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.auto_awesome_outlined),
                    selectedIcon: Icon(Icons.auto_awesome),
                    label: 'AI',
                  ),
                ],
              ),
            ),
    );
  }
}
