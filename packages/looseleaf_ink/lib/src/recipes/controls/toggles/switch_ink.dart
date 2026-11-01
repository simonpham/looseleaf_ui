import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Switch track params.
///
/// Mirrors `SwitchParams` in `src/lib/ink/recipes/switch-ink.ts`.
final class SwitchParams {
  /// Params.
  const SwitchParams({this.disabled = false, this.invalid = false});

  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

List<Pt> _pillLine(double x, double y, double w, double h) {
  final r = h / 2;
  final pts = <Pt>[(x + w / 2, y)];
  void end(double cx, double a0) {
    for (var i = 0; i <= 12; i++) {
      final a = a0 + (i / 12) * JsMath.pi;
      pts.add((cx + JsMath.cos(a) * r, y + r + JsMath.sin(a) * r));
    }
  }

  end(x + w - r, -JsMath.pi / 2);
  end(x + r, JsMath.pi / 2);
  pts.add((x + w / 2 + math.min(3, w * 0.08), y));
  return pts;
}

List<Pt> _liftLine(double w, double h, double d) {
  final r = (h - 1) / 2;
  final cx = w - 0.5 - r + d;
  final cy = 0.5 + r + d;
  final pts = <Pt>[(0.5 + r + d + 2, cy + r), (cx, cy + r)];
  for (var i = 1; i <= 12; i++) {
    final a = JsMath.pi / 2 - (i / 12) * (JsMath.pi / 2 + 0.75);
    pts.add((cx + JsMath.cos(a) * r, cy + JsMath.sin(a) * r));
  }
  return pts;
}

/// The switch track: a ruled pill outline, a lifted shadow on hover and a
/// marker fill when checked.
///
/// Mirrors `switchRecipe` in `src/lib/ink/recipes/switch-ink.ts`.
final Recipe<SwitchParams> switchRecipe = defineRecipe<SwitchParams>(
  id: 'switch',
  kind: 'switch',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.checked,
    LayerName.focus,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, SwitchParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final disabled = params.disabled, invalid = params.invalid;
  final r = h / 2;
  final calm = ctx.calm;
  final body = pillPoly(0.5, 0.5, w - 1, h - 1);

  if (!disabled) {
    ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r));
  }
  if (ctx.lazyOnly) return;

  void outline([double? width]) {
    final pen = switch ((invalid, calm)) {
      (true, true) => PenName.redFine,
      (true, false) => PenName.red,
      (false, true) => PenName.pencilFine,
      (false, false) => PenName.ink,
    };
    ink.stroke(
      _pillLine(0.5, 0.5, w - 1, h - 1),
      pen,
      ruler.merge(StrokeOpts(width: width, simple: true)),
    );
  }

  ink.layer(LayerName.rest, () {
    if (disabled) {
      wash(
        ink,
        body,
        PaintKey.pencilMark,
        alpha: 0.35,
        material: Material.wash,
      );
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: r,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencil, width: 1.2),
      );
      return;
    }
    ink.poly(Material.under, body, PaintKey.slip, 0.85);
    outline(switch (invalid) {
      true => 1.2,
      false => null,
    });
  });

  if (!disabled) {
    ink.layer(LayerName.hover, () {
      if (calm) {
        ink.stroke(
          _pillLine(2, 2, w - 4, h - 4),
          switch (invalid) {
            true => PenName.redFine,
            false => PenName.pencilFine,
          },
          ruler.merge(const StrokeOpts(alpha: 0.75, simple: true)),
        );
        return;
      }
      ink.stroke(
        _liftLine(w, h, 2 + h / 24),
        PenName.inkFine,
        ruler.merge(const StrokeOpts(width: 1.1)),
      );
    });
  }

  ink.layer(LayerName.checked, () {
    if (disabled) {
      wash(ink, body, PaintKey.pencilMark, alpha: 0.4, material: Material.wash);
      return;
    }
    ink.part('fill', () => solidFill(ink, body, PaintKey.marker, alpha: 0.94));
    if (invalid) outline(1.3);
  });
}

/// Switch thumb params.
///
/// Mirrors `SwitchThumbParams` in `src/lib/ink/recipes/switch-ink.ts`.
final class SwitchThumbParams {
  /// Params.
  const SwitchThumbParams({this.disabled = false});

  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (disabled) 'disabled': true};
}

/// The switch thumb: a slip disc in an inked loop.
///
/// Mirrors `switchThumbRecipe` in `src/lib/ink/recipes/switch-ink.ts`.
final Recipe<SwitchThumbParams> switchThumbRecipe =
    defineRecipe<SwitchThumbParams>(
      id: 'switch-thumb',
      kind: 'thumb',
      layers: const [LayerName.rest],
      pad: 6,
      draw: _drawThumb,
    );

void _drawThumb(
  Ink ink,
  Box size,
  SwitchThumbParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final d = math.min(w, h);
  final cx = w / 2;
  final cy = h / 2;
  final rad = d / 2 - 0.8;
  ink.layer(LayerName.rest, () {
    if (params.disabled) {
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: d / 2,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencil, width: 1.1),
      );
      return;
    }
    final disc = <Pt>[
      for (var i = 0; i < 24; i++)
        (
          cx + JsMath.cos((i / 24) * JsMath.pi * 2) * (rad + 0.4),
          cy + JsMath.sin((i / 24) * JsMath.pi * 2) * (rad + 0.4),
        ),
    ];
    ink.poly(Material.under, disc, PaintKey.slip);
    loop(
      ink,
      cx,
      cy,
      rad,
      rad,
      pen: switch ((ctx.calm, d < 14)) {
        (true, _) => PenName.pencilFine,
        (false, true) => PenName.inkFine,
        (false, false) => PenName.ink,
      },
      clean: true,
      opts: const StrokeOpts(simple: true),
    );
  });
}
