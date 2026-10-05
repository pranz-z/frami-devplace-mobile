import '../../../core/data/seed_demo_data.dart';
import '../../projects/domain/project_model.dart';
import '../../projects/data/project_repository.dart';
import '../domain/public_models.dart';
import 'public_portfolio_repository.dart';

/// Public Portfolio Repository
/// ARCHITECTURAL REQUIREMENT:
/// Safely creates public projections from projects that have isPublic == true.
/// It NEVER projects private fields (tasks, internal notes, plans, calendar, goals, or unapproved sections).
class SafePublicPortfolioRepository implements PublicPortfolioRepository {
  final ProjectRepository _projectRepository;
  final String _ownerId;

  SafePublicPortfolioRepository(
    this._projectRepository, {
    String ownerId = 'owner-1',
  }) : _ownerId = ownerId;

  @override
  Future<PublicProfile> getPublicProfile() async {
    return SeedDemoData.getPublicProfile();
  }

  @override
  Future<List<PublicProject>> getFeaturedProjects() async {
    final privateProjects =
        await _projectRepository.getProjects(ownerId: _ownerId);

    // Filter only projects explicitly toggled isPublic == true
    final publicOnly = privateProjects.where((p) => p.isPublic).toList();

    return publicOnly.map(_projectToPublicProjection).toList();
  }

  @override
  Future<PublicProject?> getPublicProjectById(String id) async {
    final privateProjects =
        await _projectRepository.getProjects(ownerId: _ownerId);
    final match = privateProjects.where((p) => p.id == id && p.isPublic);
    if (match.isEmpty) return null;
    return _projectToPublicProjection(match.first);
  }

  @override
  Future<List<PublicEvidence>> getEvidenceForProject(String projectId) async {
    final allEvidence = SeedDemoData.getPublicEvidence();
    return allEvidence.where((e) => e.projectId == projectId).toList();
  }

  @override
  Future<PublicContext> getPublicContext() async {
    final profile = await getPublicProfile();
    final projects = await getFeaturedProjects();
    final allEvidence = SeedDemoData.getPublicEvidence();

    // Only include evidence for currently public projects
    final publicProjectIds = projects.map((p) => p.id).toSet();
    final validEvidence = allEvidence
        .where((e) => publicProjectIds.contains(e.projectId))
        .toList();

    return PublicContext(
      profile: profile,
      projects: projects,
      evidence: validEvidence,
    );
  }

  /// Pure projector: Maps ONLY approved fields into PublicProject
  PublicProject _projectToPublicProjection(Project p) {
    return PublicProject(
      id: p.id,
      title: p.name,
      summary: p.publishSummaryApproved ? p.summary : '',
      technologies: p.publishTechApproved ? p.technologies : const [],
      architecture:
          p.publishArchitectureApproved ? p.architectureNotes : null,
      screenshots:
          p.publishScreenshotsApproved ? p.screenshotUrls : const [],
      challenges: p.publishChallengesApproved ? p.challengesNotes : null,
      outcome: p.publishOutcomeApproved ? p.outcomeNotes : null,
      publicRepoUrl: p.githubRepoName != null
          ? 'https://github.com/frami-dev/${p.githubRepoName}'
          : null,
      isFeatured: p.id == 'proj-1',
    );
  }
}
