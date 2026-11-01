import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// One cursor highlight: a highlighter column, a pencil guide, a ring on a
/// point, a slice outline, a cell box or a spoke, drawn by
/// [chartMarkRecipe] where the layout puts it.
///
/// Mirrors `CursorMark` in upstream `src/components/ui/chart.tsx`.
class ChartCursorMark extends StatelessWidget {
  const ChartCursorMark({super.key, required this.cursor, required this.seed});

  /// Where and what.
  final CursorSpec cursor;

  /// The chart's seed.
  final String seed;

  /// The mark's params, rounded like upstream `cursorParams`.
  static MiniParams paramsOf(CursorSpec c) => switch (c.kind) {
    CursorKind.ring => MiniRing(slot: c.slot ?? 0),
    CursorKind.slice => MiniSlice(
      cx: roundTo(c.cx ?? 0, 1),
      cy: roundTo(c.cy ?? 0, 1),
      r0: roundTo(c.r0 ?? 0, 1),
      r1: roundTo(c.r1 ?? 0, 1),
      a0: roundTo(c.a0 ?? 0, 3),
      a1: roundTo(c.a1 ?? 0, 3),
    ),
    CursorKind.spoke => MiniSpoke(
      x1: roundTo(c.x1 ?? 0, 1),
      y1: roundTo(c.y1 ?? 0, 1),
      x2: roundTo(c.x2 ?? 0, 1),
      y2: roundTo(c.y2 ?? 0, 1),
    ),
    CursorKind.column => const MiniColumn(),
    CursorKind.guide => const MiniGuide(),
    CursorKind.cell => const MiniCell(),
  };

  @override
  Widget build(BuildContext context) {
    final params = paramsOf(cursor);
    return AnimatedPositioned(
      duration: InkMotion.of(context, InkMotion.hover),
      curve: InkMotion.easeOut,
      left: cursor.x,
      top: cursor.y,
      width: math.max(4, cursor.w.roundToDouble()),
      height: math.max(4, cursor.h.roundToDouble()),
      child: InkSurface(
        source: RecipeInkSource(chartMarkRecipe, params, json: params.toJson()),
        seed: '$seed:${cursor.kind.name}',
      ),
    );
  }
}
