import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../../focus/domain/focus_session_model.dart';
import '../../kanban/domain/task_model.dart';
import '../../health/domain/health_model.dart';
import '../widgets/create_task_modal.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final focusSession = ref.watch(focusSessionProvider);
    final healthReport = ref.watch(healthReportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s Workspace',
          style: TextStyle(
              fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Quick add task',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const CreateTaskModal(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'More menu',
            onPressed: () => _showMoreSheet(context),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          final dueTodayTasks = tasks
              .where((t) => t.isDueToday && t.status != TaskStatus.done)
              .toList();
          final overdueTasks = tasks.where((t) => t.isOverdue).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tasksProvider);
              ref.invalidate(projectsProvider);
            },
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // Greeting and Date
                _buildGreetingCard(context),
                const SizedBox(height: 12),

                // Active Focus Card
                _buildFocusCard(context, ref, focusSession),
                const SizedBox(height: 12),

                // Health & Rhythm Summary
                _buildHealthCard(context, healthReport),
                const SizedBox(height: 14),

                // Overdue Tasks (if any)
                if (overdueTasks.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 18, color: SketchPalette.danger),
                      const SizedBox(width: 6),
                      Text(
                        'Overdue (${overdueTasks.length})',
                        style: const TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: SketchPalette.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...overdueTasks.map(
                      (t) => _buildTaskItem(context, ref, t, isOverdue: true)),
                  const SizedBox(height: 14),
                ],

                // Tasks Due Today
                SketchSectionHeading(
                  eyebrow: 'Execution',
                  title: 'Today’s tasks',
                  trailing: TextButton(
                    onPressed: () => context.go('/app/kanban'),
                    child: const Text('View board'),
                  ),
                ),
                const SizedBox(height: 6),
                if (dueTodayTasks.isEmpty)
                  SketchCard(
                    id: 'empty-today',
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No remaining tasks due today. Great job keeping clean!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: isDark
                              ? SketchPalette.inkMutedDark
                              : SketchPalette.inkMutedLight,
                        ),
                      ),
                    ),
                  )
                else
                  ...dueTodayTasks.map((t) => _buildTaskItem(context, ref, t)),

                const SizedBox(height: 16),
                const DoodleDivider(),
                const SizedBox(height: 8),

                // Quick Actions
                const SketchSectionHeading(
                    eyebrow: 'Shortcuts', title: 'Quick actions'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SketchButton(
                      isSmall: true,
                      icon: Icons.add,
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const CreateTaskModal(),
                      ),
                      child: const Text('New Task'),
                    ),
                    SketchButton(
                      isSmall: true,
                      isSecondary: true,
                      icon: Icons.timer_outlined,
                      onPressed: () => context.go('/app/focus'),
                      child: const Text('Start Focus'),
                    ),
                    SketchButton(
                      isSmall: true,
                      isSecondary: true,
                      icon: Icons.auto_awesome,
                      onPressed: () => context.go('/app/ai'),
                      child: const Text('Ask Workspace AI'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return SketchCard(
      id: 'greeting',
      hasTornEdge: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORKSPACE • ${DateFormat('EEEE, MMMM d').format(DateTime.now())}'
                .toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.25,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Expanded(child: MarkerHighlight(text: 'Hello, Frami ✦')),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SketchPalette.sageGreen.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: SketchPalette.sageGreen, width: 1),
                ),
                child: const Text('PRIVATE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep building privately. When ready, project approved case studies to your public portfolio.',
            style: TextStyle(fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCard(
      BuildContext context, WidgetRef ref, FocusSession session) {
    final remainingSec = session.getRemainingSeconds();
    final mins = remainingSec ~/ 60;
    final secs = remainingSec % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isRunning = session.status == FocusSessionStatus.running;

    return SketchCard(
      id: 'focus-card',
      borderColor: isRunning ? SketchPalette.orangePencil : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SketchPalette.markerYellow.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRunning ? Icons.hourglass_top : Icons.timer,
              color: SketchPalette.orangePencil,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.taskTitle ?? 'Deep Work Focus Session',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Remaining: $timeStr (${session.status.name})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          SketchButton(
            isSmall: true,
            onPressed: () => context.go('/app/focus'),
            child: Text(isRunning ? 'Open' : 'Start'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, HealthReport report) {
    Color badgeColor;
    switch (report.state) {
      case HealthState.thriving:
        badgeColor = SketchPalette.success;
        break;
      case HealthState.steady:
        badgeColor = SketchPalette.skyBlue;
        break;
      case HealthState.needsAttention:
        badgeColor = SketchPalette.warning;
        break;
      case HealthState.stalled:
        badgeColor = SketchPalette.danger;
        break;
    }

    return SketchCard(
      id: 'health-summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite,
                      size: 16, color: SketchPalette.dustyRose),
                  const SizedBox(width: 6),
                  Text(
                    'Workspace Rhythm Score',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontFamily: 'Caveat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: badgeColor, width: 1.2),
                ),
                child: Text(
                  '${report.score}/100 • ${report.state.label}',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          HandDrawnProgressBar(
              progress: report.score / 100.0, color: badgeColor),
          const SizedBox(height: 8),
          Text(
            report.summary,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, WidgetRef ref, Task task,
      {bool isOverdue = false}) {
    return SketchCard(
      id: task.id,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderColor: isOverdue ? SketchPalette.danger : null,
      child: Row(
        children: [
          Checkbox(
            value: task.status == TaskStatus.done,
            activeColor: SketchPalette.sageGreen,
            onChanged: (bool? val) {
              final newStatus =
                  (val == true) ? TaskStatus.done : TaskStatus.todo;
              ref.read(tasksProvider.notifier).moveTask(
                    taskId: task.id,
                    targetStatus: newStatus,
                    targetIndex: 0,
                  );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
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
    );
  }

  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('GitHub Activity & Repos'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/github');
                },
              ),
              ListTile(
                leading: const Icon(Icons.monitor_heart_outlined),
                title: const Text('Project Health Score'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/health');
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Goals & Snapshot Reports'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/goals');
                },
              ),
              ListTile(
                leading: const Icon(Icons.public),
                title: const Text('Recruiter Portfolio Preview'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/portfolio');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings & Data Reset'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/settings');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
