import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A block on its desk, at least [minHeight] tall, like upstream's
/// full-layout stage.
class BlockPreview extends StatelessWidget {
  const BlockPreview({
    super.key,
    required this.slug,
    required this.block,
    this.minHeight = 520,
  });

  final String slug;
  final GalleryBlock block;
  final double minHeight;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: Desk(
      objects: block.objects,
      seed: slug,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Center(child: block.builder()),
      ),
    ),
  );
}
