import 'dart:math' as math;

enum HealthState {
  thriving,
  steady,
  needsAttention,
  stalled;

  String get label {
    switch (this) {
      case HealthState.thriving:
        return 'Thriving';
      case HealthState.steady:
        return 'Steady';
      case HealthState.needsAttention:
        return 'Needs attention';
      case HealthState.stalled:
        return 'Stalled';
    }
  }
}

class HealthReport {
  final int score; // 0 to 100
  final HealthState state;
  final String summary;
  final List<String> breakdown;
  final List<String> suggestedNextActions;

  const HealthReport({
    required this.score,
    required this.state,
    required this.summary,
    required this.breakdown,
    required this.suggestedNextActions,
  });
}

/// Pure deterministic scoring function (0-100)
/// Inputs:
/// - activeDaysInLast14: consistency (active days out of 14, NOT commit count) -> up to 30 pts
/// - projectProgressAvg: average project progress (0.0 to 1.0) -> up to 25 pts
/// - milestoneOnTimeRate: completed on-time milestones ratio (0.0 to 1.0) -> up to 20 pts
/// - taskCompletionRatio: completed tasks vs overdue ratio -> up to 15 pts
/// - githubActivityCount: log-scaled git actions (capped, small weight) -> up to 10 pts
HealthReport calculateProjectHealth({
  required int activeDaysInLast14,
  required double projectProgressAvg,
  required double milestoneOnTimeRate,
  required int completedTasksCount,
  required int overdueTasksCount,
  required int githubActivityCount,
  required double goalsProgressAvg,
}) {
  // 1. Consistency Score (max 30)
  final clampedDays = activeDaysInLast14.clamp(0, 14);
  final consistencyScore = (clampedDays / 14.0) * 30.0;

  // 2. Project Progress Score (max 25)
  final progressScore = projectProgressAvg.clamp(0.0, 1.0) * 25.0;

  // 3. Milestone On-time Score (max 20)
  final milestoneScore = milestoneOnTimeRate.clamp(0.0, 1.0) * 20.0;

  // 4. Task Ratio Score (max 15)
  double taskScore;
  if (completedTasksCount == 0 && overdueTasksCount == 0) {
    taskScore = 10.0;
  } else {
    final overduePenalty = (overdueTasksCount * 3.0);
    final rawTaskRatio = (completedTasksCount * 2.0) - overduePenalty;
    taskScore = rawTaskRatio.clamp(0.0, 15.0);
  }

  // 5. GitHub log-scaled activity (max 10)
  // log2(activity + 1) normalized up to ~32 events
  final logGit = math.log(githubActivityCount + 1) / math.ln2;
  final gitScore = (logGit / 5.0).clamp(0.0, 1.0) * 10.0;

  final rawTotal =
      consistencyScore + progressScore + milestoneScore + taskScore + gitScore;
  final totalScore = rawTotal.round().clamp(0, 100);

  HealthState state;
  String summary;
  if (totalScore >= 80) {
    state = HealthState.thriving;
    summary =
        'Excellent development rhythm with high consistency and on-track milestones.';
  } else if (totalScore >= 60) {
    state = HealthState.steady;
    summary =
        'Steady progress across projects. Keep momentum going without burning out.';
  } else if (totalScore >= 40) {
    state = HealthState.needsAttention;
    summary =
        'Workflow has slowed down or overdue items are accumulating. Needs focus.';
  } else {
    state = HealthState.stalled;
    summary =
        'Projects are stalled with little recent activity or high overdue backlog.';
  }

  final breakdown = [
    'Consistency: $clampedDays/14 active days (${consistencyScore.toStringAsFixed(1)}/30 pts)',
    'Project Progress: ${(projectProgressAvg * 100).toInt()}% avg (${progressScore.toStringAsFixed(1)}/25 pts)',
    'Milestones on-time: ${(milestoneOnTimeRate * 100).toInt()}% (${milestoneScore.toStringAsFixed(1)}/20 pts)',
    'Tasks: $completedTasksCount done, $overdueTasksCount overdue (${taskScore.toStringAsFixed(1)}/15 pts)',
    'GitHub Activity (log-scaled): $githubActivityCount events (${gitScore.toStringAsFixed(1)}/10 pts)',
  ];

  final suggestions = <String>[];
  if (overdueTasksCount > 0) {
    suggestions.add(
        'Reschedule or complete the $overdueTasksCount overdue tasks in Today view.');
  }
  if (clampedDays < 7) {
    suggestions.add(
        'Establish a regular daily 25-minute focus session to build momentum.');
  }
  if (milestoneOnTimeRate < 0.7) {
    suggestions.add('Break upcoming milestones into smaller 1-day tasks.');
  }
  if (suggestions.isEmpty) {
    suggestions.add(
        'Maintain current cadence and consider shipping the next portfolio update.');
  }

  return HealthReport(
    score: totalScore,
    state: state,
    summary: summary,
    breakdown: breakdown,
    suggestedNextActions: suggestions,
  );
}
