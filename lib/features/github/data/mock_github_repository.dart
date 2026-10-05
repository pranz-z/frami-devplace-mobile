import '../../../core/data/seed_demo_data.dart';
import '../domain/github_model.dart';
import 'github_repository.dart';

/// Mocked GitHub Repository
/// NOTE: Real GitHub token handling MUST stay on the backend server.
/// Mobile clients must never store permanent GitHub PATs or OAuth secrets.
class MockGithubRepository implements GithubRepository {
  @override
  Future<List<GitHubRepoSummary>> getAuthorizedRepos() async {
    await Future.delayed(const Duration(milliseconds: 60));
    return SeedDemoData.getGitHubRepos();
  }

  @override
  Future<List<GitHubActivityItem>> getRecentActivity({String? repoName, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final all = SeedDemoData.getGitHubActivity();
    if (repoName != null) {
      return all.where((a) => a.repoName == repoName).take(limit).toList();
    }
    return all.take(limit).toList();
  }

  @override
  Future<List<GitHubActivityItem>> getCommits(String repoName, {int limit = 20}) async {
    final all = await getRecentActivity(repoName: repoName, limit: limit);
    return all.where((a) => a.type == GitHubItemType.commit).toList();
  }

  @override
  Future<List<GitHubActivityItem>> getPullRequests(String repoName, {int limit = 20}) async {
    final all = await getRecentActivity(repoName: repoName, limit: limit);
    return all.where((a) => a.type == GitHubItemType.pullRequest).toList();
  }

  @override
  Future<List<GitHubActivityItem>> getIssues(String repoName, {int limit = 20}) async {
    final all = await getRecentActivity(repoName: repoName, limit: limit);
    return all.where((a) => a.type == GitHubItemType.issue).toList();
  }
}
