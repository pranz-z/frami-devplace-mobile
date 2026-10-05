import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/focus_session_model.dart';
import '../../kanban/domain/task_model.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> with WidgetsBindingObserver {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 1-second ticker recalculating from DateTime.now()
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-trigger build to compute remaining time from actual current timestamp!
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusSessionProvider);
    final notifier = ref.read(focusSessionProvider.notifier);
    final tasksAsync = ref.watch(tasksProvider);
    final isFocusMode = ref.watch(isFocusModeActiveProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final remainingSec = session.getRemainingSeconds();
    final mins = remainingSec ~/ 60;
    final secs = remainingSec % 60;
    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final progress = session.getProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deep Work Focus',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Focus mode fullscreen toggle
          TextButton.icon(
            icon: Icon(isFocusMode ? Icons.fullscreen_exit : Icons.fullscreen),
            label: Text(isFocusMode ? 'Exit Focus Mode' : 'Focus Mode'),
            onPressed: () {
              ref.read(isFocusModeActiveProvider.notifier).state = !isFocusMode;
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            // Focused Task Card
            SketchCard(
              id: 'focus-task-picker',
              hasTornEdge: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Task',
                        style: TextStyle(fontFamily: 'Caveat', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => _showTaskPicker(context, tasksAsync.value ?? []),
                        child: const Text('Change Task'),
                      ),
                    ],
                  ),
                  Text(
                    session.taskTitle ?? 'No specific task linked (General Deep Work)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Large Circular Timestamp Timer Display
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      session.status == FocusSessionStatus.running
                          ? SketchPalette.markerYellowDark
                          : SketchPalette.sageGreen,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: isDark ? SketchPalette.inkCream : SketchPalette.inkDark,
                          ),
                        ),
                        Text(
                          session.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: session.status == FocusSessionStatus.running
                                ? SketchPalette.orangePencil
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Duration Presets (15 / 25 / 50 min)
            if (session.status == FocusSessionStatus.idle) ...[
              const Text('Duration Presets', style: TextStyle(fontFamily: 'Caveat', fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [15, 25, 50].map((m) {
                  final isSelected = session.targetDurationSeconds == m * 60;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: SketchChip(
                      label: '$m min',
                      isSelected: isSelected,
                      onTap: () => notifier.setDurationMinutes(m),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons (Start, Pause, Resume, +5 min, Complete)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (session.status == FocusSessionStatus.idle)
                  SketchButton(
                    icon: Icons.play_arrow,
                    onPressed: () => notifier.start(),
                    child: const Text('Start Focus Session'),
                  )
                else if (session.status == FocusSessionStatus.running) ...[
                  SketchButton(
                    icon: Icons.pause,
                    isSecondary: true,
                    onPressed: () => notifier.pause(),
                    child: const Text('Pause'),
                  ),
                  const SizedBox(width: 12),
                  SketchButton(
                    icon: Icons.add,
                    isSecondary: true,
                    onPressed: () => notifier.extend(5),
                    child: const Text('+5 min'),
                  ),
                  const SizedBox(width: 12),
                  SketchButton(
                    icon: Icons.check,
                    onPressed: () => notifier.complete(),
                    child: const Text('Done'),
                  ),
                ] else if (session.status == FocusSessionStatus.paused) ...[
                  SketchButton(
                    icon: Icons.play_arrow,
                    onPressed: () => notifier.resume(),
                    child: const Text('Resume'),
                  ),
                  const SizedBox(width: 12),
                  SketchButton(
                    icon: Icons.refresh,
                    isSecondary: true,
                    onPressed: () => notifier.reset(),
                    child: const Text('Reset'),
                  ),
                ] else ...[
                  SketchButton(
                    icon: Icons.refresh,
                    onPressed: () => notifier.reset(),
                    child: const Text('Start New Session'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // Invariant explanation note
            SketchCard(
              id: 'timer-explanation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Timestamp-Based Accuracy Invariant',
                      style: TextStyle(fontFamily: 'Caveat', fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'This timer stores startedAt, pausedAt, and accumulated pause duration. It re-computes elapsed time directly from the system clock on every tick and AppLifecycleState.resumed. It never drifts or loses time when backgrounded.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? SketchPalette.inkMutedDark : SketchPalette.inkMutedLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskPicker(BuildContext context, List<Task> tasks) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pick a Task to Focus On', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...tasks.where((t) => t.status != TaskStatus.done).map((t) => ListTile(
                title: Text(t.title),
                subtitle: Text('Column: ${t.status.label} • Priority: ${t.priority.label}'),
                onTap: () {
                  ref.read(focusSessionProvider.notifier).selectTask(t);
                  Navigator.pop(ctx);
                },
              )),
        ],
      ),
    );
  }
}
