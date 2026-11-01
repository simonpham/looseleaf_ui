import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/catalog/catalog.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:provider/provider.dart';

/// Every ported block as a tile with its tags.
///
/// Mirrors `BlocksIndexPage` in upstream `src/docs/pages/BlocksPage.tsx`.
class BlocksPage extends StatelessWidget {
  const BlocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    return DocPage(
      kicker: 'Library',
      title: 'Blocks',
      description:
          'Whole pages composed from the components: sign in, dashboards and more. ${BlockCatalog.blocks.length} of ${BlockCatalog.upstreamCount} drawn so far. Copy one and edit it; it is your code.',
      children: [
        switch (BlockCatalog.blocks) {
          [] => const DocHint('No blocks yet.'),
          final blocks => TileGrid(
            children: [
              for (final block in blocks)
                DocTile(
                  title: block.title,
                  description: block.description,
                  meta: [
                    for (final tag in block.tags)
                      DocChip(tag, tone: DocChipTone.outline),
                  ],
                  onPressed: () => navigation.go(BlocksRoute(block.slug)),
                ),
            ],
          ),
        },
      ],
    );
  }
}
