import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../../kanban/domain/task_model.dart';
import '../../home/widgets/create_task_modal.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth =
      DateTime.utc(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  String _filter = 'All'; // 'All', 'Tasks', 'Milestones'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime.utc(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workspace Calendar',
          style: TextStyle(
              fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Jump to today',
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _currentMonth = DateTime.utc(now.year, now.month, 1);
                _selectedDate = DateTime.utc(now.year, now.month, now.day);
              });
            },
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (allTasks) {
          final unscheduledTasks =
              allTasks.where((t) => t.dueDate == null).toList();

          return Column(
            children: [
              // Month Switcher Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: SketchCard(
                  id: 'calendar-month-switcher',
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime.utc(
                              _currentMonth.year,
                              _currentMonth.month - 1,
                              1,
                            );
                          });
                        },
                      ),
                      Text(
                        '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                        style: const TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _currentMonth = DateTime.utc(
                              _currentMonth.year,
                              _currentMonth.month + 1,
                              1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    SketchChip(
                      label: 'All Items',
                      isSelected: _filter == 'All',
                      onTap: () => setState(() => _filter = 'All'),
                    ),
                    const SizedBox(width: 6),
                    SketchChip(
                      label: 'Tasks Only',
                      isSelected: _filter == 'Tasks',
                      onTap: () => setState(() => _filter = 'Tasks'),
                    ),
                    const SizedBox(width: 6),
                    SketchChip(
                      label: 'Milestones',
                      isSelected: _filter == 'Milestones',
                      onTap: () => setState(() => _filter = 'Milestones'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Month Grid
              _buildMonthGrid(allTasks),

              const DoodleDivider(height: 16),

              // Day Agenda & Unscheduled Tray Header
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDayAgendaSection(context, allTasks),
                    const SizedBox(height: 16),
                    _buildUnscheduledTray(context, unscheduledTasks),
                    const SizedBox(height: 24),
                  ],
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

  Widget _buildMonthGrid(List<Task> allTasks) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfWeek =
        DateTime.utc(_currentMonth.year, _currentMonth.month, 1)
            .weekday; // 1 = Mon
    final offset = (firstDayOfWeek - 1) % 7;

    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SketchCard(
      id: 'calendar-month-grid',
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: weekDays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontFamily: 'Caveat',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // Calendar months can span six weeks.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - offset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final cellDate = DateTime.utc(
                  _currentMonth.year, _currentMonth.month, dayNumber);
              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == cellDate.year &&
                  _selectedDate!.month == cellDate.month &&
                  _selectedDate!.day == cellDate.day;

              // Count tasks due on this date
              final tasksOnDate = allTasks.where((t) {
                if (t.dueDate == null) return false;
                return t.dueDate!.year == cellDate.year &&
                    t.dueDate!.month == cellDate.month &&
                    t.dueDate!.day == cellDate.day;
              }).toList();

              return DragTarget<Task>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  // Reschedule task to this date
                  final updated = details.data.copyWith(dueDate: cellDate);
                  ref.read(tasksProvider.notifier).saveTask(updated);
                  setState(() => _selectedDate = cellDate);
                },
                builder: (context, candidate, rejected) {
                  final isHovered = candidate.isNotEmpty;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDate = cellDate);
                      _showDayAgendaSheet(context, cellDate, tasksOnDate);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? SketchPalette.markerYellow.withValues(alpha: 0.3)
                            : (isHovered
                                ? SketchPalette.skyBlue.withValues(alpha: 0.2)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? SketchPalette.borderLight
                              : (isHovered
                                  ? SketchPalette.skyBlue
                                  : Colors.transparent),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (tasksOnDate.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: tasksOnDate.any((t) => t.isOverdue)
                                        ? SketchPalette.danger
                                        : SketchPalette.sageGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (tasksOnDate.length > 1) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    '${tasksOnDate.length}',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayAgendaSection(BuildContext context, List<Task> allTasks) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final dateTasks = allTasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == _selectedDate!.year &&
          t.dueDate!.month == _selectedDate!.month &&
          t.dueDate!.day == _selectedDate!.day;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agenda for ${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
              style: const TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SketchButton(
              isSmall: true,
              icon: Icons.add,
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) =>
                    CreateTaskModal(initialDueDate: _selectedDate),
              ),
              child: const Text('Add on Date'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (dateTasks.isEmpty)
          const Text('No scheduled items on this date.',
              style: TextStyle(fontSize: 12, color: Colors.grey))
        else
          ...dateTasks.map((t) => _buildAgendaTaskCard(context, t)),
      ],
    );
  }

  Widget _buildAgendaTaskCard(BuildContext context, Task t) {
    return SketchCard(
      id: 'agenda-${t.id}',
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: t.status == TaskStatus.done,
            activeColor: SketchPalette.sageGreen,
            onChanged: (val) {
              final next = (val == true) ? TaskStatus.done : TaskStatus.todo;
              ref.read(tasksProvider.notifier).moveTask(
                    taskId: t.id,
                    targetStatus: next,
                    targetIndex: 0,
                  );
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    decoration: t.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                    'Status: ${t.status.label} • Priority: ${t.priority.label}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar, size: 18),
            tooltip: 'Reschedule',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: t.dueDate ?? DateTime.now(),
                firstDate: DateTime(2025),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                final updated = t.copyWith(dueDate: picked.toUtc());
                ref.read(tasksProvider.notifier).saveTask(updated);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnscheduledTray(BuildContext context, List<Task> unscheduled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Unscheduled Tray (${unscheduled.length})',
              style: const TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const Text('Drag onto any date',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 6),
        if (unscheduled.isEmpty)
          const Text('All tasks are scheduled!',
              style: TextStyle(fontSize: 12, color: Colors.grey))
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: unscheduled.take(8).map((t) {
                return LongPressDraggable<Task>(
                  data: t,
                  feedback: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 180,
                      child:
                          SketchCard(id: 'drag-${t.id}', child: Text(t.title)),
                    ),
                  ),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 8),
                    child: SketchCard(
                      id: 'tray-${t.id}',
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(t.priority.label,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showDayAgendaSheet(
      BuildContext context, DateTime date, List<Task> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? SketchPalette.paperCardDark
                : SketchPalette.paperCardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agenda: ${date.month}/${date.day}/${date.year}',
                    style: const TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No tasks due on this date.')),
                )
              else
                ...tasks.map((t) => ListTile(
                      title: Text(t.title),
                      subtitle: Text(t.status.label),
                      trailing: Checkbox(
                        value: t.status == TaskStatus.done,
                        onChanged: (val) {
                          final next =
                              (val == true) ? TaskStatus.done : TaskStatus.todo;
                          ref.read(tasksProvider.notifier).moveTask(
                              taskId: t.id, targetStatus: next, targetIndex: 0);
                          Navigator.pop(ctx);
                        },
                      ),
                    )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SketchButton(
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CreateTaskModal(initialDueDate: date),
                    );
                  },
                  child: const Text('Add Task on this Date'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month - 1];
  }
}
