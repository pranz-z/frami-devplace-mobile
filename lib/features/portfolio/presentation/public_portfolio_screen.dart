import 'package:flutter/material.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../domain/public_models.dart';
import '../data/public_portfolio_repository.dart';
import '../../ai_workspace/data/ai_service.dart';

class PublicPortfolioScreen extends StatefulWidget {
  final PublicPortfolioRepository repository;
  final AiService aiService;

  const PublicPortfolioScreen({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  State<PublicPortfolioScreen> createState() => _PublicPortfolioScreenState();
}

class _PublicPortfolioScreenState extends State<PublicPortfolioScreen> {
  late Future<PublicContext> _contextFuture;

  @override
  void initState() {
    super.initState();
    _contextFuture = widget.repository.getPublicContext();
  }

  void _showAskAiConcierge(BuildContext context, PublicContext publicContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PublicAiConciergeSheet(
        publicContext: publicContext,
        aiService: widget.aiService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<PublicContext>(
      future: _contextFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || snap.data == null) {
          return Scaffold(body: Center(child: Text('Error loading portfolio: ${snap.error}')));
        }

        final publicContext = snap.data!;
        final profile = publicContext.profile;
        final projects = publicContext.projects;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Public Portfolio',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined),
                tooltip: 'Download Resume',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading verified public resume (PDF)...')),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: SketchPalette.markerYellow,
            foregroundColor: SketchPalette.inkDark,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask AI Concierge', style: TextStyle(fontFamily: 'Caveat', fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () => _showAskAiConcierge(context, publicContext),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // Safe projection banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SketchPalette.sageGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SketchPalette.sageGreen),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: SketchPalette.sageGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verified Public View • Built exclusively from approved project projections. No private data is exposed.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hero / Intro
              SketchCard(
                id: 'profile-hero',
                hasTornEdge: true,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: SketchPalette.markerYellow,
                          child: Icon(Icons.person, size: 36, color: SketchPalette.inkDark),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name, style: const TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold)),
                              Text(profile.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(profile.location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(profile.bio, style: const TextStyle(fontSize: 13, height: 1.4)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: profile.primarySkills.map((s) => SketchChip(label: s)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Featured Projects & Case Studies
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Projects & Case Studies', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('${projects.length} Published', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              ...projects.map((proj) => _buildPublicProjectCard(context, proj, publicContext)),

              const SizedBox(height: 16),
              const DoodleDivider(),
              const SizedBox(height: 10),

              // Professional Experience
              const Text('Experience', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...profile.experiences.map((exp) => SketchCard(
                    id: exp.company,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(exp.role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(exp.period, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Text(exp.company, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SketchPalette.skyBlue)),
                        const SizedBox(height: 6),
                        Text(exp.description, style: const TextStyle(fontSize: 12)),
                        if (exp.highlights.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...exp.highlights.map((h) => Padding(
                                padding: const EdgeInsets.only(left: 6.0, top: 2.0),
                                child: Text('• $h', style: const TextStyle(fontSize: 11)),
                              )),
                        ],
                      ],
                    ),
                  )),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPublicProjectCard(BuildContext context, PublicProject proj, PublicContext pubContext) {
    final evidence = pubContext.evidence.where((e) => e.projectId == proj.id).toList();

    return SketchCard(
      id: 'pub-proj-${proj.id}',
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(proj.title, style: const TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              if (proj.isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SketchPalette.markerYellow.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(proj.summary, style: const TextStyle(fontSize: 13, height: 1.3)),
          if (proj.technologies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: proj.technologies.map((t) => SketchChip(label: t)).toList(),
            ),
          ],
          if (proj.architecture != null && proj.architecture!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Architecture & Isolation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(proj.architecture!, style: const TextStyle(fontSize: 12, height: 1.3)),
          ],
          if (proj.outcome != null && proj.outcome!.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text('Outcome:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(proj.outcome!, style: const TextStyle(fontSize: 12)),
          ],
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: evidence.map((e) {
                return ActionChip(
                  avatar: const Icon(Icons.link, size: 14),
                  label: Text('${e.proofType}: ${e.title}', style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${e.url}')),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Recruiter-facing floating AI Concierge Modal
class _PublicAiConciergeSheet extends StatefulWidget {
  final PublicContext publicContext;
  final AiService aiService;

  const _PublicAiConciergeSheet({
    required this.publicContext,
    required this.aiService,
  });

  @override
  State<_PublicAiConciergeSheet> createState() => _PublicAiConciergeSheetState();
}

class _PublicAiConciergeSheetState extends State<_PublicAiConciergeSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final List<String> _suggestedQuestions = [
    'What has Frami built?',
    'Which technologies does he use?',
    'Show me a project with GitHub integration',
    'What are his internal tasks? (Test refusal)',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'bot',
      'text':
          "Hi! I'm Frami's AI portfolio concierge. I can answer questions about his experience, skills, and verified published projects.",
    });
  }

  Future<void> _ask(String query) async {
    if (query.trim().isEmpty || _isLoading) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isLoading = true;
    });
    _controller.clear();

    final response = await widget.aiService.askPublicConcierge(
      query: query,
      publicContext: widget.publicContext,
    );

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': response});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? SketchPalette.paperCardDark : SketchPalette.paperCardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: SketchPalette.markerYellowDark),
                  SizedBox(width: 8),
                  Text('Recruiter Concierge (Public AI)', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 6),
          // Suggested prompts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestedQuestions.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 11)),
                    onPressed: _isLoading ? null : () => _ask(q),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, idx) {
                final m = _messages[idx];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: SketchCard(
                    id: 'chat-$idx',
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isUser ? SketchPalette.markerYellow.withValues(alpha: 0.25) : null,
                    child: Text(m['text'] ?? '', style: const TextStyle(fontSize: 12, height: 1.3)),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Ask about projects, skills, experience...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: _ask,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
                onPressed: _isLoading ? null : () => _ask(_controller.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
