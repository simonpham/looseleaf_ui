import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Stepper (number field) params.
///
/// Mirrors `StepperParams` in `src/lib/ink/recipes/stepper-ink.ts`.
final class StepperParams {
  /// Params.
  const StepperParams({this.disabled, this.invalid, this.plain});

  final bool? disabled;
  final bool? invalid;

  /// No divider ticks or underline, even when roomy.
  final bool? plain;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'disabled': ?disabled,
    'invalid': ?invalid,
    'plain': ?plain,
  };
}

void _tick(
  Ink ink,
  double x,
  double h,
  double alpha, [
  PenName pen = PenName.pencilFine,
]) {
  ink.stroke(
    [(x, 6), (x, h - 6)],
    pen,
    ruler.merge(StrokeOpts(alpha: alpha, simple: true)),
  );
}

/// The stepper field: a pencil box with divider ticks beside the buttons,
/// a lazy hover outline and focus ring, an invalid and a disabled look.
///
/// Mirrors `stepperRecipe` in `src/lib/ink/recipes/stepper-ink.ts`.
final Recipe<StepperParams> stepperRecipe = defineRecipe<StepperParams>(
  id: 'stepper',
  kind: 'field',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.focus,
    LayerName.invalid,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus, LayerName.hover],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, StepperParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final invalid = params.invalid ?? false;
  final r = clamp(math.min(w, h) * 0.08, 2, 4);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final roomy = !(params.plain ?? false) && w >= h * 2.4;
  if (params.disabled ?? false) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      wash(
        ink,
        body,
        PaintKey.paperShade,
        alpha: 0.9,
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
        opts: const StrokeOpts(color: PaintKey.pencilMark),
      );
      if (roomy) {
        _tick(ink, h, h, 0.5);
        _tick(ink, w - h, h, 0.5);
      }
    });
    return;
  }
  ctx
    ..lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r))
    ..lazy(
      LayerName.hover,
      (hv) => box(
        hv,
        0.6,
        0.6,
        w - 1.2,
        h - 1.2,
        pen: switch (invalid) {
          true => PenName.redFine,
          false => PenName.inkFine,
        },
        corner: r,
        loose: 0.7,
        opts: StrokeOpts(
          alpha: switch (invalid) {
            true => 0.7,
            false => 0.75,
          },
        ),
      ),
    );
  if (ctx.lazyOnly) return;
  if (invalid) {
    ink.layer(LayerName.invalid, () {
      ink.poly(Material.under, body, PaintKey.slip, 0.7);
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (ctx.calm) {
          true => PenName.redFine,
          false => PenName.red,
        },
        corner: r,
        opts: StrokeOpts(
          width: switch (ctx.calm) {
            true => 1.1,
            false => 1.25,
          },
        ),
      );
      if (!ctx.calm) {
        squiggle(
          ink,
          6,
          h + 5,
          clamp(w - 40, 24, 90),
          pen: PenName.redfeltFine,
          h: 7,
          amp: 0.8,
        );
      }
      if (roomy) {
        _tick(ink, h, h, 0.7, PenName.redFine);
        _tick(ink, w - h, h, 0.7, PenName.redFine);
      }
    });
    return;
  }
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, body, PaintKey.slip, 0.7);
    if (ctx.calm) {
      box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r);
    }
    if (!ctx.calm) {
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: PenName.pencil,
        corner: r,
        opts: const StrokeOpts(width: 1.15),
      );
    }
    if (!roomy) return;
    _tick(ink, h, h, 0.8);
    _tick(ink, w - h, h, 0.8);
    if (ctx.calm) return;
    final len = clamp(w - 2 * h - 22, 16, 56);
    underline(
      ink,
      w / 2 - len / 2,
      h - 6.4,
      len,
      pen: PenName.blueFine,
      kind: UnderlineKind.single,
      opts: const StrokeOpts(alpha: 0.45, simple: true),
    );
  });
}

/// Stepper tally params.
///
/// Mirrors `StepperTallyParams` in `src/lib/ink/recipes/stepper-ink.ts`.
final class StepperTallyParams {
  /// Params.
  const StepperTallyParams({required this.count});

  final int count;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'count': count};
}

/// The default tally gate height.
///
/// Mirrors `TALLY_H` in `src/lib/ink/recipes/stepper-ink.ts`.
const double tallyH = 16;

/// The width the stepper tally needs for [count] marks.
///
/// Mirrors `tallyWidth` in `src/lib/ink/recipes/stepper-ink.ts`.
double tallyWidth(int count, [double gh = tallyH]) {
  final groups = (math.max(0, count) / 5).ceil();
  return math.max(4, JsMath.round(groups * (1.05 * gh + 6) - 6 + 4)).toDouble();
}

/// Tally marks counting the stepper's value (up to 60).
///
/// Mirrors `stepperTallyRecipe` in `src/lib/ink/recipes/stepper-ink.ts`.
final Recipe<StepperTallyParams> stepperTallyRecipe =
    defineRecipe<StepperTallyParams>(
      id: 'stepper-tally',
      kind: 'tally',
      layers: const [LayerName.rest],
      pad: 6,
      draw: (ink, size, params, ctx) {
        final Box(:h) = size;
        final gh = math.min(tallyH, h - 2);
        final t = tallyLines(
          ink.next('tally'),
          2,
          (h - gh) / 2,
          math.max(0, math.min(params.count, 60)),
          gh,
        );
        ink.layer(
          LayerName.rest,
          () => ink.lines(
            t.lines,
            PenName.inkFine,
            const StrokeOpts(alpha: 0.9, simple: true),
          ),
        );
      },
    );
