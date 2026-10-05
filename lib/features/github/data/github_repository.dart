import '../domain/github_model.dart';

abstract class GithubRepository {
  Future<List<GitHubRepoSummary>> getAuthorizedRepos();
  Future<List<GitHubActivityItem>> getRecentActivity({String? repoName, int limit = 20});
  Future<List<GitHubActivityItem>> getCommits(String repoName, {int limit = 20});
  Future<List<GitHubActivityItem>> getPullRequests(String repoName, {int limit = 20});
  Future<List<GitHubActivityItem>> getIssues(String repoName, {int limit = 20});
}
