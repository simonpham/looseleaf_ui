import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Lays [children] out in as many equal columns of at least [minTileWidth]
/// as fit, like CSS `repeat(auto-fill, minmax(min(15rem, 100%), 1fr))`.
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.children,
    this.minTileWidth = 240,
    this.spacing = Spacing.d20,
    this.runSpacing = Spacing.d24,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final columns = math.max(
        1,
        ((width + spacing) / (minTileWidth + spacing)).floor(),
      );
      final tileWidth = (width - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          for (final child in children)
            SizedBox(width: tileWidth, child: child),
        ],
      );
    },
  );
}
