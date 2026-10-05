enum FocusSessionStatus {
  idle,
  running,
  paused,
  completed,
  cancelled;
}

/// Timestamp-based Focus Session
/// NEVER decrements a counter. Computes remaining time from DateTime.now()
/// on each tick and on AppLifecycleState.resumed.
class FocusSession {
  final String id;
  final String? taskId;
  final String? taskTitle;
  final String? projectId;
  final int targetDurationSeconds; // e.g. 1500 (25 min)
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final int accumulatedPausedSeconds; // Sum of seconds spent in paused state
  final FocusSessionStatus status;

  const FocusSession({
    required this.id,
    this.taskId,
    this.taskTitle,
    this.projectId,
    required this.targetDurationSeconds,
    this.startedAt,
    this.pausedAt,
    this.accumulatedPausedSeconds = 0,
    this.status = FocusSessionStatus.idle,
  });

  /// Calculate seconds remaining from current timestamp
  int getRemainingSeconds([DateTime? nowTime]) {
    if (status == FocusSessionStatus.idle || startedAt == null) {
      return targetDurationSeconds;
    }
    if (status == FocusSessionStatus.completed) {
      return 0;
    }

    final now = nowTime ?? DateTime.now();

    // If currently paused, elapsed active time is pausedAt - startedAt - accumulatedPaused
    final referenceEnd = (status == FocusSessionStatus.paused && pausedAt != null)
        ? pausedAt!
        : now;

    final totalElapsedSeconds =
        referenceEnd.difference(startedAt!).inSeconds - accumulatedPausedSeconds;

    final remaining = targetDurationSeconds - totalElapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Calculate progress from 0.0 to 1.0
  double getProgress([DateTime? nowTime]) {
    if (targetDurationSeconds <= 0) return 0.0;
    final remaining = getRemainingSeconds(nowTime);
    final elapsed = targetDurationSeconds - remaining;
    return (elapsed / targetDurationSeconds).clamp(0.0, 1.0);
  }

  bool isFinished([DateTime? nowTime]) {
    return getRemainingSeconds(nowTime) <= 0;
  }

  FocusSession copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    String? projectId,
    int? targetDurationSeconds,
    DateTime? startedAt,
    DateTime? pausedAt,
    int? accumulatedPausedSeconds,
    FocusSessionStatus? status,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      projectId: projectId ?? this.projectId,
      targetDurationSeconds:
          targetDurationSeconds ?? this.targetDurationSeconds,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      accumulatedPausedSeconds:
          accumulatedPausedSeconds ?? this.accumulatedPausedSeconds,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'taskTitle': taskTitle,
        'projectId': projectId,
        'targetDurationSeconds': targetDurationSeconds,
        'startedAt': startedAt?.toIso8601String(),
        'pausedAt': pausedAt?.toIso8601String(),
        'accumulatedPausedSeconds': accumulatedPausedSeconds,
        'status': status.name,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        taskId: json['taskId'] as String?,
        taskTitle: json['taskTitle'] as String?,
        projectId: json['projectId'] as String?,
        targetDurationSeconds: json['targetDurationSeconds'] as int? ?? 1500,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        pausedAt: json['pausedAt'] != null
            ? DateTime.parse(json['pausedAt'] as String)
            : null,
        accumulatedPausedSeconds:
            json['accumulatedPausedSeconds'] as int? ?? 0,
        status: FocusSessionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => FocusSessionStatus.idle,
        ),
      );
}

/// Pure math state transitions for Focus Session
FocusSession startFocusSession({
  required FocusSession session,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  return session.copyWith(
    startedAt: current,
    pausedAt: null,
    accumulatedPausedSeconds: 0,
    status: FocusSessionStatus.running,
  );
}

FocusSession pauseFocusSession({
  required FocusSession session,
  DateTime? now,
}) {
  if (session.status != FocusSessionStatus.running) return session;
  final current = now ?? DateTime.now();
  return session.copyWith(
    pausedAt: current,
    status: FocusSessionStatus.paused,
  );
}

FocusSession resumeFocusSession({
  required FocusSession session,
  DateTime? now,
}) {
  if (session.status != FocusSessionStatus.paused || session.pausedAt == null) {
    return session;
  }
  final current = now ?? DateTime.now();
  final pauseDuration = current.difference(session.pausedAt!).inSeconds;
  return session.copyWith(
    pausedAt: null,
    accumulatedPausedSeconds: session.accumulatedPausedSeconds + pauseDuration,
    status: FocusSessionStatus.running,
  );
}

FocusSession extendFocusSession({
  required FocusSession session,
  int additionalSeconds = 300, // +5 min
}) {
  return session.copyWith(
    targetDurationSeconds: session.targetDurationSeconds + additionalSeconds,
  );
}

FocusSession completeFocusSession({
  required FocusSession session,
}) {
  return session.copyWith(
    status: FocusSessionStatus.completed,
  );
}
