import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/data/seed_demo_data.dart';
import '../domain/task_model.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  static const String _tasksKey = 'frami_tasks_v1';
  final SharedPreferences _prefs;

  LocalTaskRepository(this._prefs) {
    _ensureInitialSeed();
  }

  void _ensureInitialSeed() {
    if (!_prefs.containsKey(_tasksKey)) {
      final seedTasks = SeedDemoData.getTasks();
      _prefs.setString(
          _tasksKey, jsonEncode(seedTasks.map((t) => t.toJson()).toList()));
    }
  }

  Future<void> resetToDemoData() async {
    final seedTasks = SeedDemoData.getTasks();
    await _prefs.setString(
        _tasksKey, jsonEncode(seedTasks.map((t) => t.toJson()).toList()));
  }

  @override
  Future<List<Task>> getTasks({required String ownerId}) async {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .where((t) => t.ownerId == ownerId)
        .toList();
  }

  @override
  Future<Task?> getTaskById(String id, {required String ownerId}) async {
    final list = await getTasks(ownerId: ownerId);
    final match = list.where((t) => t.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<void> saveTask(Task task) async {
    final raw = _prefs.getString(_tasksKey);
    final list = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList()
        : <Task>[];

    final index = list.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      list[index] = task;
    } else {
      list.add(task);
    }

    await _prefs.setString(
        _tasksKey, jsonEncode(list.map((t) => t.toJson()).toList()));
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final raw = _prefs.getString(_tasksKey);
    final existing = raw != null
        ? (jsonDecode(raw) as List<dynamic>)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList()
        : <Task>[];

    final updatedMap = {for (var t in tasks) t.id: t};
    final merged = <Task>[];

    for (final ex in existing) {
      if (updatedMap.containsKey(ex.id)) {
        merged.add(updatedMap[ex.id]!);
        updatedMap.remove(ex.id);
      } else {
        merged.add(ex);
      }
    }
    // Add any newly created tasks
    merged.addAll(updatedMap.values);

    await _prefs.setString(
        _tasksKey, jsonEncode(merged.map((t) => t.toJson()).toList()));
  }

  @override
  Future<void> deleteTask(String id, {required String ownerId}) async {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .where((t) => !(t.id == id && t.ownerId == ownerId))
        .toList();

    await _prefs.setString(
        _tasksKey, jsonEncode(list.map((t) => t.toJson()).toList()));
  }
}
