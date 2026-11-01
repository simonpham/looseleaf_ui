import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Dropzone recipe params.
///
/// Mirrors `DropzoneParams` in `src/lib/ink/recipes/dropzone-ink.ts`.
final class DropzoneParams {
  /// Params.
  const DropzoneParams({this.over, this.invalid, this.disabled});

  /// Files are being dragged over the zone.
  final bool? over;
  final bool? invalid;
  final bool? disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (over case final bool v) 'over': v,
    if (invalid case final bool v) 'invalid': v,
    if (disabled case final bool v) 'disabled': v,
  };
}

String _path(List<Pt> pts) =>
    'M${pts.map((p) => '${n(p.x)} ${n(p.y)}').join('L')}Z';

void _sewn(
  Ink ink,
  double w,
  double h, {
  required String colour,
  required double width,
  required (double, double) dash,
  required double alpha,
}) {
  final inset = switch (math.min(w, h) > 60) {
    true => 6.0,
    false => 3.0,
  };
  final r = math.max(2.0, clamp(math.min(w, h) * 0.09, 6, 14) - inset * 0.5);
  final iw = w - 2 * inset, ih = h - 2 * inset;
  final perimeter = 2 * (iw + ih) - 8 * r + 2 * JsMath.pi * r;
  final unit = dash.$1 + dash.$2;
  final k = perimeter / (math.max(4, JsMath.roundInt(perimeter / unit)) * unit);
  ink.raw(
    '<path d="${_path(roundRectPoly(inset, inset, iw, ih, r, 6))}" '
    'fill="none" stroke="$colour" '
    'stroke-width="${JsMath.numberToString(width)}" stroke-linecap="round" '
    'stroke-linejoin="round" '
    'stroke-dasharray="${n(dash.$1 * k)} ${n(dash.$2 * k)}" '
    'stroke-opacity="${JsMath.numberToString(alpha)}"/>',
    Material.pencil,
  );
}

/// A file dropzone: a paper wash with a sewn (dashed) border that changes
/// with the drag-over, invalid and disabled states, a lazy hover and focus.
///
/// Mirrors `dropzoneRecipe` in `src/lib/ink/recipes/dropzone-ink.ts`.
final Recipe<DropzoneParams> dropzoneRecipe = defineRecipe<DropzoneParams>(
  id: 'dropzone',
  kind: 'field',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.focus,
    LayerName.open,
    LayerName.invalid,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus, LayerName.hover],
  pad: 12,
  draw: _drawZone,
);

void _drawZone(Ink ink, Box size, DropzoneParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final r = clamp(math.min(w, h) * 0.09, 6, 14);
  final body = roundRectPoly(2, 2, w - 4, h - 4, r, 6);
  if (params.disabled ?? false) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      wash(ink, body, PaintKey.paperShade, alpha: 0.9, material: Material.wash);
      _sewn(
        ink,
        w,
        h,
        colour: 'var(--ll-pencil-mark)',
        width: 1.6,
        dash: (7, 6),
        alpha: 0.75,
      );
    });
    return;
  }
  ctx
    ..lazy(
      LayerName.focus,
      (f) => focusRing(
        f,
        0,
        0,
        w,
        h,
        r: r,
        opts: switch (w > 280) {
          true => const StrokeOpts(simple: true),
          false => null,
        },
      ),
    )
    ..lazy(LayerName.hover, (hv) {
      wash(hv, body, PaintKey.hi, alpha: 0.3, material: Material.wash);
      _sewn(
        hv,
        w,
        h,
        colour: 'var(--ll-ink-soft)',
        width: 1.2,
        dash: (9, 5),
        alpha: 0.55,
      );
    });
  if (ctx.lazyOnly) return;
  if (params.over ?? false) {
    ink.layer(LayerName.open, () {
      wash(
        ink,
        body,
        PaintKey.paperShade,
        alpha: 0.92,
        material: Material.wash,
      );
      wash(ink, body, PaintKey.hi, alpha: 0.62, material: Material.wash);
      _sewn(
        ink,
        w,
        h,
        colour: 'var(--ll-ink-you)',
        width: 2.4,
        dash: (11, 6),
        alpha: 0.95,
      );
    });
    return;
  }
  if (params.invalid ?? false) {
    ink.layer(LayerName.invalid, () {
      wash(ink, body, PaintKey.paper, alpha: 0.92, material: Material.wash);
      wash(ink, body, PaintKey.red, alpha: 0.12, material: Material.wash);
      _sewn(
        ink,
        w,
        h,
        colour: 'var(--ll-red)',
        width: 2,
        dash: (9, 6),
        alpha: 0.9,
      );
    });
    return;
  }
  ink.layer(LayerName.rest, () {
    wash(ink, body, PaintKey.paperShade, alpha: 0.92, material: Material.wash);
    _sewn(
      ink,
      w,
      h,
      colour: 'var(--ll-pencil)',
      width: switch (ctx.calm) {
        true => 1.2,
        false => 1.9,
      },
      dash: switch (ctx.calm) {
        true => (5, 5),
        false => (9, 6),
      },
      alpha: 0.92,
    );
  });
}

/// A dropped file's upload status.
enum DropzoneItemStatus { idle, done, error }

/// Dropzone item recipe params.
///
/// Mirrors `DropzoneItemParams` in `src/lib/ink/recipes/dropzone-ink.ts`.
final class DropzoneItemParams {
  /// Params.
  const DropzoneItemParams({required this.status});

  final DropzoneItemStatus status;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'status': status.name};
}

/// The rule under a dropped file: a pencil line, red with a squiggle when
/// the upload failed.
///
/// Mirrors `dropzoneItemRecipe` in `src/lib/ink/recipes/dropzone-ink.ts`.
final Recipe<DropzoneItemParams> dropzoneItemRecipe =
    defineRecipe<DropzoneItemParams>(
      id: 'dropzone-item',
      kind: 'rule',
      layers: const [LayerName.rest, LayerName.invalid],
      pad: 12,
      draw: _drawItem,
    );

void _drawItem(
  Ink ink,
  Box size,
  DropzoneItemParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  if (params.status == DropzoneItemStatus.error) {
    ink.layer(LayerName.invalid, () {
      line(
        ink,
        0,
        h - 0.75,
        w,
        h - 0.75,
        pen: switch (ctx.calm) {
          true => PenName.redFine,
          false => PenName.red,
        },
        opts: const StrokeOpts(alpha: 0.85, simple: true),
      );
      if (!ctx.calm && w > 60) {
        squiggle(
          ink,
          4,
          h + 3.5,
          math.min(w - 8, 120.0),
          pen: PenName.redfeltFine,
          h: 6,
          amp: 0.7,
        );
      }
    });
    return;
  }
  ink.layer(
    LayerName.rest,
    () => line(
      ink,
      0,
      h - 0.8,
      w,
      h - 0.8,
      pen: PenName.pencilFine,
      opts: StrokeOpts(
        alpha: switch (ctx.calm) {
          true => 0.7,
          false => 0.55,
        },
        simple: true,
      ),
    ),
  );
}
