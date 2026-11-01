import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Whether a bookmark toggles or always shows.
///
/// Mirrors `BookmarkParams['mode']` in `src/lib/ink/recipes/bookmark-ink.ts`.
enum BookmarkMode {
  toggle('toggle'),
  fixed('static');

  const BookmarkMode(this.id);

  /// The upstream name.
  final String id;
}

/// Bookmark ribbon recipe params.
///
/// Mirrors `BookmarkParams` in `src/lib/ink/recipes/bookmark-ink.ts`.
final class BookmarkParams {
  /// Params.
  const BookmarkParams({
    required this.tone,
    required this.mode,
    required this.disabled,
  });

  /// The ribbon colour.
  final Accent tone;

  /// A toggle (ghost at rest, ribbon when checked) or a fixed ribbon.
  final BookmarkMode mode;

  /// Draws only a ghost in the disabled layer.
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'tone': tone.name,
    'mode': mode.id,
    'disabled': disabled,
  };
}

/// The depth of the ribbon's swallowtail notch, as a share of its width.
///
/// Mirrors `NOTCH` in `src/lib/ink/recipes/bookmark-ink.ts`.
const double bookmarkNotch = 0.55;

/// The outline of a [w]×[h] ribbon with a swallowtail notch.
///
/// Mirrors `ribbonPoly` in `src/lib/ink/recipes/bookmark-ink.ts`.
List<Pt> ribbonPoly(double w, double h) {
  final notch = math.min(h * 0.4, w * bookmarkNotch);
  return [(0, 0), (w, 0), (w, h), (w / 2, h - notch), (0, h)];
}

String _ribbonD(double w, double h, Rng r) {
  final poly = ribbonPoly(w, h);
  final dense = densify([...poly, poly.first], 6);
  final p = dense.sublist(0, dense.length - 1);
  final d = StringBuffer('M${num10(p.first.x)} ${num10(p.first.y)}');
  for (final (x, y) in p.skip(1)) {
    d.write('L${num10(x + r.gauss(0, 0.22))} ${num10(y + r.gauss(0, 0.22))}');
  }
  return '${d}z';
}

/// A cloth bookmark ribbon: a pencil ghost at rest and the woven ribbon
/// when checked (always, for a fixed one), with a wash on hover.
///
/// Mirrors `bookmarkRecipe` in `src/lib/ink/recipes/bookmark-ink.ts`.
final Recipe<BookmarkParams> bookmarkRecipe = defineRecipe<BookmarkParams>(
  id: 'bookmark-ribbon',
  kind: 'bookmark',
  layers: const [
    LayerName.rest,
    LayerName.checked,
    LayerName.disabled,
    LayerName.hover,
  ],
  pad: 6,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final tone = params.tone;
    final d = _ribbonD(w, h, ink.next('edge'));
    String ribbon() {
      final r = ink.next('cloth');
      final id = 'll-bm${ink.seed.toRadixString(36)}';
      final g = StringBuffer();
      for (var x = 2.2; x < w - 1; x += 2.3) {
        g.write('M${num10(x + r.gauss(0, 0.08))} 0V${num10(h)}');
      }
      final notch = math.min(h * 0.4, w * bookmarkNotch);
      return '<clipPath id="${id}c"><path d="$d"/></clipPath>'
          '${pathTag(d, fill: tok(tone.name))}'
          '<g clip-path="url(#${id}c)">'
          '${pathTag('$g', stroke: tok('ink'), sw: 0.7, op: 0.1)}'
          '${pathTag('M0 0H${num10(w * 0.34)}V${num10(h)}H0z', fill: tok('photo'), op: 0.22)}'
          '${pathTag('M${num10(w * 0.7)} 0H${num10(w)}V${num10(h)}H${num10(w * 0.7)}z', fill: tok('ink'), op: 0.13)}'
          '${pathTag('M0 ${num10(h)}L${num10(w / 2)} ${num10(h - notch)}L${num10(w)} ${num10(h)}V${num10(h + 4)}H0z', fill: tok('ink'), op: 0.16)}'
          '</g>'
          '${pathTag('M2.6 1.5V${num10(h - 3)}M${num10(w - 2.6)} 1.5V${num10(h - 3)}', stroke: tok('photo'), sw: 0.8, op: 0.6, extra: 'stroke-dasharray="${num10(r.range(2, 2.6))} ${num10(r.range(1.5, 2.1))}"')}'
          '${pathTag(d, stroke: tok('ink'), sw: 0.7, op: 0.36)}';
    }

    void ghost(double alpha) => ink.raw(
      pathTag(d, fill: tok('paper-shade'), op: alpha) +
          pathTag(
            d,
            stroke: tok('pencil'),
            sw: 1.1,
            op: 0.85,
            extra: 'stroke-dasharray="3.6 3.2"',
          ),
      Material.under,
    );
    if (params.disabled) {
      ink.layer(LayerName.disabled, () => ghost(0.3));
      return;
    }
    if (params.mode == BookmarkMode.fixed) {
      ink.layer(LayerName.rest, () => ink.raw(ribbon(), Material.under));
      return;
    }
    ink
      ..layer(LayerName.rest, () => ghost(0.45))
      ..layer(LayerName.checked, () => ink.raw(ribbon(), Material.under));
    if (!ctx.calm) {
      ink.layer(
        LayerName.hover,
        () => wash(
          ink,
          ribbonPoly(w, h),
          PaintKey.byId(tone.name) ?? PaintKey.ink,
          alpha: 0.52,
          inset: 1.2,
        ),
      );
    }
  },
);
