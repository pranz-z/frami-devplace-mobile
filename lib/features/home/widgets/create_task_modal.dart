import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../../kanban/domain/task_model.dart';

class CreateTaskModal extends ConsumerStatefulWidget {
  final DateTime? initialDueDate;
  final String? initialProjectId;

  const CreateTaskModal({
    super.key,
    this.initialDueDate,
    this.initialProjectId,
  });

  @override
  ConsumerState<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends ConsumerState<CreateTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  String _projectId = 'proj-1';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    if (widget.initialProjectId != null) {
      _projectId = widget.initialProjectId!;
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newTask = Task(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      ownerId: currentOwnerId,
      projectId: _projectId,
      title: title,
      description: _descController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate?.toUtc(),
      createdAt: DateTime.now().toUtc(),
    );

    ref.read(tasksProvider.notifier).saveTask(newTask);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF26231E) : const Color(0xFFFFFDF8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add New Task',
                  style: TextStyle(fontFamily: 'Caveat', fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'e.g. Implement edge case validation',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Notes & context (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (projects.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue: projects.any((p) => p.id == _projectId) ? _projectId : projects.first.id,
                decoration: const InputDecoration(labelText: 'Project'),
                items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _projectId = val);
                },
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: TaskPriority.values
                        .map((pr) => DropdownMenuItem(value: pr, child: Text(pr.label)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<TaskStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Column / Status'),
                    items: TaskStatus.values
                        .map((st) => DropdownMenuItem(value: st, child: Text(st.label)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dueDate == null
                      ? 'No due date set'
                      : 'Due: ${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 13),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month, size: 16),
                  label: Text(_dueDate == null ? 'Set Due Date' : 'Change'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SketchButton(
              onPressed: _submit,
              child: const Text('Save Task to Workspace'),
            ),
          ],
        ),
      ),
    );
  }
}
