import '../domain/ai_models.dart';
import '../../portfolio/domain/public_models.dart';

abstract class AiService {
  /// Workspace AI query: requires owner-verified re-fetched entities, bounded history
  Future<AiChatMessage> sendWorkspaceMessage({
    required String message,
    required List<AiChatMessage> boundedHistory,
    required List<AiAttachment> attachedEntities,
    required String ownerId,
  });

  /// Public Portfolio Concierge query: strictly consumes PublicContext only.
  /// If asked about private tasks/notes/plans/goals, politely refuses.
  Future<String> askPublicConcierge({
    required String query,
    required PublicContext publicContext,
  });
}
