import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/task_model.dart';
import '../../home/widgets/create_task_modal.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen> {
  late PageController _pageController;
  int _activeColumnIndex = 1; // Default to Todo column

  final List<TaskStatus> _columns = [
    TaskStatus.backlog,
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.inReview,
    TaskStatus.done,
  ];

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _activeColumnIndex, viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const CreateTaskModal(),
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (allTasks) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: SketchCard(
                  id: 'kanban-intro',
                  backgroundColor: SketchPalette.charcoal,
                  borderColor: SketchPalette.charcoal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXECUTION',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: SketchPalette.inkMutedDark,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Task management',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: SketchPalette.inkCream),
                      ),
                    ],
                  ),
                ),
              ),
              // Column Tab Strip / Indicator
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: List.generate(_columns.length, (idx) {
                    final col = _columns[idx];
                    final count = allTasks.where((t) => t.status == col).length;
                    final isCurrent = _activeColumnIndex == idx;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2),
                      child: SketchChip(
                        label: '${col.label} ($count)',
                        isSelected: isCurrent,
                        onTap: () {
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),

              // Horizontally Paged Board
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _columns.length,
                  onPageChanged: (idx) =>
                      setState(() => _activeColumnIndex = idx),
                  itemBuilder: (context, colIndex) {
                    final status = _columns[colIndex];
                    final colTasks = allTasks
                        .where((t) => t.status == status)
                        .toList()
                      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

                    return _buildColumnView(context, status, colTasks);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildColumnView(
      BuildContext context, TaskStatus status, List<Task> tasks) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        // Move task into this column at end
        ref.read(tasksProvider.notifier).moveTask(
              taskId: details.data.id,
              targetStatus: status,
              targetIndex: tasks.length,
            );
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: isHovered
                ? SketchPalette.markerYellow.withValues(alpha: 0.12)
                : (isDark
                    ? SketchPalette.paperSurfaceDark.withValues(alpha: 0.5)
                    : SketchPalette.paperSurfaceLight.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovered
                  ? SketchPalette.markerYellowDark
                  : (isDark
                      ? SketchPalette.borderSubtleDark
                      : SketchPalette.borderSubtleLight),
              width: isHovered ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Column Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status.label,
                      style: const TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${tasks.length} cards',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Task card drag & drop list
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'Drag cards here',
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 16,
                            color: isDark
                                ? SketchPalette.inkMutedDark
                                : SketchPalette.inkMutedLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildDraggableCard(context, task, index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableCard(BuildContext context, Task task, int index) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 280,
          child: Opacity(
            opacity: 0.9,
            child: _buildCardContent(context, task, isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(context, task),
      ),
      child: DragTarget<Task>(
        onWillAcceptWithDetails: (details) => details.data.id != task.id,
        onAcceptWithDetails: (details) {
          ref.read(tasksProvider.notifier).moveTask(
                taskId: details.data.id,
                targetStatus: task.status,
                targetIndex: index,
              );
        },
        builder: (context, candidate, rejected) {
          return _buildCardContent(context, task);
        },
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Task task,
      {bool isDragging = false}) {
    final isDone = task.status == TaskStatus.done;

    return SketchCard(
      id: task.id,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      borderColor: isDragging ? SketchPalette.markerYellowDark : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              SketchChip(
                label: task.priority.label,
                color: task.priority == TaskPriority.urgent
                    ? SketchPalette.danger.withValues(alpha: 0.2)
                    : null,
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.dueDate != null
                    ? 'Due: ${task.dueDate!.month}/${task.dueDate!.day}'
                    : 'Unscheduled',
                style: TextStyle(
                  fontSize: 11,
                  color: task.isOverdue ? SketchPalette.danger : Colors.grey,
                  fontWeight:
                      task.isOverdue ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (task.completedAt != null)
                Text(
                  'Done ${task.completedAt!.month}/${task.completedAt!.day}',
                  style: const TextStyle(
                      fontSize: 11, color: SketchPalette.sageGreen),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
