/// One part of the getting started guide: a section with its prose and
/// code blocks, in order.
class GuideStep {
  const GuideStep({
    required this.title,
    this.description,
    this.paragraphs = const [],
    this.code = const [],
  });

  final String title;
  final String? description;
  final List<String> paragraphs;

  /// File name and code of each block.
  final List<({String title, String code})> code;
}
