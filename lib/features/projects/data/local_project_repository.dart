import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/seed_demo_data.dart';
import '../domain/project_model.dart';
import 'project_repository.dart';

class LocalProjectRepository implements ProjectRepository {
  static const String _projectsKey = 'frami_projects_v1';
  static const String _milestonesKey = 'frami_milestones_v1';
  static const String _plansKey = 'frami_plans_v1';
  static const String _notesKey = 'frami_notes_v1';

  final SharedPreferences _prefs;

  LocalProjectRepository(this._prefs) {
    _ensureInitialSeed();
  }

  void _ensureInitialSeed() {
    if (!_prefs.containsKey(_projectsKey)) {
      final seedProjects = SeedDemoData.getProjects();
      final seedMilestones = SeedDemoData.getMilestones();
      final seedPlans = SeedDemoData.getPlans();
      final seedNotes = SeedDemoData.getNotes();

      _prefs.setString(_projectsKey,
          jsonEncode(seedProjects.map((p) => p.toJson()).toList()));
      _prefs.setString(_milestonesKey,
          jsonEncode(seedMilestones.map((m) => m.toJson()).toList()));
      _prefs.setString(
          _plansKey, jsonEncode(seedPlans.map((p) => p.toJson()).toList()));
      _prefs.setString(
          _notesKey, jsonEncode(seedNotes.map((n) => n.toJson()).toList()));
    }
  }

  Future<void> resetToDemoData() async {
    final seedProjects = SeedDemoData.getProjects();
    final seedMilestones = SeedDemoData.getMilestones();
    final seedPlans = SeedDemoData.getPlans();
    final seedNotes = SeedDemoData.getNotes();

    await _prefs.setString(_projectsKey,
        jsonEncode(seedProjects.map((p) => p.toJson()).toList()));
    await _prefs.setString(_milestonesKey,
        jsonEncode(seedMilestones.map((m) => m.toJson()).toList()));
    await _prefs.setString(
        _plansKey, jsonEncode(seedPlans.map((p) => p.toJson()).toList()));
    await _prefs.setString(
        _notesKey, jsonEncode(seedNotes.map((n) => n.toJson()).toList()));
  }

  @override
  Future<List<Project>> getProjects({required String ownerId}) async {
    final raw = _prefs.getString(_projectsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .where((p) => p.ownerId == ownerId)
        .toList();
  }

  @override
  Future<Project?> getProjectById(String id, {required String ownerId}) async {
    final list = await getProjects(ownerId: ownerId);
    final match = list.where((p) => p.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<void> saveProject(Project project) async {
    final raw = _prefs.getString(_projectsKey);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList()
        : <Project>[];

    final index = list.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      list[index] = project;
    } else {
      list.add(project);
    }

    await _prefs.setString(
        _projectsKey, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  @override
  Future<void> deleteProject(String id, {required String ownerId}) async {
    final raw = _prefs.getString(_projectsKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .where((p) => !(p.id == id && p.ownerId == ownerId))
        .toList();

    await _prefs.setString(
        _projectsKey, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  // Milestones
  @override
  Future<List<Milestone>> getMilestones(String projectId) async {
    final raw = _prefs.getString(_milestonesKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
        .where((m) => m.projectId == projectId)
        .toList();
    return list;
  }

  @override
  Future<void> saveMilestone(Milestone milestone) async {
    final raw = _prefs.getString(_milestonesKey);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
            .toList()
        : <Milestone>[];

    final idx = list.indexWhere((m) => m.id == milestone.id);
    if (idx >= 0) {
      list[idx] = milestone;
    } else {
      list.add(milestone);
    }
    await _prefs.setString(
        _milestonesKey, jsonEncode(list.map((m) => m.toJson()).toList()));
  }

  // Plans
  @override
  Future<List<ProjectPlan>> getPlans(String projectId) async {
    final raw = _prefs.getString(_plansKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => ProjectPlan.fromJson(e as Map<String, dynamic>))
        .where((p) => p.projectId == projectId)
        .toList();
  }

  @override
  Future<void> savePlan(ProjectPlan plan) async {
    final raw = _prefs.getString(_plansKey);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => ProjectPlan.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ProjectPlan>[];
    final idx = list.indexWhere((p) => p.id == plan.id);
    if (idx >= 0) {
      list[idx] = plan;
    } else {
      list.add(plan);
    }
    await _prefs.setString(
        _plansKey, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  // Notes
  @override
  Future<List<ProjectNote>> getNotes(String projectId) async {
    final raw = _prefs.getString(_notesKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => ProjectNote.fromJson(e as Map<String, dynamic>))
        .where((n) => n.projectId == projectId)
        .toList();
  }

  @override
  Future<void> saveNote(ProjectNote note) async {
    final raw = _prefs.getString(_notesKey);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => ProjectNote.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ProjectNote>[];
    final idx = list.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      list[idx] = note;
    } else {
      list.add(note);
    }
    await _prefs.setString(
        _notesKey, jsonEncode(list.map((n) => n.toJson()).toList()));
  }
}
