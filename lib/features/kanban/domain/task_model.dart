enum TaskStatus {
  backlog,
  todo,
  inProgress,
  inReview,
  done;

  String get label {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Private Task domain model
class Task {
  final String id;
  final String ownerId;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate; // Stored in UTC (date-only normalized or instant)
  final int orderIndex; // For ordering within column
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.ownerId,
    required this.projectId,
    required this.title,
    this.description = '',
    required this.status,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.orderIndex = 0,
    required this.createdAt,
    this.completedAt,
  });

  bool get isOverdue {
    if (status == TaskStatus.done || dueDate == null) return false;
    final now = DateTime.now().toUtc();
    final todayUtc = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
    return dueDate!.isBefore(todayUtc);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now().toUtc();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Task copyWith({
    String? id,
    String? ownerId,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'projectId': projectId,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
        'orderIndex': orderIndex,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String? ?? 'owner-1',
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.todo,
        ),
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String).toUtc()
            : null,
        orderIndex: json['orderIndex'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}

/// Pure domain function: moving a task to a target column or reordering within column.
/// When moving to Done: sets completedAt to now (UTC).
/// When moving out of Done: clears completedAt and assigns target column status.
List<Task> moveTaskInBoard({
  required List<Task> allTasks,
  required String taskId,
  required TaskStatus targetStatus,
  required int targetIndex,
  DateTime? nowUtc,
}) {
  final now = nowUtc ?? DateTime.now().toUtc();
  final taskToMoveIndex = allTasks.indexWhere((t) => t.id == taskId);
  if (taskToMoveIndex == -1) return allTasks;

  final original = allTasks[taskToMoveIndex];
  final movingToDone = targetStatus == TaskStatus.done;
  final movingOutOfDone = original.status == TaskStatus.done && !movingToDone;

  final updatedTask = original.copyWith(
    status: targetStatus,
    completedAt: movingToDone ? now : null,
    clearCompletedAt: movingOutOfDone,
  );

  // Group tasks by target column (excluding moving task)
  final columnTasks = allTasks
      .where((t) => t.id != taskId && t.status == targetStatus)
      .toList()
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

  final safeIndex = targetIndex.clamp(0, columnTasks.length);
  columnTasks.insert(safeIndex, updatedTask);

  // Re-index column
  final reindexedColumn = <Task>[];
  for (int i = 0; i < columnTasks.length; i++) {
    reindexedColumn.add(columnTasks[i].copyWith(orderIndex: i));
  }

  // Combine back with tasks from other columns
  final result = <Task>[];
  final columnTaskMap = {for (var t in reindexedColumn) t.id: t};

  for (final t in allTasks) {
    if (columnTaskMap.containsKey(t.id)) {
      result.add(columnTaskMap[t.id]!);
    } else if (t.id != taskId) {
      result.add(t);
    }
  }

  return result;
}
