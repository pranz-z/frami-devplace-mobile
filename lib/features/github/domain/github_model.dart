enum GitHubItemType {
  commit,
  pullRequest,
  issue,
  release;
}

class GitHubActivityItem {
  final String id;
  final String repoName;
  final GitHubItemType type;
  final String title;
  final String summary;
  final String author;
  final DateTime timestamp;
  final String? url;

  const GitHubActivityItem({
    required this.id,
    required this.repoName,
    required this.type,
    required this.title,
    required this.summary,
    required this.author,
    required this.timestamp,
    this.url,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'repoName': repoName,
        'type': type.name,
        'title': title,
        'summary': summary,
        'author': author,
        'timestamp': timestamp.toIso8601String(),
        'url': url,
      };

  factory GitHubActivityItem.fromJson(Map<String, dynamic> json) =>
      GitHubActivityItem(
        id: json['id'] as String,
        repoName: json['repoName'] as String,
        type: GitHubItemType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => GitHubItemType.commit,
        ),
        title: json['title'] as String,
        summary: json['summary'] as String? ?? '',
        author: json['author'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        url: json['url'] as String?,
      );
}

class GitHubRepoSummary {
  final String name;
  final String description;
  final String defaultBranch;
  final int starsCount;
  final int openIssuesCount;
  final bool isPrivate;
  final DateTime lastPushedAt;

  const GitHubRepoSummary({
    required this.name,
    required this.description,
    this.defaultBranch = 'main',
    this.starsCount = 0,
    this.openIssuesCount = 0,
    this.isPrivate = false,
    required this.lastPushedAt,
  });
}
