import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/project_model.dart';
import '../../kanban/domain/task_model.dart';
import '../../home/widgets/create_task_modal.dart';
import '../../github/domain/github_model.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Overview',
    'Tasks',
    'Milestones',
    'Plans',
    'Notes',
    'Tech',
    'Screenshots',
    'GitHub',
    'Publish',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return projectsAsync.when(
      data: (projects) {
        final project = projects.firstWhere(
          (p) => p.id == widget.projectId,
          orElse: () => Project(
            id: widget.projectId,
            ownerId: currentOwnerId,
            name: 'Project Details',
            summary: '',
            fullDescription: '',
            workflowStage: ProjectWorkflowStage.building,
            lifecycleStatus: ProjectLifecycleStatus.active,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              project.name,
              style: const TextStyle(fontFamily: 'Caveat', fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: project.isPublic
                      ? SketchPalette.sageGreen.withValues(alpha: 0.2)
                      : (isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: project.isPublic ? SketchPalette.sageGreen : SketchPalette.borderSubtleLight,
                  ),
                ),
                child: Center(
                  child: Text(
                    project.isPublic ? 'Public' : 'Private',
                    style: TextStyle(
                      fontFamily: 'Caveat',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: project.isPublic ? SketchPalette.sageGreen : null,
                    ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: isDark ? SketchPalette.inkCream : SketchPalette.inkDark,
              indicatorColor: SketchPalette.markerYellowDark,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontFamily: 'Caveat', fontSize: 17, fontWeight: FontWeight.bold),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, project),
              _buildTasksTab(context, project),
              _buildMilestonesTab(context, project),
              _buildPlansTab(context, project),
              _buildNotesTab(context, project),
              _buildTechTab(context, project),
              _buildScreenshotsTab(context, project),
              _buildGitHubTab(context, project),
              _buildPublishTab(context, project),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  // 1. OVERVIEW TAB
  Widget _buildOverviewTab(BuildContext context, Project project) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SketchCard(
          id: 'proj-overview-${project.id}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MarkerHighlight(text: 'Workflow Stage & Lifecycle'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stage: ${project.workflowStage.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Status: ${project.lifecycleStatus.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Overall Progress:'),
                  Text(
                    '${(project.progress * 100).toInt()}%',
                    style: const TextStyle(fontFamily: 'Caveat', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              HandDrawnProgressBar(progress: project.progress),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SketchCard(
          id: 'proj-desc-${project.id}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description', style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                project.fullDescription.isNotEmpty ? project.fullDescription : project.summary,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SketchCard(
          id: 'proj-stage-kanban-${project.id}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stage Progression',
                style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProjectWorkflowStage.values.map((stage) {
                  final isCurrent = project.workflowStage == stage;
                  return InkWell(
                    onTap: () {
                      final updated = project.copyWith(workflowStage: stage);
                      ref.read(projectsProvider.notifier).saveProject(updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? SketchPalette.markerYellow.withValues(alpha: 0.3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? SketchPalette.borderLight : SketchPalette.borderSubtleLight,
                          width: isCurrent ? 1.6 : 1.0,
                        ),
                      ),
                      child: Text(
                        stage.label,
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. TASKS TAB (Filtered for this project)
  Widget _buildTasksTab(BuildContext context, Project project) {
    final tasksAsync = ref.watch(tasksProvider);
    final tasks = (tasksAsync.value ?? []).where((t) => t.projectId == project.id).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tasks (${tasks.length})', style: const TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
              SketchButton(
                isSmall: true,
                icon: Icons.add,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => CreateTaskModal(initialProjectId: project.id),
                ),
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text('No tasks created for this project yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, i) {
                    final t = tasks[i];
                    return SketchCard(
                      id: t.id,
                      margin: const EdgeInsets.symmetric(vertical: 4),
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
                                    fontWeight: FontWeight.w600,
                                    decoration: t.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                Text('Column: ${t.status.label} • Priority: ${t.priority.label}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 3. MILESTONES TAB
  Widget _buildMilestonesTab(BuildContext context, Project project) {
    final repo = ref.watch(projectRepositoryProvider);

    return FutureBuilder<List<Milestone>>(
      future: repo.getMilestones(project.id),
      builder: (context, snap) {
        final milestones = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Milestones', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
                SketchButton(
                  isSmall: true,
                  icon: Icons.add,
                  onPressed: () => _showAddMilestoneDialog(context, project),
                  child: const Text('New Milestone'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (milestones.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No milestones yet.')))
            else
              ...milestones.map((m) {
                return SketchCard(
                  id: m.id,
                  child: Row(
                    children: [
                      Icon(
                        m.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: m.isCompleted ? SketchPalette.sageGreen : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            if (m.description.isNotEmpty)
                              Text(m.description, style: const TextStyle(fontSize: 12)),
                            Text(
                              'Due: ${m.dueDate.year}-${m.dueDate.month.toString().padLeft(2, '0')}-${m.dueDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // 4. PLANS TAB
  Widget _buildPlansTab(BuildContext context, Project project) {
    final repo = ref.watch(projectRepositoryProvider);

    return FutureBuilder<List<ProjectPlan>>(
      future: repo.getPlans(project.id),
      builder: (context, snap) {
        final plans = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Architecture & Phase Plans', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (plans.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No plans recorded.')))
            else
              ...plans.map((p) => SketchCard(
                    id: p.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: const TextStyle(fontFamily: 'Caveat', fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(p.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }

  // 5. NOTES TAB
  Widget _buildNotesTab(BuildContext context, Project project) {
    final repo = ref.watch(projectRepositoryProvider);

    return FutureBuilder<List<ProjectNote>>(
      future: repo.getNotes(project.id),
      builder: (context, snap) {
        final notes = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Developer Notes (Private)', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (notes.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No notes added yet.')))
            else
              ...notes.map((n) => SketchCard(
                    id: n.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: const TextStyle(fontFamily: 'Caveat', fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(n.content, style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }

  // 6. TECH TAB
  Widget _buildTechTab(BuildContext context, Project project) {
    final techController = TextEditingController();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Technologies & Stack', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.technologies.map((t) {
            return Chip(
              label: Text(t),
              onDeleted: () {
                final updatedTech = List<String>.from(project.technologies)..remove(t);
                final updated = project.copyWith(technologies: updatedTech);
                ref.read(projectsProvider.notifier).saveProject(updated);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: techController,
                decoration: const InputDecoration(hintText: 'Add technology (e.g. Redis, WebSockets)'),
              ),
            ),
            const SizedBox(width: 8),
            SketchButton(
              isSmall: true,
              onPressed: () {
                final val = techController.text.trim();
                if (val.isNotEmpty) {
                  final updatedTech = List<String>.from(project.technologies)..add(val);
                  final updated = project.copyWith(technologies: updatedTech);
                  ref.read(projectsProvider.notifier).saveProject(updated);
                  techController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  // 7. SCREENSHOTS TAB
  Widget _buildScreenshotsTab(BuildContext context, Project project) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Screenshots & Media', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (project.screenshotUrls.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No screenshots uploaded.')))
        else
          ...project.screenshotUrls.map((url) => SketchCard(
                id: url,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    url,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey.withValues(alpha: 0.2),
                      child: const Center(child: Text('Screenshot preview')),
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  // 8. GITHUB TAB
  Widget _buildGitHubTab(BuildContext context, Project project) {
    final ghRepo = ref.watch(githubRepositoryProvider);

    return FutureBuilder<List<GitHubActivityItem>>(
      future: ghRepo.getRecentActivity(repoName: project.githubRepoName),
      builder: (context, snap) {
        final items = snap.data ?? [];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Icon(Icons.code),
                const SizedBox(width: 8),
                Text(
                  project.githubRepoName != null ? 'Repo: ${project.githubRepoName}' : 'No GitHub repo linked',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No commits or activity found.')))
            else
              ...items.map((it) => SketchCard(
                    id: it.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(it.type.name.toUpperCase(),
                                style: const TextStyle(fontFamily: 'Caveat', fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${it.timestamp.month}/${it.timestamp.day}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(it.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        if (it.summary.isNotEmpty)
                          Text(it.summary, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )),
          ],
        );
      },
    );
  }

  // 9. PUBLISH TAB & SAFE PROJECTION BUILDER
  Widget _buildPublishTab(BuildContext context, Project project) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SketchCard(
          id: 'publish-card',
          hasTornEdge: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MarkerHighlight(text: 'Public Portfolio Exposure'),
                  Switch(
                    value: project.isPublic,
                    onChanged: (val) {
                      final updated = project.copyWith(isPublic: val);
                      ref.read(projectsProvider.notifier).saveProject(updated);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                project.isPublic
                    ? 'This project is live in your public portfolio. Only approved fields below are projected.'
                    : 'This project is completely PRIVATE. It will not appear in the recruiter portfolio or public AI concierge.',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Approved Projection Fields',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        _buildApprovalToggle(
          title: 'Project Summary',
          value: project.publishSummaryApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishSummaryApproved: v)),
        ),
        _buildApprovalToggle(
          title: 'Technologies Stack',
          value: project.publishTechApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishTechApproved: v)),
        ),
        _buildApprovalToggle(
          title: 'Architecture Blueprint',
          value: project.publishArchitectureApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishArchitectureApproved: v)),
        ),
        _buildApprovalToggle(
          title: 'Screenshots & UI',
          value: project.publishScreenshotsApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishScreenshotsApproved: v)),
        ),
        _buildApprovalToggle(
          title: 'Engineering Challenges',
          value: project.publishChallengesApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishChallengesApproved: v)),
        ),
        _buildApprovalToggle(
          title: 'Outcome & Metrics',
          value: project.publishOutcomeApproved,
          onChanged: (v) => _updateProject(project.copyWith(publishOutcomeApproved: v)),
        ),
        const SizedBox(height: 16),
        const DoodleDivider(),
        const SizedBox(height: 10),
        const Text(
          'What the Recruiter Will See (Live Projection Preview)',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Live preview of the safe PublicProject
        SketchCard(
          id: 'live-projection-preview',
          borderColor: SketchPalette.skyBlue,
          child: project.isPublic
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name, style: const TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
                    if (project.publishSummaryApproved) ...[
                      const SizedBox(height: 4),
                      Text(project.summary, style: const TextStyle(fontSize: 13)),
                    ],
                    if (project.publishTechApproved && project.technologies.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: project.technologies.map((t) => SketchChip(label: t)).toList(),
                      ),
                    ],
                    if (project.publishArchitectureApproved && project.architectureNotes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Architecture:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(project.architectureNotes, style: const TextStyle(fontSize: 12)),
                    ],
                    if (project.publishOutcomeApproved && project.outcomeNotes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Outcome:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(project.outcomeNotes, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Hidden from Public Portfolio (isPublic = false)'),
                  ),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildApprovalToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      activeColor: SketchPalette.sageGreen,
      dense: true,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  void _updateProject(Project updated) {
    ref.read(projectsProvider.notifier).saveProject(updated);
  }

  void _showAddMilestoneDialog(BuildContext context, Project project) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Milestone', style: TextStyle(fontFamily: 'Caveat', fontSize: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Milestone Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          SketchButton(
            isSmall: true,
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final m = Milestone(
                  id: 'mile-${DateTime.now().millisecondsSinceEpoch}',
                  projectId: project.id,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  dueDate: DateTime.now().add(const Duration(days: 14)),
                );
                await ref.read(projectRepositoryProvider).saveMilestone(m);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
