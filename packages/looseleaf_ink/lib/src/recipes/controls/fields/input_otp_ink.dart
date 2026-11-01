import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// One-time-code slot params.
///
/// Mirrors `OtpSlotParams` in `src/lib/ink/recipes/input-otp-ink.ts`.
final class OtpSlotParams {
  /// Params.
  const OtpSlotParams({
    this.invalid = false,
    this.disabled = false,
    this.active = false,
    this.filled = false,
  });

  final bool invalid;
  final bool disabled;

  /// The slot holding the caret: draws an eager focus ring.
  final bool active;

  /// The slot has a character: inked instead of penciled.
  final bool filled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (invalid) 'invalid': true,
    if (disabled) 'disabled': true,
    if (active) 'active': true,
    if (filled) 'filled': true,
  };
}

/// One box of a one-time-code input.
///
/// Mirrors `otpSlotRecipe` in `src/lib/ink/recipes/input-otp-ink.ts`.
final Recipe<OtpSlotParams> otpSlotRecipe = defineRecipe<OtpSlotParams>(
  id: 'input-otp-slot',
  kind: 'field',
  layers: const [
    LayerName.rest,
    LayerName.invalid,
    LayerName.disabled,
    LayerName.focus,
  ],
  pad: 12,
  draw: _drawSlot,
);

void _drawSlot(Ink ink, Box size, OtpSlotParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final r = clamp(math.min(w, h) * 0.1, 2, 4.5);
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final calm = ctx.calm;
  if (params.active && !params.disabled) {
    ink.layer(
      LayerName.focus,
      () => focusRing(ink, 0, 0, w, h, r: r, gap: 2.6),
    );
  }
  if (params.disabled) {
    ink.layer(LayerName.disabled, () {
      wash(ink, body, PaintKey.paperShade, alpha: 0.9, material: Material.wash);
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
    });
    return;
  }
  if (params.invalid) {
    ink.layer(LayerName.invalid, () {
      ink.poly(Material.under, body, PaintKey.slip, 0.7);
      box(
        ink,
        0,
        0,
        w,
        h,
        pen: switch (calm) {
          true => PenName.redFine,
          false => PenName.red,
        },
        corner: r,
        opts: StrokeOpts(
          width: switch (calm) {
            true => 1.1,
            false => 1.25,
          },
        ),
      );
    });
    return;
  }
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, body, PaintKey.slip, 0.7);
    if (calm) {
      box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: r);
      return;
    }
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: switch (params.filled) {
        true => PenName.inkFine,
        false => PenName.pencil,
      },
      corner: r,
      opts: StrokeOpts(
        width: switch (params.filled) {
          true => 1.05,
          false => 1.15,
        },
      ),
    );
  });
}

const StrokeOpts _caretOpts = StrokeOpts(
  color: PaintKey.current,
  start: StrokeStart.pool,
  end: StrokeEnd.pool,
  simple: true,
);

/// A CSS `url(...)` of the slot's hand-drawn I-beam caret (9 × 28), drawn in
/// `currentColor`. Upstream uses it with seed `otp|caret`.
///
/// Mirrors `caretTile` in `src/lib/ink/recipes/input-otp-ink.ts`.
String otpCaretTile(String seed) {
  final ink = Ink(seed, tier: Tier.lo, grain: false);
  ink.layer(LayerName.rest, () {
    final rng = ink.next('caret');
    final x = 4.5 + rng.range(-0.25, 0.25);
    ink
      ..stroke(
        seg(x, 4, x + rng.range(-0.5, 0.5), 24, rng.range(-0.4, 0.4), 5),
        PenName.inkBrush,
        _caretOpts.merge(const StrokeOpts(width: 0.36, wobble: 0.5)),
      )
      ..stroke(
        seg(
          x - 3.3,
          3.6 + rng.range(-0.2, 0.2),
          x + 3.3,
          3.8 + rng.range(-0.2, 0.2),
          rng.range(-0.15, 0.15),
          3,
        ),
        PenName.inkBrush,
        _caretOpts.merge(const StrokeOpts(width: 0.3, wobble: 0.3)),
      )
      ..stroke(
        seg(
          x - 3.3,
          24.4 + rng.range(-0.2, 0.2),
          x + 3.3,
          24.2 + rng.range(-0.2, 0.2),
          rng.range(-0.15, 0.15),
          3,
        ),
        PenName.inkBrush,
        _caretOpts.merge(const StrokeOpts(width: 0.3, wobble: 0.3)),
      );
  });
  final svg = ink.toSvg(w: 9, h: 28, pad: 0).svg;
  final doc =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 9 28" width="9" '
      'height="28">$svg</svg>';
  return 'url("data:image/svg+xml,${Uri.encodeComponent(doc)}")';
}
