import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The mask id of a self-drawing mark.
///
/// Mirrors `markRevealId` in `src/lib/ink/recipes/mark-reveal-ink.ts`.
String markRevealId(String seed, String name) =>
    'll-mr-${hashSeed(seed).toRadixString(36)}$name';

/// The centre line of [lines] as path data, one decimal.
String revealPathData(List<Line> lines) => lines
    .map(
      (l) => [
        for (final (i, (x, y)) in l.pts.indexed)
          '${switch (i) {
            0 => 'M',
            _ => 'L',
          }}${JsMath.toFixed(x, 1)} ${JsMath.toFixed(y, 1)}',
      ].join(),
    )
    .join();

StrokeOpts _withWidth(StrokeOpts? o, double? width) => StrokeOpts(
  tier: o?.tier,
  wobble: o?.wobble,
  speed: o?.speed,
  start: o?.start,
  end: o?.end,
  width: width,
  alpha: o?.alpha,
  color: o?.color,
  poly: o?.poly,
  round: o?.round,
  raw: o?.raw,
  dry: o?.dry,
  press: o?.press,
  simple: o?.simple,
);

/// Draws [lines] behind a mask whose `data-part="reveal"` stroke can be
/// animated to draw the mark on.
///
/// Mirrors `revealMark` in `src/lib/ink/recipes/mark-reveal-ink.ts`.
void revealMark(
  Ink ink, {
  required String id,
  required List<Line> lines,
  required Pen pen,
  required Box box,
  required double pad,
  double? width,
  StrokeOpts? opts,
  double? revealWidth,
}) {
  final sym = ink.define(() => ink.lines(lines, pen, _withWidth(opts, width)));
  final d = revealPathData(lines);
  ink
    ..raw(
      '<mask id="$id" maskUnits="userSpaceOnUse" '
      'x="${JsMath.numberToString(-pad)}" y="${JsMath.numberToString(-pad)}" '
      'width="${JsMath.numberToString(box.w + 2 * pad)}" '
      'height="${JsMath.numberToString(box.h + 2 * pad)}">'
      '<path data-part="reveal" d="$d" pathLength="1" fill="none" '
      'stroke="${paint(PaintKey.photo)}" '
      'stroke-width="${JsMath.toFixed(revealWidth ?? 6, 1)}" '
      'stroke-linejoin="round" stroke-linecap="round"/>'
      '</mask>',
      Material.under,
    )
    ..raw('<g mask="url(#$id)"><use href="#$sym"/></g>', Material.top);
}
