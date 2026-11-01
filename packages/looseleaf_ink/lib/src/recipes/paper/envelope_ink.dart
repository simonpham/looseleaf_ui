import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Envelope back recipe params.
///
/// Mirrors `EnvelopeBackParams` in `src/lib/ink/recipes/envelope-ink.ts`.
final class EnvelopeBackParams {
  /// Params.
  const EnvelopeBackParams({required this.stock});

  /// The paper stock.
  final StockName stock;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'stock': stock.id};
}

/// Envelope front recipe params.
///
/// Mirrors `EnvelopeFrontParams` in `src/lib/ink/recipes/envelope-ink.ts`.
final class EnvelopeFrontParams {
  /// Params.
  const EnvelopeFrontParams({
    required this.stock,
    this.stamp,
    required this.postmark,
    required this.airmail,
  });

  /// The paper stock.
  final StockName stock;

  /// The postage stamp's colour; no stamp when null.
  final Accent? stamp;

  /// A wavy postmark beside the stamp.
  final bool postmark;

  /// A striped airmail border.
  final bool airmail;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'stock': stock.id,
    'stamp': stamp?.name ?? 'none',
    'postmark': postmark,
    'airmail': airmail,
  };
}

/// How far the open flap reaches, as a share of the height.
///
/// Mirrors `FLAP` in `src/lib/ink/recipes/envelope-ink.ts`.
const double envelopeFlap = 0.5;

String _rectD(double w, double h) => 'M0 0H${num10(w)}V${num10(h)}H0z';

/// An envelope's back: the paper in rest, the flap lifted a little on hover
/// and fully open in `open`.
///
/// Mirrors `envelopeBackRecipe` in `src/lib/ink/recipes/envelope-ink.ts`.
final Recipe<EnvelopeBackParams>
envelopeBackRecipe = defineRecipe<EnvelopeBackParams>(
  id: 'envelope-back',
  kind: 'sheet',
  layers: const [LayerName.rest, LayerName.hover, LayerName.open],
  padFor: (size, params, ctx) => (size.h * envelopeFlap).ceilToDouble() + 8,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final stock = params.stock;
    final r = ink.next('back');
    String flap(double lift, String id) {
      final apexX = w / 2 + r.gauss(0, 1.5);
      final top = h * lift;
      final d = 'M1 0.5L${num10(apexX)} ${num10(-top)}L${num10(w - 1)} 0.5z';
      return paperFill(
            ink.seed,
            d,
            stock: stock,
            id: id,
            shadow: true,
            far: false,
          ) +
          pathTag(
            'M${num10(apexX)} ${num10(-top)}L${num10(w - 1)} 0.5H${num10(apexX)}z',
            fill: tok('ink'),
            op: 0.06,
          ) +
          pathTag(
            'M2 0.6H${num10(w - 2)}',
            stroke: tok('ink'),
            sw: 0.9,
            op: 0.22,
          ) +
          litEdge('M1.5 -0.2L${num10(apexX)} ${num10(-top + 0.6)}', 0.55);
    }

    ink.layer(LayerName.rest, () {
      ink
        ..raw(
          paperFill(
            ink.seed,
            _rectD(w, h),
            stock: stock,
            id: 'b',
            shadow: true,
          ),
          Material.under,
        )
        ..grow(BBox(-2, -2, w + 2, h + 2));
    });
    ink.layer(LayerName.hover, () {
      ink
        ..raw(flap(math.min(0.12, 14 / h), 'h'), Material.under)
        ..grow(BBox(-2, -h * 0.13, w + 2, 2));
    });
    ink.layer(LayerName.open, () {
      ink
        ..raw(flap(envelopeFlap, 'o'), Material.under)
        ..grow(BBox(-2, -h * envelopeFlap - 4, w + 2, 2));
    });
  },
);

/// A rectangle with a perforated (stamp) edge: semicircle bites of radius
/// [r] about every [pitch] px.
///
/// Mirrors `perfRectD` in `src/lib/ink/recipes/envelope-ink.ts`.
String perfRectD(
  double x,
  double y,
  double w,
  double h,
  double r,
  double pitch,
) {
  final nx = math.max(2, JsMath.roundInt(w / pitch));
  final ny = math.max(2, JsMath.roundInt(h / pitch));
  final gx = (w - nx * 2 * r) / (nx + 1);
  final gy = (h - ny * 2 * r) / (ny + 1);
  final rs = '${num10(r)} ${num10(r)} 0 0 0';
  final d = StringBuffer('M${num10(x)} ${num10(y)}');
  for (var i = 0; i < nx; i++) {
    d.write('h${num10(gx)}a$rs ${num10(2 * r)} 0');
  }
  d.write('h${num10(gx)}');
  for (var i = 0; i < ny; i++) {
    d.write('v${num10(gy)}a$rs 0 ${num10(2 * r)}');
  }
  d.write('v${num10(gy)}');
  for (var i = 0; i < nx; i++) {
    d.write('h${num10(-gx)}a$rs ${num10(-2 * r)} 0');
  }
  d.write('h${num10(-gx)}');
  for (var i = 0; i < ny; i++) {
    d.write('v${num10(-gy)}a$rs 0 ${num10(-2 * r)}');
  }
  return '${d}v${num10(-gy)}z';
}

/// Where the stamp sits on a [w] wide envelope: its size and top-left.
///
/// Mirrors `stampBox` in `src/lib/ink/recipes/envelope-ink.ts`.
({double sw, double sh, double x, double y}) stampBox(double w) {
  final sw = math.max(30, math.min(58, w * 0.115)).toDouble();
  return (
    sw: sw,
    sh: sw * 1.22,
    x: w - sw - math.max(12, w * 0.04),
    y: math.max(12, w * 0.04).toDouble(),
  );
}
