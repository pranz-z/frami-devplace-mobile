enum ProjectWorkflowStage {
  idea,
  planning,
  building,
  polishing,
  shipped;

  String get label {
    switch (this) {
      case ProjectWorkflowStage.idea:
        return 'Idea';
      case ProjectWorkflowStage.planning:
        return 'Planning';
      case ProjectWorkflowStage.building:
        return 'Building';
      case ProjectWorkflowStage.polishing:
        return 'Polishing';
      case ProjectWorkflowStage.shipped:
        return 'Shipped';
    }
  }
}

enum ProjectLifecycleStatus {
  active,
  paused,
  completed,
  archived;

  String get label {
    switch (this) {
      case ProjectLifecycleStatus.active:
        return 'Active';
      case ProjectLifecycleStatus.paused:
        return 'Paused';
      case ProjectLifecycleStatus.completed:
        return 'Completed';
      case ProjectLifecycleStatus.archived:
        return 'Archived';
    }
  }
}

/// Private Project domain entity
class Project {
  final String id;
  final String ownerId;
  final String name;
  final String summary;
  final String fullDescription;
  final ProjectWorkflowStage workflowStage;
  final ProjectLifecycleStatus lifecycleStatus;
  final bool isPublic;
  final List<String> technologies;
  final String? githubRepoName;
  final double progress; // 0.0 - 1.0
  final DateTime createdAt;
  final DateTime updatedAt;

  // Publish-approval flags (which fields the owner approved for public projection)
  final bool publishSummaryApproved;
  final bool publishTechApproved;
  final bool publishArchitectureApproved;
  final bool publishScreenshotsApproved;
  final bool publishChallengesApproved;
  final bool publishOutcomeApproved;
  final String architectureNotes;
  final String challengesNotes;
  final String outcomeNotes;
  final List<String> screenshotUrls;

  const Project({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.summary,
    required this.fullDescription,
    required this.workflowStage,
    required this.lifecycleStatus,
    this.isPublic = false,
    this.technologies = const [],
    this.githubRepoName,
    this.progress = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.publishSummaryApproved = true,
    this.publishTechApproved = true,
    this.publishArchitectureApproved = false,
    this.publishScreenshotsApproved = false,
    this.publishChallengesApproved = false,
    this.publishOutcomeApproved = false,
    this.architectureNotes = '',
    this.challengesNotes = '',
    this.outcomeNotes = '',
    this.screenshotUrls = const [],
  });

  Project copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? summary,
    String? fullDescription,
    ProjectWorkflowStage? workflowStage,
    ProjectLifecycleStatus? lifecycleStatus,
    bool? isPublic,
    List<String>? technologies,
    String? githubRepoName,
    double? progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? publishSummaryApproved,
    bool? publishTechApproved,
    bool? publishArchitectureApproved,
    bool? publishScreenshotsApproved,
    bool? publishChallengesApproved,
    bool? publishOutcomeApproved,
    String? architectureNotes,
    String? challengesNotes,
    String? outcomeNotes,
    List<String>? screenshotUrls,
  }) {
    return Project(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      fullDescription: fullDescription ?? this.fullDescription,
      workflowStage: workflowStage ?? this.workflowStage,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      isPublic: isPublic ?? this.isPublic,
      technologies: technologies ?? this.technologies,
      githubRepoName: githubRepoName ?? this.githubRepoName,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishSummaryApproved:
          publishSummaryApproved ?? this.publishSummaryApproved,
      publishTechApproved: publishTechApproved ?? this.publishTechApproved,
      publishArchitectureApproved:
          publishArchitectureApproved ?? this.publishArchitectureApproved,
      publishScreenshotsApproved:
          publishScreenshotsApproved ?? this.publishScreenshotsApproved,
      publishChallengesApproved:
          publishChallengesApproved ?? this.publishChallengesApproved,
      publishOutcomeApproved:
          publishOutcomeApproved ?? this.publishOutcomeApproved,
      architectureNotes: architectureNotes ?? this.architectureNotes,
      challengesNotes: challengesNotes ?? this.challengesNotes,
      outcomeNotes: outcomeNotes ?? this.outcomeNotes,
      screenshotUrls: screenshotUrls ?? this.screenshotUrls,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'summary': summary,
        'fullDescription': fullDescription,
        'workflowStage': workflowStage.name,
        'lifecycleStatus': lifecycleStatus.name,
        'isPublic': isPublic,
        'technologies': technologies,
        'githubRepoName': githubRepoName,
        'progress': progress,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'publishSummaryApproved': publishSummaryApproved,
        'publishTechApproved': publishTechApproved,
        'publishArchitectureApproved': publishArchitectureApproved,
        'publishScreenshotsApproved': publishScreenshotsApproved,
        'publishChallengesApproved': publishChallengesApproved,
        'publishOutcomeApproved': publishOutcomeApproved,
        'architectureNotes': architectureNotes,
        'challengesNotes': challengesNotes,
        'outcomeNotes': outcomeNotes,
        'screenshotUrls': screenshotUrls,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String? ?? 'owner-1',
        name: json['name'] as String,
        summary: json['summary'] as String? ?? '',
        fullDescription: json['fullDescription'] as String? ?? '',
        workflowStage: ProjectWorkflowStage.values.firstWhere(
          (e) => e.name == json['workflowStage'],
          orElse: () => ProjectWorkflowStage.building,
        ),
        lifecycleStatus: ProjectLifecycleStatus.values.firstWhere(
          (e) => e.name == json['lifecycleStatus'],
          orElse: () => ProjectLifecycleStatus.active,
        ),
        isPublic: json['isPublic'] as bool? ?? false,
        technologies: (json['technologies'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        githubRepoName: json['githubRepoName'] as String?,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        publishSummaryApproved:
            json['publishSummaryApproved'] as bool? ?? true,
        publishTechApproved: json['publishTechApproved'] as bool? ?? true,
        publishArchitectureApproved:
            json['publishArchitectureApproved'] as bool? ?? false,
        publishScreenshotsApproved:
            json['publishScreenshotsApproved'] as bool? ?? false,
        publishChallengesApproved:
            json['publishChallengesApproved'] as bool? ?? false,
        publishOutcomeApproved:
            json['publishOutcomeApproved'] as bool? ?? false,
        architectureNotes: json['architectureNotes'] as String? ?? '',
        challengesNotes: json['challengesNotes'] as String? ?? '',
        outcomeNotes: json['outcomeNotes'] as String? ?? '',
        screenshotUrls: (json['screenshotUrls'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

/// Project Milestone
class Milestone {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;

  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
  });

  Milestone copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) =>
      Milestone(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        dueDate: DateTime.parse(json['dueDate'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}

/// Project Plan
class ProjectPlan {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final DateTime createdAt;

  const ProjectPlan({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProjectPlan.fromJson(Map<String, dynamic> json) => ProjectPlan(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Project Note
class ProjectNote {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final DateTime updatedAt;

  const ProjectNote({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'content': content,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProjectNote.fromJson(Map<String, dynamic> json) => ProjectNote(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
