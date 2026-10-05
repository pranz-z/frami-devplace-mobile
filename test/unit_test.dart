import 'package:flutter_test/flutter_test.dart';
import 'package:frami_mobile/features/kanban/domain/task_model.dart';
import 'package:frami_mobile/features/health/domain/health_model.dart';
import 'package:frami_mobile/features/focus/domain/focus_session_model.dart';
import 'package:frami_mobile/features/portfolio/domain/public_models.dart';
import 'package:frami_mobile/core/data/seed_demo_data.dart';

void main() {
  group('1. Kanban Move Logic & Invariants', () {
    test('Moving a task to Done sets completedAt to now (UTC)', () {
      final nowUtc = DateTime.utc(2026, 10, 5, 12, 0, 0);
      final initialTasks = [
        Task(
          id: 'task-test-1',
          ownerId: 'owner-1',
          projectId: 'proj-1',
          title: 'Implement Kanban',
          status: TaskStatus.inProgress,
          createdAt: nowUtc.subtract(const Duration(days: 1)),
        ),
      ];

      final updatedTasks = moveTaskInBoard(
        allTasks: initialTasks,
        taskId: 'task-test-1',
        targetStatus: TaskStatus.done,
        targetIndex: 0,
        nowUtc: nowUtc,
      );

      final moved = updatedTasks.firstWhere((t) => t.id == 'task-test-1');
      expect(moved.status, TaskStatus.done);
      expect(moved.completedAt, nowUtc);
    });

    test('Moving a task out of Done clears completedAt and assigns target column status', () {
      final nowUtc = DateTime.utc(2026, 10, 5, 12, 0, 0);
      final initialTasks = [
        Task(
          id: 'task-test-2',
          ownerId: 'owner-1',
          projectId: 'proj-1',
          title: 'Finished Task',
          status: TaskStatus.done,
          completedAt: nowUtc.subtract(const Duration(hours: 3)),
          createdAt: nowUtc.subtract(const Duration(days: 2)),
        ),
      ];

      final updatedTasks = moveTaskInBoard(
        allTasks: initialTasks,
        taskId: 'task-test-2',
        targetStatus: TaskStatus.inProgress,
        targetIndex: 0,
        nowUtc: nowUtc,
      );

      final moved = updatedTasks.firstWhere((t) => t.id == 'task-test-2');
      expect(moved.status, TaskStatus.inProgress);
      expect(moved.completedAt, isNull);
    });
  });

  group('2. Project Health Deterministic Scoring', () {
    test('Calculates score deterministically and caps at 0-100', () {
      final highReport = calculateProjectHealth(
        activeDaysInLast14: 14,
        projectProgressAvg: 1.0,
        milestoneOnTimeRate: 1.0,
        completedTasksCount: 20,
        overdueTasksCount: 0,
        githubActivityCount: 30,
        goalsProgressAvg: 1.0,
      );

      expect(highReport.score, greaterThanOrEqualTo(80));
      expect(highReport.state, HealthState.thriving);
      expect(highReport.breakdown.isNotEmpty, isTrue);
      expect(highReport.suggestedNextActions.isNotEmpty, isTrue);

      final stalledReport = calculateProjectHealth(
        activeDaysInLast14: 2,
        projectProgressAvg: 0.1,
        milestoneOnTimeRate: 0.2,
        completedTasksCount: 1,
        overdueTasksCount: 10, // heavy overdue drag
        githubActivityCount: 0,
        goalsProgressAvg: 0.1,
      );

      expect(stalledReport.score, lessThan(40));
      expect(stalledReport.state, HealthState.stalled);
    });
  });

  group('3. Timestamp-based Focus Timer Math', () {
    test('Computes accurate remaining time from timestamps without counting drift', () {
      final startTime = DateTime.utc(2026, 10, 5, 10, 0, 0);
      var session = FocusSession(
        id: 'session-1',
        targetDurationSeconds: 1500, // 25 min
        startedAt: startTime,
        status: FocusSessionStatus.running,
      );

      // Advance clock by 10 minutes (600 seconds)
      final after10Min = startTime.add(const Duration(minutes: 10));
      expect(session.getRemainingSeconds(after10Min), 900); // 1500 - 600 = 900s
      expect(session.getProgress(after10Min), closeTo(0.4, 0.01));

      // Pause at 10 minutes
      session = pauseFocusSession(session: session, now: after10Min);
      expect(session.status, FocusSessionStatus.paused);

      // App paused for 5 minutes in background
      final after15Min = startTime.add(const Duration(minutes: 15));
      // Remaining time during pause stays frozen at 900s
      expect(session.getRemainingSeconds(after15Min), 900);

      // Resume at 15 minutes
      session = resumeFocusSession(session: session, now: after15Min);
      expect(session.status, FocusSessionStatus.running);
      expect(session.accumulatedPausedSeconds, 300); // 5 min paused

      // Another 5 minutes of active work passed (total time 20 min from start)
      final after20Min = startTime.add(const Duration(minutes: 20));
      // Elapsed active time = 20m - 5m paused = 15m (900s). Remaining = 1500 - 900 = 600s
      expect(session.getRemainingSeconds(after20Min), 600);
    });
  });

  group('4. Hard Privacy Separation: PublicContext Zero-Leakage Test', () {
    test('PublicContext serialization contains NO private fields or private projects', () {
      final profile = SeedDemoData.getPublicProfile();
      final allProjects = SeedDemoData.getProjects();
      final publicOnlyProjects = allProjects
          .where((p) => p.isPublic)
          .map((p) => PublicProject(
                id: p.id,
                title: p.name,
                summary: p.publishSummaryApproved ? p.summary : '',
                technologies: p.publishTechApproved ? p.technologies : [],
                architecture: p.publishArchitectureApproved ? p.architectureNotes : null,
                outcome: p.publishOutcomeApproved ? p.outcomeNotes : null,
              ))
          .toList();

      final context = PublicContext(
        profile: profile,
        projects: publicOnlyProjects,
        evidence: SeedDemoData.getPublicEvidence(),
      );

      final json = context.toJson();

      // Check forbidden private project names are absent
      final jsonString = json.toString().toLowerCase();
      expect(jsonString.contains('internal ledger'), isFalse);
      expect(jsonString.contains('stealth ai agent'), isFalse);

      // Check forbidden private structural keys do NOT exist in serialized output
      expect(json.containsKey('tasks'), isFalse);
      expect(json.containsKey('notes'), isFalse);
      expect(json.containsKey('plans'), isFalse);
      expect(json.containsKey('calendarEvents'), isFalse);
      expect(json.containsKey('goals'), isFalse);
      expect(json.containsKey('healthScore'), isFalse);
    });
  });
}
