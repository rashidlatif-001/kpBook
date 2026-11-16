import 'content_block_model.dart';

class Chapter {
  final String id;
  final int number;
  final String title;
  final String titleUrdu;
  final int pageStart;
  final int pageEnd;
  final bool isCompleted;
  final String sloSummary;
  final List<String> keyTopics;
  final List<ContentBlock> contentBlocks;

  const Chapter({
    this.id = '',
    required this.number,
    required this.title,
    this.titleUrdu = '',
    required this.pageStart,
    required this.pageEnd,
    this.isCompleted = false,
    this.sloSummary = '',
    this.keyTopics = const [],
    this.contentBlocks = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var rawTopics = json['key_topics'];
    List<String> parsedTopics = [];
    if (rawTopics is List) {
      parsedTopics = rawTopics.map((e) => e.toString()).toList();
    }

    var rawBlocks = json['content_blocks'];
    List<ContentBlock> parsedBlocks = [];
    if (rawBlocks is List) {
      parsedBlocks = rawBlocks.map((b) => ContentBlock.fromJson(Map<String, dynamic>.from(b))).toList();
    }

    return Chapter(
      id: json['id']?.toString() ?? '',
      number: json['chapter_number'] is int
          ? json['chapter_number']
          : int.tryParse(json['chapter_number']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? '',
      titleUrdu: json['title_urdu']?.toString() ?? '',
      pageStart: json['start_page'] is int
          ? json['start_page']
          : int.tryParse(json['start_page']?.toString() ?? '1') ?? 1,
      pageEnd: json['end_page'] is int
          ? json['end_page']
          : int.tryParse(json['end_page']?.toString() ?? '1') ?? 1,
      isCompleted: json['is_completed'] == true,
      sloSummary: json['slo_summary']?.toString() ?? '',
      keyTopics: parsedTopics,
      contentBlocks: parsedBlocks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': number,
      'title': title,
      'title_urdu': titleUrdu,
      'start_page': pageStart,
      'end_page': pageEnd,
      'is_completed': isCompleted,
      'slo_summary': sloSummary,
      'key_topics': keyTopics,
      'content_blocks': contentBlocks.map((b) => b.toJson()).toList(),
    };
  }

  Chapter copyWith({
    String? id,
    int? number,
    String? title,
    String? titleUrdu,
    int? pageStart,
    int? pageEnd,
    bool? isCompleted,
    String? sloSummary,
    List<String>? keyTopics,
    List<ContentBlock>? contentBlocks,
  }) {
    return Chapter(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      titleUrdu: titleUrdu ?? this.titleUrdu,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      isCompleted: isCompleted ?? this.isCompleted,
      sloSummary: sloSummary ?? this.sloSummary,
      keyTopics: keyTopics ?? this.keyTopics,
      contentBlocks: contentBlocks ?? this.contentBlocks,
    );
  }
}
