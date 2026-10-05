import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/project_model.dart';

class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  String _searchQuery = '';
  ProjectWorkflowStage? _stageFilter;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workspace Projects',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Project',
            onPressed: () => _showCreateProjectDialog(context),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          final filtered = projects.where((p) {
            final matchesQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.summary.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesStage = _stageFilter == null || p.workflowStage == _stageFilter;
            return matchesQuery && matchesStage;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search projects, technologies...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SketchChip(
                            label: 'All Stages',
                            isSelected: _stageFilter == null,
                            onTap: () => setState(() => _stageFilter = null),
                          ),
                          const SizedBox(width: 6),
                          ...ProjectWorkflowStage.values.map(
                            (st) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: SketchChip(
                                label: st.label,
                                isSelected: _stageFilter == st,
                                onTap: () => setState(() => _stageFilter = st),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Project List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No projects match your filter.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: isDark ? SketchPalette.inkMutedDark : SketchPalette.inkMutedLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final project = filtered[index];
                          return _buildProjectCard(context, project);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading projects: $err')),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SketchCard(
      id: project.id,
      onTap: () => context.push('/app/projects/${project.id}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: const TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Visibility badge (Private / Public)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: project.isPublic
                      ? SketchPalette.sageGreen.withValues(alpha: 0.2)
                      : (isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: project.isPublic ? SketchPalette.sageGreen : SketchPalette.borderSubtleLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      project.isPublic ? Icons.public : Icons.lock_outline,
                      size: 12,
                      color: project.isPublic ? SketchPalette.sageGreen : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.isPublic ? 'Public' : 'Private',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: project.isPublic ? SketchPalette.sageGreen : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            project.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stage: ${project.workflowStage.label} • ${project.lifecycleStatus.label}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(project.progress * 100).toInt()}% progress',
                style: const TextStyle(fontFamily: 'Caveat', fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          HandDrawnProgressBar(
            progress: project.progress,
            color: project.isPublic ? SketchPalette.skyBlue : SketchPalette.markerYellowDark,
          ),
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: project.technologies
                  .take(4)
                  .map((t) => SketchChip(label: t))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    final summaryController = TextEditingController();
    ProjectWorkflowStage stage = ProjectWorkflowStage.idea;
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Create New Project',
            style: TextStyle(fontFamily: 'Caveat', fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(labelText: 'Short Summary'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ProjectWorkflowStage>(
                  initialValue: stage,
                  decoration: const InputDecoration(labelText: 'Workflow Stage'),
                  items: ProjectWorkflowStage.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => stage = val);
                  },
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Publish to Recruiter Portfolio?'),
                  subtitle: const Text('Can be toggled later in Publish tab', style: TextStyle(fontSize: 11)),
                  value: isPublic,
                  onChanged: (val) => setDialogState(() => isPublic = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            SketchButton(
              isSmall: true,
              onPressed: () {
                final name = titleController.text.trim();
                if (name.isNotEmpty) {
                  final now = DateTime.now().toUtc();
                  final newProj = Project(
                    id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
                    ownerId: currentOwnerId,
                    name: name,
                    summary: summaryController.text.trim(),
                    fullDescription: summaryController.text.trim(),
                    workflowStage: stage,
                    lifecycleStatus: ProjectLifecycleStatus.active,
                    isPublic: isPublic,
                    createdAt: now,
                    updatedAt: now,
                  );
                  ref.read(projectsProvider.notifier).saveProject(newProj);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}
