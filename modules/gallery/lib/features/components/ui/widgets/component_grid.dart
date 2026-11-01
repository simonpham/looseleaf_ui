import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:gallery/features/components/ui/widgets/component_thumbnail.dart';
import 'package:gallery/features/components/ui/widgets/gallery_tile.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Gallery tiles for [docs], each with a live thumbnail of its first example.
class ComponentGrid extends StatelessWidget {
  const ComponentGrid({super.key, required this.docs, required this.onOpen});

  final List<ComponentDoc> docs;
  final ValueChanged<String> onOpen;

  static const List<double> _tilts = [-0.5, 0.45, -0.15];

  @override
  Widget build(BuildContext context) => TileGrid(
    minTileWidth: 248,
    spacing: Spacing.d28,
    runSpacing: Spacing.d36,
    children: [
      for (final (index, doc) in docs.indexed)
        GalleryTile(
          title: doc.title,
          description: doc.description,
          tiltDegrees: _tilts[index % _tilts.length],
          picture: ComponentThumbnail(
            title: doc.title,
            example: ComponentCatalog.examplesOf(doc.slug).firstOrNull,
          ),
          chips: [
            if (doc.upstream case final name?)
              DocChip('shadcn: $name', tone: DocChipTone.outline),
          ],
          onPressed: () => onOpen(doc.slug),
        ),
    ],
  );
}
