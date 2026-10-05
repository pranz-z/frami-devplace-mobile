enum AiAttachmentType {
  project,
  task,
  plan,
  file; // text/code, PDF, PNG/JPEG/WebP
}

class AiAttachment {
  final String id;
  final AiAttachmentType type;
  final String title;
  final String previewText;
  final int? fileSizeBytes; // Max 5MB enforced
  final String? mimeType;

  const AiAttachment({
    required this.id,
    required this.type,
    required this.title,
    required this.previewText,
    this.fileSizeBytes,
    this.mimeType,
  });
}

enum AiSuggestionType {
  createSubtask,
  createMilestone,
  updateProgress,
  summarizeNotes;
}

class AiStructuredSuggestion {
  final String id;
  final AiSuggestionType type;
  final String title;
  final String targetEntityId; // e.g. projectId or taskId
  final Map<String, dynamic> payload; // proposed data
  bool isSelected;

  AiStructuredSuggestion({
    required this.id,
    required this.type,
    required this.title,
    required this.targetEntityId,
    required this.payload,
    this.isSelected = true,
  });
}

class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final List<AiStructuredSuggestion> suggestions;
  final List<AiAttachment> attachedContextChips; // displayed on user message

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.suggestions = const [],
    this.attachedContextChips = const [],
  });
}
