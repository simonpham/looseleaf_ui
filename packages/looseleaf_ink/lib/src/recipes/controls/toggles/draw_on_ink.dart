import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The mask id of a draw-on reveal: unique per [seed] and [name].
///
/// Mirrors `revealId` in `src/lib/ink/recipes/draw-on-ink.ts`.
String revealId(String seed, String name) =>
    'll-rv-${hashSeed(seed).toRadixString(36)}$name';

/// Draws [lines] once as a symbol and shows it through a mask whose path
/// (`data-part="reveal"`) follows the same lines, so the mark can be drawn
/// on by animating the mask stroke.
///
/// Mirrors `reveal` in `src/lib/ink/recipes/draw-on-ink.ts`.
void reveal(
  Ink ink, {
  required String id,
  required List<Line> lines,
  required Pen pen,
  required Box box,
  double? width,
  double? revealWidth,
}) {
  final sym = ink.define(
    () => ink.lines(lines, pen, StrokeOpts(width: width)),
  );
  final d = [
    for (final l in lines)
      for (final (i, p) in l.pts.indexed)
        '${switch (i) {
          0 => 'M',
          _ => 'L',
        }}${JsMath.toFixed(p.x, 1)} ${JsMath.toFixed(p.y, 1)}',
  ].join();
  const pad = 12;
  final sw = revealWidth ?? math.max(3.4, math.min(box.w, box.h) * 0.3);
  ink
    ..raw(
      '<mask id="$id" maskUnits="userSpaceOnUse" x="${-pad}" y="${-pad}" '
      'width="${JsMath.numberToString(box.w + 2 * pad)}" '
      'height="${JsMath.numberToString(box.h + 2 * pad)}">'
      '<path data-part="reveal" d="$d" pathLength="1" fill="none" '
      'stroke="${paint(PaintKey.photo)}" '
      'stroke-width="${JsMath.toFixed(sw, 1)}" stroke-linejoin="round"/>'
      '</mask>',
      Material.under,
    )
    ..raw('<g mask="url(#$id)"><use href="#$sym"/></g>', Material.top);
}
