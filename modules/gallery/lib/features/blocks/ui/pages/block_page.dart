import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/catalog/catalog.dart';
import 'package:gallery/features/blocks/models/models.dart';
import 'package:gallery/features/blocks/ui/widgets/widgets.dart';
import 'package:gallery/features/components/ui/widgets/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// A block's page: the live block on its desk and its code.
///
/// Mirrors `BlockPage` in upstream `src/docs/pages/BlocksPage.tsx`.
class BlockPage extends StatelessWidget {
  const BlockPage({super.key, required this.doc, required this.block});

  final BlockDoc doc;
  final GalleryBlock block;

  static const String root = 'packages/gallery/lib/features/blocks';

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final blocks = BlockCatalog.blocks;
    final index = blocks.indexWhere((other) => other.slug == doc.slug);
    final previous = switch (index) {
      <= 0 => null,
      _ => blocks[index - 1],
    };
    PagerLink? linkTo(BlockDoc? target) => switch (target) {
      null => null,
      final page => (
        title: page.title,
        onPressed: () => navigation.go(BlocksRoute(page.slug)),
      ),
    };
    return DocPage(
      kicker: 'Blocks',
      title: doc.title,
      description: doc.description,
      meta: [
        for (final tag in doc.tags) DocChip(tag, tone: DocChipTone.outline),
      ],
      footer: DocPager(
        previous: linkTo(previous),
        next: linkTo(blocks.elementAtOrNull(index + 1)),
      ),
      children: [
        DocSection(
          title: 'Preview',
          children: [
            Paper(
              tilt: false,
              shadow: PaperShadow.slip,
              seed: 'block:${doc.slug}',
              padding: const EdgeInsets.all(Spacing.d4),
              child: BlockPreview(slug: doc.slug, block: block),
            ),
          ],
        ),
        DocSection(
          title: 'Code',
          children: [
            ExampleSource(source: block.source, root: root, label: 'blocks'),
          ],
        ),
      ],
    );
  }
}
