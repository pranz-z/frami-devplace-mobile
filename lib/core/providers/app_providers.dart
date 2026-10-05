import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frami_mobile/features/projects/data/project_repository.dart';
import 'package:frami_mobile/features/projects/data/local_project_repository.dart';
import 'package:frami_mobile/features/kanban/data/task_repository.dart';
import 'package:frami_mobile/features/kanban/data/local_task_repository.dart';
import 'package:frami_mobile/features/github/data/github_repository.dart';
import 'package:frami_mobile/features/github/data/mock_github_repository.dart';
import 'package:frami_mobile/features/portfolio/data/public_portfolio_repository.dart';
import 'package:frami_mobile/features/portfolio/data/safe_public_portfolio_repository.dart';
import 'package:frami_mobile/features/ai_workspace/data/ai_service.dart';
import 'package:frami_mobile/features/ai_workspace/data/mock_ai_service.dart';
import 'package:frami_mobile/features/focus/domain/focus_session_model.dart';
import 'package:frami_mobile/features/health/domain/health_model.dart';
import 'package:frami_mobile/features/projects/domain/project_model.dart';
import 'package:frami_mobile/features/kanban/domain/task_model.dart';

// Owner authentication state
final isOwnerLoggedInProvider = StateProvider<bool>((ref) => false);
const String currentOwnerId = 'owner-1';

// Theme state: 'light', 'dark', 'system'
final themeModeStringProvider = StateProvider<String>((ref) => 'light');

// Focus Mode fullscreen state (hides bottom nav & tabs)
final isFocusModeActiveProvider = StateProvider<bool>((ref) => false);

// SharedPreferences provider (overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main');
});

// Repositories
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalProjectRepository(prefs);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalTaskRepository(prefs);
});

final githubRepositoryProvider = Provider<GithubRepository>((ref) {
  return MockGithubRepository();
});

final publicPortfolioRepositoryProvider =
    Provider<PublicPortfolioRepository>((ref) {
  final projectRepo = ref.watch(projectRepositoryProvider);
  return SafePublicPortfolioRepository(projectRepo, ownerId: currentOwnerId);
});

final aiServiceProvider = Provider<AiService>((ref) {
  final projRepo = ref.watch(projectRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  return MockAiService(projectRepository: projRepo, taskRepository: taskRepo);
});

// Reactive Data Providers
final projectsProvider =
    AsyncNotifierProvider<ProjectsNotifier, List<Project>>(
        ProjectsNotifier.new);

class ProjectsNotifier extends AsyncNotifier<List<Project>> {
  @override
  Future<List<Project>> build() async {
    final repo = ref.watch(projectRepositoryProvider);
    return repo.getProjects(ownerId: currentOwnerId);
  }

  Future<void> saveProject(Project project) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.saveProject(project);
    ref.invalidateSelf();
    ref.invalidate(publicPortfolioRepositoryProvider);
  }

  Future<void> deleteProject(String id) async {
    final repo = ref.read(projectRepositoryProvider);
    await repo.deleteProject(id, ownerId: currentOwnerId);
    ref.invalidateSelf();
    ref.invalidate(publicPortfolioRepositoryProvider);
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getTasks(ownerId: currentOwnerId);
  }

  Future<void> saveTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.saveTask(task);
    ref.invalidateSelf();
  }

  Future<void> moveTask({
    required String taskId,
    required TaskStatus targetStatus,
    required int targetIndex,
  }) async {
    final currentTasks = state.value ?? [];
    final updated = moveTaskInBoard(
      allTasks: currentTasks,
      taskId: taskId,
      targetStatus: targetStatus,
      targetIndex: targetIndex,
    );
    state = AsyncData(updated);
    final repo = ref.read(taskRepositoryProvider);
    await repo.saveTasks(updated);
  }

  Future<void> deleteTask(String id) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.deleteTask(id, ownerId: currentOwnerId);
    ref.invalidateSelf();
  }
}

// Health Score computation provider
final healthReportProvider = Provider<HealthReport>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final projectsAsync = ref.watch(projectsProvider);

  final tasks = tasksAsync.value ?? [];
  final projects = projectsAsync.value ?? [];

  final completedTasksCount =
      tasks.where((t) => t.status == TaskStatus.done).length;
  final overdueTasksCount = tasks.where((t) => t.isOverdue).length;

  double avgProgress = 0.0;
  if (projects.isNotEmpty) {
    avgProgress =
        projects.map((p) => p.progress).reduce((a, b) => a + b) / projects.length;
  }

  return calculateProjectHealth(
    activeDaysInLast14: 11,
    projectProgressAvg: avgProgress,
    milestoneOnTimeRate: 0.82,
    completedTasksCount: completedTasksCount,
    overdueTasksCount: overdueTasksCount,
    githubActivityCount: 18,
    goalsProgressAvg: 0.87,
  );
});

// Timestamp-based Focus Session Controller
final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSession>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FocusSessionNotifier(prefs);
});

class FocusSessionNotifier extends StateNotifier<FocusSession> {
  static const String _sessionKey = 'frami_focus_session_v1';
  final SharedPreferences _prefs;

  FocusSessionNotifier(this._prefs)
      : super(const FocusSession(
          id: 'focus-current',
          targetDurationSeconds: 1500, // 25 min default
        )) {
    _loadSession();
  }

  void _loadSession() {
    final raw = _prefs.getString(_sessionKey);
    if (raw != null) {
      try {
        final decoded =
            FocusSession.fromJson(Map<String, dynamic>.from(
                Uri.splitQueryString(raw))); // simplified fallback
        state = decoded;
      } catch (_) {}
    }
  }

  Future<void> _persistSession() async {
    // Save minimal serialized state
    final map = state.toJson();
    await _prefs.setString(
        _sessionKey, map.entries.map((e) => '${e.key}=${e.value}').join('&'));
  }

  void selectTask(Task task) {
    state = state.copyWith(
      taskId: task.id,
      taskTitle: task.title,
      projectId: task.projectId,
    );
    _persistSession();
  }

  void setDurationMinutes(int minutes) {
    state = state.copyWith(
      targetDurationSeconds: minutes * 60,
    );
    _persistSession();
  }

  void start() {
    state = startFocusSession(session: state);
    _persistSession();
  }

  void pause() {
    state = pauseFocusSession(session: state);
    _persistSession();
  }

  void resume() {
    state = resumeFocusSession(session: state);
    _persistSession();
  }

  void extend(int minutes) {
    state = extendFocusSession(session: state, additionalSeconds: minutes * 60);
    _persistSession();
  }

  void complete() {
    state = completeFocusSession(session: state);
    _persistSession();
  }

  void reset() {
    state = FocusSession(
      id: 'focus-current',
      taskId: state.taskId,
      taskTitle: state.taskTitle,
      projectId: state.projectId,
      targetDurationSeconds: state.targetDurationSeconds,
      status: FocusSessionStatus.idle,
    );
    _persistSession();
  }
}
