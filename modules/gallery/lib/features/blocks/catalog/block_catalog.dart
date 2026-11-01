import 'package:gallery/features/blocks/catalog/block_registry.dart';
import 'package:gallery/features/blocks/docs/all_block_docs.dart';
import 'package:gallery/features/blocks/models/models.dart';

/// The ported blocks, in upstream order.
abstract final class BlockCatalog {
  static final List<BlockDoc> blocks = [
    for (final doc in allBlockDocs)
      if (portedBlocks.containsKey(doc.slug)) doc,
  ];

  static int get upstreamCount => allBlockDocs.length;

  /// The ported block [slug] and its widget, or null.
  static (BlockDoc, GalleryBlock)? bySlug(String slug) {
    final block = portedBlocks[slug];
    if (block == null) return null;
    for (final doc in allBlockDocs) {
      if (doc.slug == slug) return (doc, block);
    }
    return null;
  }
}
