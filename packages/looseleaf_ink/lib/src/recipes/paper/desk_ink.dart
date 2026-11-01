import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';

/// Things that can lie on the desk.
///
/// Mirrors `DeskObject` in `src/lib/ink/recipes/desk-ink.ts`.
enum DeskObject { coffee, pencil, clips, ruler, pins }

/// Every desk object, in upstream order (`DESK_OBJECTS`).
const List<DeskObject> deskObjects = DeskObject.values;

/// A wooden pencil [length] px long (190 by default) in [color] (lemon by
/// default; upstream allows lemon, tomato, sky, grass, grape and teal):
/// eraser, ferrule, painted barrel with lettering, sharpened cone and lead.
///
/// Mirrors `pencil` in `src/lib/ink/recipes/desk-ink.ts`.
InkResult pencilProp(
  Object seed, {
  double? length,
  Accent? color,
  Tier? tier,
  bool? calm,
}) {
  final ink = Ink(seed, tier: tier, calm: calm);
  final len = length ?? 190;
  final t = clamp(len * 0.078, 10, 20);
  final r = ink.next('pencil');
  final col = tok((color ?? Accent.lemon).name);
  final eraserEnd = t * 0.95;
  final ferruleEnd = t * 2.05;
  final coneStart = len - t * 2.05;
  final tipStart = len - t * 0.5;
  double j() => r.gauss(0, 0.18);
  String barrel(double y0, double y1) =>
      'M${num10(ferruleEnd)} ${num10(y0)}H${num10(coneStart)}V${num10(y1)}'
      'H${num10(ferruleEnd)}z';
  final s = StringBuffer()
    ..write(pathTag(barrel(0, t), fill: col))
    ..write(pathTag(barrel(0, t * 0.34), fill: tok('photo'), op: 0.42))
    ..write(pathTag(barrel(t * 0.68, t), fill: tok('ink'), op: 0.2))
    ..write(
      pathTag(
        'M${num10(ferruleEnd)} ${num10(t * 0.34)}H${num10(coneStart)}'
        'M${num10(ferruleEnd)} ${num10(t * 0.68)}H${num10(coneStart)}',
        stroke: tok('ink'),
        sw: 0.5,
        op: 0.2,
      ),
    );
  final dash = StringBuffer();
  for (var x = ferruleEnd + 16; x < coneStart - 40; x += 5.2) {
    dash.write(
      'M${num10(x)} ${num10(t / 2 + j())}h${num10(r.range(1.8, 3.2))}',
    );
  }
  s
    ..write(pathTag('$dash', stroke: tok('ink'), sw: 1.1, op: 0.42))
    ..write(
      pathTag(
        'M${num10(coneStart)} 0L${num10(tipStart)} ${num10(t * 0.34)}'
        'L${num10(tipStart)} ${num10(t * 0.66)}L${num10(coneStart)} ${num10(t)}z',
        fill: tok('kraft'),
      ),
    )
    ..write(
      pathTag(
        'M${num10(coneStart)} 0L${num10(tipStart)} ${num10(t * 0.34)}'
        'L${num10(tipStart)} ${num10(t * 0.5)}L${num10(coneStart)} ${num10(t * 0.3)}z',
        fill: tok('photo'),
        op: 0.45,
      ),
    )
    ..write(
      pathTag(
        'M${num10(coneStart)} ${num10(t)}L${num10(tipStart)} ${num10(t * 0.66)}'
        'L${num10(tipStart)} ${num10(t * 0.5)}L${num10(coneStart)} ${num10(t * 0.7)}z',
        fill: tok('ink'),
        op: 0.16,
      ),
    )
    ..write(
      pathTag(
        'M${num10(coneStart + t * 0.05)} ${num10(t * 0.02)}'
        'q${num10(t * 0.18)} ${num10(t * 0.48)} ${num10(-t * 0.02)} ${num10(t * 0.96)}',
        stroke: tok('ink'),
        sw: 0.6,
        op: 0.28,
      ),
    )
    ..write(
      pathTag(
        'M${num10(tipStart - 1)} ${num10(t * 0.34)}L${num10(len)} '
        '${num10(t * 0.5 + j())}L${num10(tipStart - 1)} ${num10(t * 0.66)}z',
        fill: tok('ink'),
      ),
    )
    ..write(
      pathTag(
        'M${num10(eraserEnd)} 0H${num10(ferruleEnd)}V${num10(t)}H${num10(eraserEnd)}z',
        fill: tok('pencil-mark'),
      ),
    )
    ..write(
      pathTag(
        'M${num10(eraserEnd)} 0H${num10(ferruleEnd)}V${num10(t * 0.34)}'
        'H${num10(eraserEnd)}z',
        fill: tok('photo'),
        op: 0.7,
      ),
    )
    ..write(
      pathTag(
        'M${num10(eraserEnd)} ${num10(t * 0.68)}H${num10(ferruleEnd)}V${num10(t)}'
        'H${num10(eraserEnd)}z',
        fill: tok('ink'),
        op: 0.28,
      ),
    )
    ..write(
      pathTag(
        'M${num10(eraserEnd + t * 0.3)} 0v${num10(t)}'
        'M${num10(eraserEnd + t * 0.62)} 0v${num10(t)}'
        'M${num10(ferruleEnd - t * 0.3)} 0v${num10(t)}',
        stroke: tok('ink'),
        sw: 0.55,
        op: 0.35,
      ),
    )
    ..write(
      pathTag(
        'M${num10(t * 0.34)} 0H${num10(eraserEnd)}V${num10(t)}H${num10(t * 0.34)}'
        'Q0 ${num10(t)} 0 ${num10(t / 2)}Q0 0 ${num10(t * 0.34)} 0z',
        fill: tok('bubblegum'),
      ),
    )
    ..write(
      pathTag(
        'M${num10(t * 0.34)} 0H${num10(eraserEnd)}V${num10(t * 0.32)}'
        'H${num10(t * 0.05)}Q${num10(t * 0.12)} 0 ${num10(t * 0.34)} 0z',
        fill: tok('photo'),
        op: 0.4,
      ),
    )
    ..write(
      pathTag(
        'M${num10(t * 0.05)} ${num10(t * 0.7)}H${num10(eraserEnd)}V${num10(t)}'
        'H${num10(t * 0.34)}Q0 ${num10(t)} 0 ${num10(t * 0.78)}z',
        fill: tok('ink'),
        op: 0.16,
      ),
    );
  final outline = polyD([
    (t * 0.1, 0),
    (coneStart, 0),
    (tipStart, t * 0.34),
    (len, t * 0.5),
    (tipStart, t * 0.66),
    (coneStart, t),
    (t * 0.1, t),
  ], true);
  s
    ..write(pathTag(outline, stroke: tok('ink'), sw: 0.7, op: 0.3))
    ..write(
      pathTag(
        'M${num10(ferruleEnd)} 0.5H${num10(coneStart)}',
        stroke: tok('photo'),
        sw: 0.9,
        op: 0.8,
      ),
    );
  final angle = r.range(-3, 3);
  ink
    ..raw(
      '<g transform="rotate(${num10(angle)} ${num10(len / 2)} ${num10(t / 2)})">'
      '$s</g>',
      Material.top,
    )
    ..grow(BBox(0, -2, len, t + 2));
  return ink.toSvg(w: len, h: t, pad: 4);
}
