import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/data/seed_demo_data.dart';
import '../domain/goal_model.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = SeedDemoData.getGoals();
    final report = SeedDemoData.getSnapshotReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goals & Snapshot Reports',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Active Goals Section
          const Text('Active Developer Goals', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...goals.map((g) => _buildGoalCard(context, g)),
          const SizedBox(height: 16),
          const DoodleDivider(),
          const SizedBox(height: 12),

          // Periodic Snapshot Report Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Snapshot', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
              Text(report.periodName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          SketchCard(
            id: 'snapshot-card',
            hasTornEdge: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Focus Logged', '${report.focusMinutesLogged}m'),
                    _buildStatCol('Tasks Done', '${report.tasksCompletedCount}'),
                    _buildStatCol('Git Commits', '${report.commitsPushedCount}'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Daily Focus Cadence (Last 7 Days)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSimpleChart(context, report.dailyFocusMinutes),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    return SketchCard(
      id: goal.id,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              SketchChip(label: goal.cadence.label),
            ],
          ),
          if (goal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(goal.description, style: const TextStyle(fontSize: 12)),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${goal.targetDate.month}/${goal.targetDate.day}/${goal.targetDate.year}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                '${(goal.currentProgress * 100).toInt()}%',
                style: const TextStyle(fontFamily: 'Caveat', fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          HandDrawnProgressBar(progress: goal.currentProgress),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Caveat', fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSimpleChart(BuildContext context, List<int> dailyMinutes) {
    final maxVal = dailyMinutes.reduce((a, b) => a > b ? a : b).toDouble();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(dailyMinutes.length, (idx) {
          final val = dailyMinutes[idx];
          final heightRatio = maxVal > 0 ? (val / maxVal) : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${val}m', style: const TextStyle(fontSize: 9, color: Colors.grey)),
              const SizedBox(height: 2),
              Container(
                width: 18,
                height: 55 * heightRatio + 4,
                decoration: BoxDecoration(
                  color: SketchPalette.markerYellowDark,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: SketchPalette.borderLight, width: 1),
                ),
              ),
              const SizedBox(height: 4),
              Text(days[idx % 7], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          );
        }),
      ),
    );
  }
}
