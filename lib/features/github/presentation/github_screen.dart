import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/github_model.dart';

class GitHubScreen extends ConsumerStatefulWidget {
  const GitHubScreen({super.key});

  @override
  ConsumerState<GitHubScreen> createState() => _GitHubScreenState();
}

class _GitHubScreenState extends ConsumerState<GitHubScreen> {
  String? _selectedRepo;
  GitHubItemType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final ghRepo = ref.watch(githubRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GitHub Integration',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Security / Architecture Explainer Card
          const SketchCard(
            id: 'gh-security-explainer',
            hasTornEdge: true,
            borderColor: SketchPalette.skyBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, size: 18, color: SketchPalette.skyBlue),
                    SizedBox(width: 8),
                    Text(
                      'GitHub App Architecture & Security',
                      style: TextStyle(fontFamily: 'Caveat', fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '• Read-only permissions: Only public repository metadata, commits, PRs, and issues are read.\n'
                  '• Short-lived tokens: Tokens are minted server-side and never stored on mobile client.\n'
                  '• Authorization is separate from owner login.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Repo Picker
          FutureBuilder<List<GitHubRepoSummary>>(
            future: ghRepo.getAuthorizedRepos(),
            builder: (context, snap) {
              final repos = snap.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Authorized Repositories', style: TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SketchChip(
                          label: 'All Repos',
                          isSelected: _selectedRepo == null,
                          onTap: () => setState(() => _selectedRepo = null),
                        ),
                        const SizedBox(width: 6),
                        ...repos.map((r) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: SketchChip(
                                label: '${r.name} (★${r.starsCount})',
                                isSelected: _selectedRepo == r.name,
                                onTap: () => setState(() => _selectedRepo = r.name),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Filter by Activity Type
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SketchChip(
                  label: 'All Activity',
                  isSelected: _typeFilter == null,
                  onTap: () => setState(() => _typeFilter = null),
                ),
                const SizedBox(width: 6),
                ...GitHubItemType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: SketchChip(
                        label: t.name.toUpperCase(),
                        isSelected: _typeFilter == t,
                        onTap: () => setState(() => _typeFilter = t),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Activity Items (Bounded & Paginated, max 20)
          FutureBuilder<List<GitHubActivityItem>>(
            future: ghRepo.getRecentActivity(repoName: _selectedRepo, limit: 20),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
              }
              var items = snap.data ?? [];
              if (_typeFilter != null) {
                items = items.where((it) => it.type == _typeFilter).toList();
              }

              if (items.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No activity items found.')));
              }

              return Column(
                children: items.map((it) {
                  IconData icon;
                  Color iconColor;
                  switch (it.type) {
                    case GitHubItemType.commit:
                      icon = Icons.commit;
                      iconColor = SketchPalette.skyBlue;
                      break;
                    case GitHubItemType.pullRequest:
                      icon = Icons.merge_type;
                      iconColor = SketchPalette.sageGreen;
                      break;
                    case GitHubItemType.issue:
                      icon = Icons.bug_report_outlined;
                      iconColor = SketchPalette.danger;
                      break;
                    case GitHubItemType.release:
                      icon = Icons.new_releases_outlined;
                      iconColor = SketchPalette.markerYellowDark;
                      break;
                  }

                  return SketchCard(
                    id: it.id,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: iconColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(it.repoName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text('${it.timestamp.month}/${it.timestamp.day} by ${it.author}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(it.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              if (it.summary.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(it.summary, style: const TextStyle(fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
