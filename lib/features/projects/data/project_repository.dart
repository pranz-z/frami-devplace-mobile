import '../domain/project_model.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects({required String ownerId});
  Future<Project?> getProjectById(String id, {required String ownerId});
  Future<void> saveProject(Project project);
  Future<void> deleteProject(String id, {required String ownerId});

  // Milestones
  Future<List<Milestone>> getMilestones(String projectId);
  Future<void> saveMilestone(Milestone milestone);

  // Plans & Notes
  Future<List<ProjectPlan>> getPlans(String projectId);
  Future<void> savePlan(ProjectPlan plan);
  Future<List<ProjectNote>> getNotes(String projectId);
  Future<void> saveNote(ProjectNote note);
}
