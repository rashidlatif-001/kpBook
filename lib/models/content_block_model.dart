class ContentBlock {
  final String id;
  final String topicId;
  final String? subtopicId;
  final String blockType; // 'heading', 'paragraph', 'definition', 'important_note', 'formula', 'table', 'diagram', 'solved_example', 'exercise', 'question'
  final String content;
  final int displayOrder;
  final int originalPdfPage;
  final Map<String, dynamic> metadata;

  const ContentBlock({
    required this.id,
    required this.topicId,
    this.subtopicId,
    required this.blockType,
    required this.content,
    required this.displayOrder,
    required this.originalPdfPage,
    this.metadata = const {},
  });

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id']?.toString() ?? '',
      topicId: json['topic_id']?.toString() ?? '',
      subtopicId: json['subtopic_id']?.toString(),
      blockType: json['block_type']?.toString() ?? 'paragraph',
      content: json['content']?.toString() ?? '',
      displayOrder: json['display_order'] is int ? json['display_order'] : int.tryParse(json['display_order']?.toString() ?? '0') ?? 0,
      originalPdfPage: json['original_pdf_page'] is int ? json['original_pdf_page'] : int.tryParse(json['original_pdf_page']?.toString() ?? '1') ?? 1,
      metadata: json['metadata'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['metadata']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'subtopic_id': subtopicId,
      'block_type': blockType,
      'content': content,
      'display_order': displayOrder,
      'original_pdf_page': originalPdfPage,
      'metadata': metadata,
    };
  }

  bool get isFormula => blockType == 'formula';
  bool get isDefinition => blockType == 'definition';
  bool get isHeading => blockType == 'heading';
  bool get isImportantNote => blockType == 'important_note';
  bool get isTable => blockType == 'table';
  bool get isSolvedExample => blockType == 'solved_example';
  bool get isQuestion => blockType == 'question' || blockType == 'exercise';
  bool get isDiagram => blockType == 'diagram' || blockType == 'image';
}
