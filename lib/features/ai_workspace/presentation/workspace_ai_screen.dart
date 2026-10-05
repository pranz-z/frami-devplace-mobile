import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/sketch_theme.dart';
import '../../../core/widgets/sketch_widgets.dart';
import '../../../core/providers/app_providers.dart';
import '../domain/ai_models.dart';
import '../../kanban/domain/task_model.dart';
import '../../projects/domain/project_model.dart';

class WorkspaceAiScreen extends ConsumerStatefulWidget {
  const WorkspaceAiScreen({super.key});

  @override
  ConsumerState<WorkspaceAiScreen> createState() => _WorkspaceAiScreenState();
}

class _WorkspaceAiScreenState extends ConsumerState<WorkspaceAiScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<AiChatMessage> _messages = [];
  final List<AiAttachment> _attachedChips = [];
  bool _isLoading = false;
  int _rateLimitUsed = 12;
  final int _rateLimitMax = 20;

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatMessage(
        id: 'msg-welcome',
        isUser: false,
        text:
            'Hello! I am your private Workspace AI assistant. I can analyze attached tasks, break down work into subtasks, suggest milestones, or audit project health. I never mutate your data directly without your explicit review.',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final userMsg = AiChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      isUser: true,
      text: text,
      timestamp: DateTime.now(),
      attachedContextChips: List.from(_attachedChips),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
      _rateLimitUsed++;
    });

    _textController.clear();
    final chipsToSend = List<AiAttachment>.from(_attachedChips);
    _attachedChips.clear(); // Attachments are ephemeral!

    _scrollToBottom();

    try {
      final aiService = ref.read(aiServiceProvider);
      // Keep conversation history bounded to last 10 turns
      final boundedHistory = _messages.length > 10
          ? _messages.sublist(_messages.length - 10)
          : _messages;

      final botReply = await aiService.sendWorkspaceMessage(
        message: text,
        boundedHistory: boundedHistory,
        attachedEntities: chipsToSend,
        ownerId: currentOwnerId,
      );

      if (mounted) {
        setState(() {
          _messages.add(botReply);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            AiChatMessage(
              id: 'err-${DateTime.now().millisecondsSinceEpoch}',
              isUser: false,
              text: 'Error processing request: $e',
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachSheet() {
    final projects = ref.read(projectsProvider).value ?? [];
    final tasks = ref.read(tasksProvider).value ?? [];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Attach Ephemeral Context', style: TextStyle(fontFamily: 'Caveat', fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('Attach Project'),
            onTap: () {
              Navigator.pop(ctx);
              _showSubEntityPicker(
                title: 'Select Project to Attach',
                items: projects.map((p) => {'id': p.id, 'title': p.name, 'type': AiAttachmentType.project}).toList(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_box_outlined),
            title: const Text('Attach Task'),
            onTap: () {
              Navigator.pop(ctx);
              _showSubEntityPicker(
                title: 'Select Task to Attach',
                items: tasks.map((t) => {'id': t.id, 'title': t.title, 'type': AiAttachmentType.task}).toList(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('Attach File / Code snippet'),
            subtitle: const Text('Text, PDF, PNG/JPEG (Max 5MB)'),
            onTap: () {
              Navigator.pop(ctx);
              // Mock attached file with type and size limits
              setState(() {
                _attachedChips.add(
                  const AiAttachment(
                    id: 'file-mock-1',
                    type: AiAttachmentType.file,
                    title: 'schema_v2.sql',
                    previewText: 'CREATE TABLE orders...',
                    fileSizeBytes: 42000,
                    mimeType: 'text/plain',
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  void _showSubEntityPicker({required String title, required List<Map<String, dynamic>> items}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Caveat', fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...items.take(15).map((it) => ListTile(
                title: Text(it['title'] as String),
                onTap: () {
                  setState(() {
                    _attachedChips.add(
                      AiAttachment(
                        id: it['id'] as String,
                        type: it['type'] as AiAttachmentType,
                        title: it['title'] as String,
                        previewText: it['title'] as String,
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                },
              )),
        ],
      ),
    );
  }

  Future<void> _applySuggestions(List<AiStructuredSuggestion> suggestions) async {
    final selected = suggestions.where((s) => s.isSelected).toList();
    if (selected.isEmpty) return;

    for (final s in selected) {
      if (s.type == AiSuggestionType.createSubtask) {
        final p = s.payload;
        final newTask = Task(
          id: 'task-ai-${DateTime.now().millisecondsSinceEpoch}-${s.id}',
          ownerId: currentOwnerId,
          projectId: p['projectId'] ?? 'proj-1',
          title: p['title'] ?? s.title,
          status: TaskStatus.todo,
          priority: TaskPriority.high,
          createdAt: DateTime.now().toUtc(),
        );
        await ref.read(tasksProvider.notifier).saveTask(newTask);
      } else if (s.type == AiSuggestionType.createMilestone) {
        final p = s.payload;
        final m = Milestone(
          id: 'mile-ai-${DateTime.now().millisecondsSinceEpoch}',
          projectId: p['projectId'] ?? 'proj-1',
          title: p['title'] ?? s.title,
          description: p['description'] ?? '',
          dueDate: DateTime.now().add(Duration(days: p['daysFromNow'] ?? 7)),
        );
        await ref.read(projectRepositoryProvider).saveMilestone(m);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully applied ${selected.length} items to workspace!'),
          backgroundColor: SketchPalette.sageGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workspace AI',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Rate-limit indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: SketchPalette.borderSubtleLight),
            ),
            child: Text(
              '$_rateLimitUsed/$_rateLimitMax hr',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat message history
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageRow(context, msg);
              },
            ),
          ),

          // Attached Context Chips tray (ephemeral)
          if (_attachedChips.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isDark ? SketchPalette.paperSurfaceDark : SketchPalette.paperSurfaceLight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _attachedChips.map((chip) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        avatar: Icon(
                          chip.type == AiAttachmentType.file
                              ? Icons.attach_file
                              : (chip.type == AiAttachmentType.project ? Icons.folder : Icons.check_box),
                          size: 14,
                        ),
                        label: Text(chip.title, style: const TextStyle(fontSize: 11)),
                        onDeleted: () => setState(() => _attachedChips.remove(chip)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Input Bar with Concurrency Lock
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? SketchPalette.paperCardDark : SketchPalette.paperCardLight,
              border: Border(top: BorderSide(color: isDark ? SketchPalette.borderDark : SketchPalette.borderSubtleLight)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Attach Project / Task / File',
                  onPressed: _isLoading ? null : _showAttachSheet,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Ask AI (e.g. "Split task into 3 subtasks")...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(BuildContext context, AiChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        child: SketchCard(
          id: msg.id,
          margin: const EdgeInsets.symmetric(vertical: 6),
          backgroundColor: msg.isUser ? SketchPalette.markerYellow.withValues(alpha: 0.2) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.attachedContextChips.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  children: msg.attachedContextChips.map((c) => SketchChip(label: 'Context: ${c.title}')).toList(),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                msg.text,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
              if (msg.suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Structured Suggestions (Review before applying):',
                  style: TextStyle(fontFamily: 'Caveat', fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...msg.suggestions.map((sug) => CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: sug.isSelected,
                      activeColor: SketchPalette.sageGreen,
                      title: Text(sug.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onChanged: (val) {
                        setState(() => sug.isSelected = val ?? false);
                      },
                    )),
                const SizedBox(height: 6),
                SketchButton(
                  isSmall: true,
                  onPressed: () => _applySuggestions(msg.suggestions),
                  child: const Text('Apply Selected Suggestions'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
