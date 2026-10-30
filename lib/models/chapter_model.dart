class Chapter {
  final int number;
  final String title;
  final String titleUrdu;
  final int pageStart;
  final int pageEnd;
  final bool isCompleted;
  final List<String> keyTopics;

  const Chapter({
    required this.number,
    required this.title,
    this.titleUrdu = '',
    required this.pageStart,
    required this.pageEnd,
    this.isCompleted = false,
    this.keyTopics = const [],
  });
}
