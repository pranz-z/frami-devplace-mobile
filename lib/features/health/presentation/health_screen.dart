import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/health_model.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(healthReportProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Project Health & Rhythm',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Score Banner
          SketchCard(
            id: 'health-main-score',
            hasTornEdge: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Text(
                  '${report.score}',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                Text(
                  report.state.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: badgeColor,
                  ),
                ),
                const SizedBox(height: 10),
                HandDrawnProgressBar(progress: report.score / 100.0, color: badgeColor, height: 12),
                const SizedBox(height: 10),
                Text(
                  report.summary,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Philosophical note on health vs raw commits
          SketchCard(
            id: 'health-philosophy',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MarkerHighlight(text: 'How Health is Scored'),
                const SizedBox(height: 6),
                Text(
                  'More commits does NOT mean better software development. Our deterministic scoring emphasizes consistency (active days out of 14), on-time milestone delivery, and task completion vs overdue drag. GitHub activity is log-scaled with low weight.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? SketchPalette.inkMutedDark : SketchPalette.inkMutedLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Factor Breakdown
          const Text('Score Breakdown', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...report.breakdown.map((item) => SketchCard(
                id: item,
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(item, style: const TextStyle(fontSize: 12)),
              )),
          const SizedBox(height: 16),

          // Suggested Next Actions
          const Text('Recommended Next Actions', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...report.suggestedNextActions.map((action) => SketchCard(
                id: action,
                borderColor: SketchPalette.markerYellowDark,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, color: SketchPalette.orangePencil),
                    const SizedBox(width: 6),
                    Expanded(child: Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  ],
                ),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
