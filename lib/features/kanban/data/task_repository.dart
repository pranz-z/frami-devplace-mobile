import '../domain/task_model.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks({required String ownerId});
  Future<Task?> getTaskById(String id, {required String ownerId});
  Future<void> saveTask(Task task);
  Future<void> saveTasks(List<Task> tasks);
  Future<void> deleteTask(String id, {required String ownerId});
}
