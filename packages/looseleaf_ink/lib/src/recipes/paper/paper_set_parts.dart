import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';

/// An ellipse as two arcs.
///
/// Mirrors `ellipseD` in `src/lib/ink/recipes/paper-set-ink.ts`.
String ellipseD(double cx, double cy, double rx, double ry) =>
    'M${num10(cx - rx)} ${num10(cy)}a${num10(rx)} ${num10(ry)} 0 1 0 '
    '${num10(2 * rx)} 0a${num10(rx)} ${num10(ry)} 0 1 0 ${num10(-2 * rx)} 0z';

/// The transform that mirrors a [w] wide drawing left to right.
///
/// Mirrors `MIRROR` in `src/lib/ink/recipes/paper-set-ink.ts`.
String mirrorTransform(double w) => 'translate(${num10(w)} 0) scale(-1 1)';

/// [inner] wrapped in a group mirrored across a [w] wide box.
///
/// Mirrors `mirrorX` in `src/lib/ink/recipes/paper-set-ink.ts`.
String mirrorX(double w, String inner) =>
    '<g transform="${mirrorTransform(w)}">$inner</g>';

/// A punched hole of radius [r] at `(cx, cy)` tilted by [tilt] degrees: the
/// desk showing through, an inner shadow, a lit lip and a faint rim; the
/// clip path takes [id].
///
/// Mirrors `holePunch` in `src/lib/ink/recipes/paper-set-ink.ts`.
String holePunch(String id, double cx, double cy, double r, [double tilt = 0]) {
  final rx = r * 1.03;
  final ry = r * 0.97;
  final rot = 'rotate(${n(tilt)} ${num10(cx)} ${num10(cy)})';
  final hole = ellipseD(cx, cy, rx, ry);
  final s = StringBuffer(
    '<clipPath id="$id"><path d="$hole" transform="$rot"/></clipPath>',
  )..write(pathTag(hole, fill: tok('desk-deep'), transform: rot));
  s.write(
    '<g clip-path="url(#$id)">'
    '${pathTag(circleD(cx, cy, r * 1.4), fill: tok('ink'), op: 0.4)}'
    '${pathTag(circleD(cx + r * 0.34, cy + r * 0.4, r * 0.98), fill: tok('desk-deep'))}'
    '</g>',
  );
  const a0 = -0.15 * JsMath.pi;
  const a1 = 0.62 * JsMath.pi;
  Pt p(double a) =>
      (cx + JsMath.cos(a) * (r - 0.4), cy + JsMath.sin(a) * (r - 0.4));
  final (x0, y0) = p(a0);
  final (x1, y1) = p(a1);
  s
    ..write(
      pathTag(
        'M${num10(x0)} ${num10(y0)}A${num10(r - 0.4)} ${num10(r - 0.4)} 0 0 1 '
        '${num10(x1)} ${num10(y1)}',
        stroke: tok('photo'),
        sw: 1.1,
        op: 0.85,
      ),
    )
    ..write(
      pathTag(hole, stroke: tok('ink'), sw: 0.7, op: 0.3, transform: rot),
    );
  return '$s';
}

/// A paper reinforcement ring around a hole of radius [r].
///
/// Mirrors `reinforcement` in `src/lib/ink/recipes/paper-set-ink.ts`.
String reinforcement(double cx, double cy, double r) {
  final big = r + 5.4;
  final ring = '${circleD(cx, cy, big)}${circleD(cx, cy, r - 0.3)}';
  return pathTag(
        ring,
        fill: tok('ink'),
        op: 0.16,
        transform: 'translate(.7 1.2)',
        extra: 'fill-rule="evenodd"',
      ) +
      pathTag(ring, fill: tok('photo'), extra: 'fill-rule="evenodd"') +
      pathTag(
        circleD(cx, cy, big - 0.4),
        stroke: tok('ink'),
        sw: 0.7,
        op: 0.24,
      ) +
      pathTag(
        circleD(cx, cy, (big + r) / 2),
        stroke: tok('paper-shade'),
        sw: 0.6,
        op: 0.7,
      );
}

/// A paper face for path [d]: an optional contact shadow, the face mark
/// (with its far shadow), and a faint edge of opacity [edge]. [shadow]
/// casts the stock's shadow, or [shadowKind] when set; [far] false keeps
/// only the contact shadow.
///
/// Mirrors `paperFill` in `src/lib/ink/recipes/paper-set-ink.ts`.
String paperFill(
  int seed,
  String d, {
  required StockName stock,
  String? id,
  double? edge,
  bool evenodd = false,
  bool shadow = false,
  SheetShadowKind? shadowKind,
  bool far = true,
  List<double>? inset,
}) {
  final stockDef = stockOf(stock);
  final gid = 'll-pf${seed.toRadixString(36)}${id ?? ''}';
  final kind = switch (shadow) {
    true => shadowKind ?? stockDef.shadow,
    false => shadowKind,
  };
  final contact = switch (kind) {
    final SheetShadowKind k => contactShadow(k),
    null => null,
  };
  final cast = kind != null && far && farShadow(kind) != 'none';
  final rule = switch (evenodd) {
    true => ' fill-rule="evenodd"',
    false => '',
  };
  final s = StringBuffer('<defs><path id="$gid" d="$d"$rule/></defs>');
  if (contact case (:final dy, :final a)) {
    s.write(
      '<use href="#$gid" transform="translate(0 ${num10(dy)})" '
      'fill="${tok('umber')}" fill-opacity="${js(a)}" '
      'opacity="var(--ll-shadow-k)"/>',
    );
  }
  s
    ..write(
      faceMark(
        FaceSpec(
          d: d,
          stock: stock,
          seed: seed,
          veil: false,
          evenodd: evenodd,
          cast: switch ((cast, kind)) {
            (true, final SheetShadowKind k) => FaceCast(
              kind: k,
              inset: inset ?? const [1, 1, 1, 1],
            ),
            _ => null,
          },
        ),
      ),
    )
    ..write(
      '<use href="#$gid" fill="none" stroke="${tok('ink')}" '
      'stroke-opacity="${js(edge ?? 0.14)}" stroke-width=".6"/>',
    );
  return '$s';
}

/// A lit top edge along [d].
///
/// Mirrors `litEdge` in `src/lib/ink/recipes/paper-set-ink.ts`.
String litEdge(String d, [double op = 0.7]) => pathTag(
  d,
  stroke: tok('photo'),
  sw: 1,
  op: op,
  transform: 'translate(0 -.6)',
);

/// [count] sheets peeking out below and right of a [w]×[h] sheet, each a
/// little rotated, clipped to outside the sheet; ids start with [id] and
/// sheets alternate [fills] (paint tokens).
///
/// Mirrors `stackSvg` in `src/lib/ink/recipes/paper-set-ink.ts`.
String stackSvg(
  double w,
  double h,
  int count,
  Rng r,
  String id, [
  (String, String) fills = ('paper', 'paper-shade'),
]) {
  if (count < 1) return '';
  const step = 2.6;
  final s = StringBuffer(
    '<clipPath id="${id}c"><path d="M-60 -60H${num10(w + 120)}V${num10(h + 120)}'
    'H-60zM0 0V${num10(h)}H${num10(w)}V0z" clip-rule="evenodd"/></clipPath>',
  );
  final sheets = StringBuffer();
  for (var i = count; i >= 1; i--) {
    final d = i * step;
    final rot = r.gauss(0, 0.18) * i;
    final x0 = 3 + i * 1.4;
    final y0 = 3 + i * 1.4;
    final path =
        'M${num10(x0)} ${num10(y0)}H${num10(w + d)}V${num10(h + d)}H${num10(x0)}z';
    sheets.write(
      '<g transform="rotate(${num10(rot)} ${num10(x0)} ${num10(y0)})">',
    );
    if (i == count) {
      sheets
        ..write(
          pathTag(
            path,
            fill: tok('ink'),
            op: 0.1,
            transform: 'translate(1.4 4)',
          ),
        )
        ..write(
          pathTag(
            path,
            fill: tok('ink'),
            op: 0.14,
            transform: 'translate(.6 1.6)',
          ),
        );
    }
    final fill = switch (i.isOdd) {
      true => fills.$2,
      false => fills.$1,
    };
    sheets
      ..write(pathTag(path, fill: tok(fill)))
      ..write(pathTag(path, stroke: tok('ink'), sw: 0.6, op: 0.22))
      ..write(
        pathTag(
          'M${num10(x0 + 2)} ${num10(h + d - 0.6)}H${num10(w + d - 1)}'
          'M${num10(w + d - 0.6)} ${num10(y0 + 2)}V${num10(h + d - 1)}',
          stroke: tok('photo'),
          sw: 0.8,
          op: 0.7,
        ),
      )
      ..write('</g>');
  }
  s.write('<g clip-path="url(#${id}c)">$sheets</g>');
  return '$s';
}
