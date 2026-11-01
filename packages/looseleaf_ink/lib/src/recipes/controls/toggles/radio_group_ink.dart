import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/toggles/draw_on_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Radio recipe params.
///
/// Mirrors `RadioParams` in `src/lib/ink/recipes/radio-group-ink.ts`.
final class RadioParams {
  /// Params.
  const RadioParams({this.disabled = false, this.invalid = false});

  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The radio button: an inked ring, two arcs on hover, a marker dot with a
/// drawn-on spiral when checked.
///
/// Mirrors `radioRecipe` in `src/lib/ink/recipes/radio-group-ink.ts`.
final Recipe<RadioParams> radioRecipe = defineRecipe<RadioParams>(
  id: 'radio-group',
  kind: 'radio',
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

void _draw(Ink ink, Box size, RadioParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final disabled = params.disabled, invalid = params.invalid;
  final s = math.min(w, h);
  final cx = w / 2;
  final cy = h / 2;
  final rad = s / 2 - 1;
  final fine = s < 18;
  final calm = ctx.calm;
  final disc = ellipsePoly(cx, cy, rad, rad, 28);

  if (!disabled) {
    ctx.lazy(
      LayerName.focus,
      (fink) => focusRing(fink, 0, 0, w, h, shape: FocusShape.ellipse),
    );
  }
  if (ctx.lazyOnly) return;

  void ring(Pen pen, [StrokeOpts? opts]) =>
      loop(ink, cx, cy, rad, rad, pen: pen, clean: true, opts: opts);
  final inkPen = switch ((invalid, calm || fine, calm, fine)) {
    (true, true, _, _) => PenName.redFine,
    (true, false, _, _) => PenName.red,
    (false, _, true, _) => PenName.pencilFine,
    (false, _, false, true) => PenName.inkFine,
    (false, _, false, false) => PenName.ink,
  };

  ink.layer(LayerName.rest, () {
    if (disabled) {
      wash(
        ink,
        disc,
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
        r: s / 2,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencil, width: 1.2),
      );
      return;
    }
    ink.poly(Material.under, disc, PaintKey.slip, 0.85);
    ring(inkPen, switch ((invalid, s >= 26)) {
      (true, _) => const StrokeOpts(width: 1.15),
      (false, true) => const StrokeOpts(width: 1.2),
      (false, false) => null,
    });
  });

  if (!disabled) {
    ink.layer(LayerName.hover, () {
      if (calm) {
        loop(
          ink,
          cx,
          cy,
          rad - 1.6,
          rad - 1.6,
          pen: switch (invalid) {
            true => PenName.redFine,
            false => PenName.pencilFine,
          },
          turns: 1.05,
          opts: const StrokeOpts(alpha: 0.75, simple: true),
        );
        return;
      }
      final d = 1.8 + s / 24;
      List<Pt> arc(double a0, double a1) => [
        for (var i = 0; i <= 5; i++)
          (
            cx + JsMath.cos(a0 + ((a1 - a0) * i) / 5) * (rad + d),
            cy + JsMath.sin(a0 + ((a1 - a0) * i) / 5) * (rad + d),
          ),
      ];
      ink.lines(
        [
          Line(
            arc(0.25, 1.05),
            o: const StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.flick),
          ),
          Line(
            arc(1.25, 1.85),
            o: const StrokeOpts(
              start: StrokeStart.soft,
              end: StrokeEnd.flick,
              width: 0.8,
            ),
          ),
        ],
        PenName.inkFine,
        const StrokeOpts(width: 1.1),
      );
    });
  }

  ink.layer(LayerName.checked, () {
    if (disabled) {
      wash(
        ink,
        ellipsePoly(cx, cy, rad * 0.6, rad * 0.6, 20),
        PaintKey.pencilMark,
        alpha: 0.55,
        material: Material.wash,
      );
      return;
    }
    final dotR = clamp(rad * 0.68, 2.6, 14);
    ink.part(
      'fill',
      () => blobFill(
        ink,
        ellipsePoly(cx, cy, dotR, dotR, 20),
        PaintKey.marker,
        alpha: 0.88,
        mis: clamp(s * 0.07, 0.8, 2),
      ),
    );
    if (invalid) ring(PenName.red, const StrokeOpts(width: 1.25));
    final spiral = spiralLines(
      ink.next('spiral'),
      cx,
      cy,
      dotR * 0.85,
      turns: switch (fine) {
        true => 1.8,
        false => 2.2,
      },
      steps: switch (fine) {
        true => 18,
        false => 24,
      },
      shrink: 0.82,
    );
    reveal(
      ink,
      id: revealId(ctx.seed, 'd'),
      lines: spiral,
      pen: switch (fine) {
        true => PenName.inkFine,
        false => PenName.ink,
      },
      box: Box(w, h),
      width: switch (fine) {
        true => 0.9,
        false => 1,
      },
      revealWidth: math.max(3, dotR * 0.9),
    );
  });
}
