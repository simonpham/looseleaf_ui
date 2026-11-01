import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The size the peel corner flap is designed at.
///
/// Mirrors `PEEL_UNIT` in `src/lib/ink/recipes/peel-corner-ink.ts`.
const double peelUnit = 120;

/// Peel corner flap recipe params.
///
/// Mirrors `PeelFlapParams` in `src/lib/ink/recipes/peel-corner-ink.ts`.
final class PeelFlapParams {
  /// Params.
  const PeelFlapParams({this.back, this.mirror});

  /// The paint of the flap's back; defaults to [PaintKey.paper].
  final PaintKey? back;

  /// Peels the other corner.
  final bool? mirror;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (back case final PaintKey b) 'back': b.id,
    if (mirror case final bool m) 'mirror': m,
  };
}

/// A peeled-back page corner: shadow bands, the curled flap, its highlight
/// and ink edges.
///
/// Mirrors `peelFlapRecipe` in `src/lib/ink/recipes/peel-corner-ink.ts`.
final Recipe<PeelFlapParams> peelFlapRecipe = defineRecipe<PeelFlapParams>(
  id: 'peel-corner-flap',
  kind: 'peel-corner-flap',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _drawFlap,
);

void _drawFlap(Ink ink, Box size, PeelFlapParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final back = params.back ?? PaintKey.paper;
  final mirror = params.mirror ?? false;
  final u = math.min(w, h);
  double x(double v) => switch (mirror) {
    true => u - v,
    false => v,
  };
  String s(double v) => JsMath.numberToString(v);
  String poly(List<Pt> p) =>
      'M${p.map((pt) => '${s(x(pt.x))} ${s(pt.y)}').join('L')}Z';
  ink.layer(LayerName.rest, () {
    void band(double a, double b, double op) => ink.flat(
      Material.wash,
      poly([(u, a), (a, u), (b, u), (u, b)]),
      PaintKey.ink,
      op: op,
    );
    band(0, 8, 0.26);
    band(8, 20, 0.14);
    if (!ctx.calm) band(20, 38, 0.07);
    final r = ink.next('flap');
    final cx = r.gauss(2, 1.3);
    final cy = r.gauss(2, 1.3);
    final bowTop = r.gauss(3.6, 1.2);
    final bowSide = r.gauss(3.6, 1.2);
    final flap =
        'M${s(x(0))} ${s(u)}L${s(x(u))} 0'
        'Q${s(x((u + cx) / 2))} ${s(cy / 2 + bowTop)} ${s(x(cx))} ${s(cy)}'
        'Q${s(x(cx / 2 + bowSide))} ${s((u + cy) / 2)} ${s(x(0))} ${s(u)}Z';
    ink
      ..flat(Material.wash, flap, back)
      ..flat(
        Material.wash,
        poly([(0, u), (u, 0), (u - 16, 0), (0, u - 16)]),
        PaintKey.photo,
        op: 0.55,
      )
      ..flat(
        Material.wash,
        poly([(cx, cy), (u * 0.34, 0), (0, u * 0.34)]),
        PaintKey.ink,
        op: 0.06,
      );
    line(
      ink,
      x(0),
      u,
      x(cx),
      cy,
      pen: PenName.inkFine,
      opts: const StrokeOpts(alpha: 0.85),
    );
    line(
      ink,
      x(cx),
      cy,
      x(u),
      0,
      pen: PenName.inkFine,
      opts: const StrokeOpts(alpha: 0.85),
    );
    line(
      ink,
      x(0),
      u,
      x(u),
      0,
      pen: PenName.pencilFine,
      opts: const StrokeOpts(alpha: 0.7),
    );
  });
}

/// The peel corner's trigger: only a lazy focus ring.
///
/// Mirrors `peelTriggerRecipe` in `src/lib/ink/recipes/peel-corner-ink.ts`.
final Recipe<NoParams> peelTriggerRecipe = defineRecipe<NoParams>(
  id: 'peel-corner-trigger',
  kind: 'peel-corner-trigger',
  layers: const [LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 6));
  },
);
