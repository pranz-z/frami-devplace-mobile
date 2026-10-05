import 'dart:math';
import '../domain/ai_models.dart';
import '../../portfolio/domain/public_models.dart';
import '../../projects/data/project_repository.dart';
import '../../kanban/data/task_repository.dart';
import 'ai_service.dart';

class MockAiService implements AiService {
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;

  MockAiService({
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
  })  : _projectRepository = projectRepository,
        _taskRepository = taskRepository;

  @override
  Future<AiChatMessage> sendWorkspaceMessage({
    required String message,
    required List<AiChatMessage> boundedHistory,
    required List<AiAttachment> attachedEntities,
    required String ownerId,
  }) async {
    // Artificial latency for realism
    await Future.delayed(const Duration(milliseconds: 350));

    // HARD SECURITY REQUIREMENT:
    // At send time, never trust client-provided entity state or IDs blindly.
    // Re-fetch every attached entity from the repository and verify ownership!
    final verifiedContextNotes = <String>[];
    String? matchedProjectId;
    String? matchedTaskId;

    for (final attachment in attachedEntities) {
      if (attachment.type == AiAttachmentType.project) {
        final verifiedProj = await _projectRepository.getProjectById(
          attachment.id,
          ownerId: ownerId,
        );
        if (verifiedProj != null) {
          matchedProjectId = verifiedProj.id;
          verifiedContextNotes.add(
              'Verified Project: ${verifiedProj.name} (${verifiedProj.workflowStage.label})');
        }
      } else if (attachment.type == AiAttachmentType.task) {
        final verifiedTask = await _taskRepository.getTaskById(
          attachment.id,
          ownerId: ownerId,
        );
        if (verifiedTask != null) {
          matchedTaskId = verifiedTask.id;
          matchedProjectId ??= verifiedTask.projectId;
          verifiedContextNotes.add(
              'Verified Task: ${verifiedTask.title} [Status: ${verifiedTask.status.label}]');
        }
      } else if (attachment.type == AiAttachmentType.file) {
        verifiedContextNotes.add(
            'Verified File Attachment: ${attachment.title} (${attachment.fileSizeBytes ?? 0} bytes)');
      }
    }

    final lower = message.toLowerCase();
    final suggestions = <AiStructuredSuggestion>[];
    String replyText = '';

    final pId = matchedProjectId ?? 'proj-1';
    final randomSuffix = Random().nextInt(900) + 100;

    if (lower.contains('split') || lower.contains('break down') || lower.contains('subtask')) {
      replyText =
          'I analyzed your task workflow. Here is a recommended 3-step breakdown to maintain momentum:';
      suggestions.addAll([
        AiStructuredSuggestion(
          id: 'sug-$randomSuffix-1',
          type: AiSuggestionType.createSubtask,
          title: 'Implement edge-case validation & unit tests',
          targetEntityId: matchedTaskId ?? pId,
          payload: {
            'projectId': pId,
            'title': 'Implement edge-case validation & unit tests',
            'status': 'todo',
            'priority': 'high',
          },
        ),
        AiStructuredSuggestion(
          id: 'sug-$randomSuffix-2',
          type: AiSuggestionType.createSubtask,
          title: 'Add tactile micro-haptics on drag release',
          targetEntityId: matchedTaskId ?? pId,
          payload: {
            'projectId': pId,
            'title': 'Add tactile micro-haptics on drag release',
            'status': 'todo',
            'priority': 'medium',
          },
        ),
        AiStructuredSuggestion(
          id: 'sug-$randomSuffix-3',
          type: AiSuggestionType.createSubtask,
          title: 'Verify responsiveness at 1.3x text scale',
          targetEntityId: matchedTaskId ?? pId,
          payload: {
            'projectId': pId,
            'title': 'Verify responsiveness at 1.3x text scale',
            'status': 'todo',
            'priority': 'medium',
          },
        ),
      ]);
    } else if (lower.contains('milestone') || lower.contains('roadmap')) {
      replyText =
          'Based on your project velocity, I suggest anchoring this milestone:';
      suggestions.add(
        AiStructuredSuggestion(
          id: 'sug-$randomSuffix-4',
          type: AiSuggestionType.createMilestone,
          title: 'Milestone: Production Readiness & Recruiter Demo',
          targetEntityId: pId,
          payload: {
            'projectId': pId,
            'title': 'Production Readiness & Recruiter Demo',
            'description': 'Ensure all public projections and smoke tests pass.',
            'daysFromNow': 7,
          },
        ),
      );
    } else if (lower.contains('publish') || lower.contains('portfolio')) {
      replyText =
          'Your project is in great shape for portfolio projection. Remember that only fields explicitly checked in the "Publish" tab are exposed to recruiters. Tasks and internal notes will stay private.';
    } else {
      replyText =
          'I reviewed your development workspace. Everything is indexed and ready. You can ask me to break down tasks, suggest milestones, or audit project health.';
    }

    if (verifiedContextNotes.isNotEmpty) {
      replyText += '\n\n*Attached context verified:* ${verifiedContextNotes.join(', ')}';
    }

    return AiChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      text: replyText,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    );
  }

  @override
  Future<String> askPublicConcierge({
    required String query,
    required PublicContext publicContext,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lower = query.toLowerCase();

    // STRICT REFUSAL on private topics
    final privateKeywords = [
      'private',
      'internal task',
      'task list',
      'personal note',
      'internal note',
      'plan',
      'calendar',
      'calendar event',
      'focus session',
      'goal',
      'internal ledger',
      'stealth ai',
      'private repo',
      'todo',
      'backlog'
    ];

    for (final kw in privateKeywords) {
      if (lower.contains(kw)) {
        return "I apologize, but I only have access to Frami's verified public portfolio and case studies. Internal workspace tasks, private notes, calendar schedules, and unreleased repositories remain private to the developer.";
      }
    }

    if (lower.contains('what') && lower.contains('built')) {
      final titles = publicContext.projects.map((p) => p.title).join(', ');
      return 'Frami has built several featured projects including $titles. Notably, Developer Workplace acts as a developer operating system that projects private work into verified recruiter evidence.';
    }

    if (lower.contains('tech') || lower.contains('skills') || lower.contains('stack')) {
      final skills = publicContext.profile.primarySkills.join(', ');
      return "Frami's primary technical skills include: $skills. He specializes in high-throughput distributed systems in Rust, as well as fluid, resilient mobile experiences in Flutter & Dart.";
    }

    if (lower.contains('github') || lower.contains('repo') || lower.contains('integration')) {
      final repos = publicContext.projects
          .where((p) => p.publicRepoUrl != null)
          .map((p) => '${p.title} (${p.publicRepoUrl})')
          .join('\n• ');
      return 'Frami has published public open-source repositories:\n• $repos\n\nAll commits and releases reflect production-grade craftsmanship.';
    }

    if (lower.contains('experience') || lower.contains('background') || lower.contains('who')) {
      final exp = publicContext.profile.experiences
          .map((e) => '${e.role} at ${e.company} (${e.period})')
          .join('; ');
      return '${publicContext.profile.name} is a ${publicContext.profile.title} based in ${publicContext.profile.location}. Prior experience includes: $exp.';
    }

    return "Frami is a ${publicContext.profile.title}. You can explore his featured projects above, download his resume, or ask me about his technical background and architecture decisions!";
  }
}
