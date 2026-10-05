enum GoalCadence {
  weekly,
  monthly,
  quarterly;

  String get label {
    switch (this) {
      case GoalCadence.weekly:
        return 'Weekly';
      case GoalCadence.monthly:
        return 'Monthly';
      case GoalCadence.quarterly:
        return 'Quarterly';
    }
  }
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalCadence cadence;
  final double currentProgress; // 0.0 to 1.0
  final DateTime targetDate;
  final bool isCompleted;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.cadence,
    required this.currentProgress,
    required this.targetDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'cadence': cadence.name,
        'currentProgress': currentProgress,
        'targetDate': targetDate.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        cadence: GoalCadence.values.firstWhere(
          (e) => e.name == json['cadence'],
          orElse: () => GoalCadence.weekly,
        ),
        currentProgress: (json['currentProgress'] as num?)?.toDouble() ?? 0.0,
        targetDate: DateTime.parse(json['targetDate'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class PeriodicSnapshotReport {
  final String id;
  final String periodName; // e.g. "Week 40 - 2026"
  final DateTime startDate;
  final DateTime endDate;
  final int focusMinutesLogged;
  final int tasksCompletedCount;
  final int commitsPushedCount;
  final List<int> dailyFocusMinutes; // 7 days values for chart

  const PeriodicSnapshotReport({
    required this.id,
    required this.periodName,
    required this.startDate,
    required this.endDate,
    required this.focusMinutesLogged,
    required this.tasksCompletedCount,
    required this.commitsPushedCount,
    required this.dailyFocusMinutes,
  });
}
