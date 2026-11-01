/// The surface a block sits on, upstream `BlockDoc.surface`.
enum BlockSurface { paper, desk }

/// A block's page data, upstream `BlockDoc` (`src/docs/content/blocks/<slug>.meta.ts`).
class BlockDoc {
  const BlockDoc({
    required this.slug,
    required this.title,
    this.description,
    this.tags = const [],
    this.surface = BlockSurface.paper,
  });

  final String slug;
  final String title;
  final String? description;
  final List<String> tags;
  final BlockSurface surface;
}
