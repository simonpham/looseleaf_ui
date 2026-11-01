import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The hand-drawn arrow from a popup to its anchor, pointing across [side]
/// (a popup below its anchor points up). It is [size] long-side-first as
/// drawn pointing down: 22 × 20 for popovers, 18 × 16 for tooltips.
///
/// Mirrors `PopoverPointer` / `TooltipPointer` in upstream `popover.tsx`
/// and `tooltip.tsx`, drawn by `pointerMark`
/// (`src/lib/ink/recipes/overlay-ink.ts`).
class PopupPointer extends StatelessWidget {
  const PopupPointer({
    super.key,
    required this.side,
    required this.seed,
    this.size = popoverSize,
  });

  /// A popover's arrow.
  static const Size popoverSize = Size(22, 20);

  /// A tooltip's arrow.
  static const Size tooltipSize = Size(18, 16);

  /// The side of the anchor the popup is on.
  final OverlaySide side;

  /// The popup's seed; the arrow is seeded `seed|pointer`.
  final String seed;

  /// Width × height as drawn pointing down.
  final Size size;

  /// How far the arrow reaches out from the popup's edge.
  double get reach => size.height;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final tier = PaperInk.tier(theme);
    final calm = PaperInk.calm(theme);
    final turns = switch (side) {
      OverlaySide.top => 0.0,
      OverlaySide.bottom => 1.0,
      OverlaySide.right => 0.5,
      OverlaySide.left => -0.5,
    };
    final art = InkArt(
      cacheKey: 'pointer|$seed|${size.width}x${size.height}|${tier.name}|$calm',
      draw: () => pointerMark(
        '$seed|pointer',
        w: size.width,
        h: size.height,
        tier: tier,
        calm: calm,
      ),
    );
    final box = switch (side.vertical) {
      true => size,
      false => Size(size.height, size.width),
    };
    return SizedBox.fromSize(
      size: box,
      child: OverflowBox(
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height,
        maxHeight: size.height,
        child: Transform.rotate(angle: turns * math.pi, child: art),
      ),
    );
  }
}
