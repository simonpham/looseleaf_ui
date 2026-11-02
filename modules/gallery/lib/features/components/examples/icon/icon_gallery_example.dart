import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `minmax(7.5rem, 1fr)`.
const _minCellWidth = 120.0;

class IconGalleryExample extends StatelessWidget {
  const IconGalleryExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final caption = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.pencilText,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(
          1,
          ((constraints.maxWidth + Spacing.d12) / (_minCellWidth + Spacing.d12))
              .floor(),
        );
        final cellWidth =
            (constraints.maxWidth - Spacing.d12 * (columns - 1)) / columns;
        return Wrap(
          spacing: Spacing.d12,
          runSpacing: Spacing.d12,
          children: [
            for (final name in icons.keys)
              SizedBox(
                width: cellWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                  child: Column(
                    spacing: Spacing.d4,
                    children: [
                      InkIcon(name, size: Spacing.d24),
                      Text(name, style: caption, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
