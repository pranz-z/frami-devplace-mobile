import '../domain/public_models.dart';

abstract class PublicPortfolioRepository {
  Future<PublicProfile> getPublicProfile();
  Future<List<PublicProject>> getFeaturedProjects();
  Future<PublicProject?> getPublicProjectById(String id);
  Future<List<PublicEvidence>> getEvidenceForProject(String projectId);
  Future<PublicContext> getPublicContext();
}
