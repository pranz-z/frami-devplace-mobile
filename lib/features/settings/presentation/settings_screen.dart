import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../../projects/data/local_project_repository.dart';
import '../../kanban/data/local_task_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeStringProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings & Workspace Info',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Theme Switcher Card
          SketchCard(
            id: 'settings-theme',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarkerHighlight(text: 'Visual Theme'),
                const SizedBox(height: 8),
                Text(
                  'Switch between warm sketchbook paper (~#FBF6EA) and dark charcoal (~#1C1A17).',
                  style: TextStyle(fontSize: 12, color: isDark ? SketchPalette.inkMutedDark : SketchPalette.inkMutedLight),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SketchChip(
                      label: 'Light Paper',
                      isSelected: themeMode == 'light',
                      onTap: () => ref.read(themeModeStringProvider.notifier).state = 'light',
                    ),
                    const SizedBox(width: 8),
                    SketchChip(
                      label: 'Dark Charcoal',
                      isSelected: themeMode == 'dark',
                      onTap: () => ref.read(themeModeStringProvider.notifier).state = 'dark',
                    ),
                    const SizedBox(width: 8),
                    SketchChip(
                      label: 'System',
                      isSelected: themeMode == 'system',
                      onTap: () => ref.read(themeModeStringProvider.notifier).state = 'system',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Owner-only Security & Architecture Info
          SketchCard(
            id: 'settings-security',
            hasTornEdge: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Owner-Only Workspace Protection', style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your daily workspace is strictly private. Tasks, scratch notes, internal roadmaps, and calendar schedules are local to your owner account.\n\n'
                  'Only approved case study projections are published to the recruiter portfolio preview.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 10),
                SketchButton(
                  isSmall: true,
                  isSecondary: true,
                  onPressed: () {
                    ref.read(isOwnerLoggedInProvider.notifier).state = false;
                    context.go('/login');
                  },
                  child: const Text('Lock Private Workspace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Demo Data Reset
          SketchCard(
            id: 'settings-reset',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Demo Data Management', style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  'Restore original demo data (5 projects, 30+ tasks, GitHub logs, goals, and public portfolio case studies).',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SketchButton(
                  isSmall: true,
                  backgroundColor: SketchPalette.orangePencil,
                  onPressed: () async {
                    final projRepo = ref.read(projectRepositoryProvider) as LocalProjectRepository;
                    final taskRepo = ref.read(taskRepositoryProvider) as LocalTaskRepository;
                    await projRepo.resetToDemoData();
                    await taskRepo.resetToDemoData();
                    ref.invalidate(projectsProvider);
                    ref.invalidate(tasksProvider);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo data restored successfully!')),
                      );
                    }
                  },
                  child: const Text('Reload Realistic Demo Data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // About App
          const SketchCard(
            id: 'settings-about',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Developer Workplace v1.0.0', style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  '"Build privately. Track the work. Let AI help. Publish only what matters."',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Web counterpart: https://frami-devplace.vercel.app/app\nMobile adaptation built with Flutter 3.x & Material 3 custom sketchbook theme.',
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
