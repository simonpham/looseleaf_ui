import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/fields/field_frame_ink.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Combobox chips field params.
///
/// Mirrors `ComboboxChipsParams` in `src/lib/ink/recipes/combobox-ink.ts`.
final class ComboboxChipsParams {
  /// Params.
  const ComboboxChipsParams({this.disabled = false, this.invalid = false});

  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The multi-select field holding chips: a [drawFieldFrame], multiline once
/// taller than 48.
///
/// Mirrors `comboboxChipsRecipe` in `src/lib/ink/recipes/combobox-ink.ts`.
final Recipe<ComboboxChipsParams> comboboxChipsRecipe =
    defineRecipe<ComboboxChipsParams>(
      id: 'combobox-chips',
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
      draw: (ink, size, params, ctx) => drawFieldFrame(
        ink,
        size,
        FieldFrameParams(
          disabled: params.disabled,
          invalid: params.invalid,
          multiline: size.h > 48,
        ),
        ctx,
      ),
    );

/// A chip's marker tone: its paint and fill alpha.
///
/// Mirrors `ChipTone` and `TONE` in `src/lib/ink/recipes/combobox-ink.ts`.
enum ChipTone {
  hi(PaintKey.hi, 0.7),
  sky(PaintKey.sky, 0.42),
  grass(PaintKey.grass, 0.42),
  bubblegum(PaintKey.bubblegum, 0.5);

  const ChipTone(this.paint, this.alpha);

  final PaintKey paint;
  final double alpha;
}

/// Combobox chip params.
///
/// Mirrors `ComboboxChipParams` in `src/lib/ink/recipes/combobox-ink.ts`.
final class ComboboxChipParams {
  /// Params.
  const ComboboxChipParams({required this.tone, this.disabled = false});

  final ChipTone tone;
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'tone': tone.name,
    if (disabled) 'disabled': true,
  };
}

/// The length of a chip's pointed tip for a chip [h] tall.
///
/// Mirrors `chipTip` in `src/lib/ink/recipes/combobox-ink.ts`.
double chipTip(double h) => clamp(h * 0.42, 8, 13);

/// A selected value as a luggage tag: a toned marker fill, an inked outline
/// pointing to the start, and a punched hole.
///
/// Mirrors `comboboxChipRecipe` in `src/lib/ink/recipes/combobox-ink.ts`.
final Recipe<ComboboxChipParams> comboboxChipRecipe =
    defineRecipe<ComboboxChipParams>(
      id: 'combobox-chip',
      kind: 'chip',
      layers: const [LayerName.rest, LayerName.disabled],
      pad: 8,
      draw: _drawChip,
    );

void _drawChip(
  Ink ink,
  Box size,
  ComboboxChipParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final disabled = params.disabled;
  final rtl = ctx.dir == Dir.rtl;
  double x(double v) => switch (rtl) {
    true => w - v,
    false => v,
  };
  final rng = ink.next('chip');
  final tip = chipTip(h);
  double j() => rng.gauss(0, 0.28);
  final y0 = 1.6 + j(), y1 = h - 1.6 + j();
  final outline = <Pt>[
    (x(1.6 + j()), h / 2 + j()),
    (x(tip + j()), y0),
    (x(w - 2 + j()), y0 + j()),
    (x(w - 1.6 + j()), y1 + j()),
    (x(tip + j()), y1),
  ];
  final Pt hole = (x(tip * 0.72 + 3.2), h / 2 + 0.3);
  final tone = params.tone;
  final layer = switch (disabled) {
    true => LayerName.disabled,
    false => LayerName.rest,
  };
  final shift = switch (rtl) {
    true => -0.4,
    false => 0.4,
  };
  ink.layer(layer, () {
    ink.part(
      'fill',
      () => blobFill(
        ink,
        [for (final p in outline) (p.x + shift, p.y + 0.5)],
        switch (disabled) {
          true => PaintKey.pencilMark,
          false => tone.paint,
        },
        alpha: switch (disabled) {
          true => 0.3,
          false => tone.alpha,
        },
        rough: 0.5,
      ),
    );
    final hook = switch (outline[1].x > outline[0].x) {
      true => 2.2,
      false => -2.2,
    };
    final closed = <Pt>[
      ...outline,
      outline[0],
      (outline[1].x + hook, outline[1].y + 0.6),
    ];
    final quiet = ctx.calm || disabled;
    ink.stroke(
      closed,
      switch (quiet) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      switch (quiet) {
        true => const StrokeOpts(
          poly: true,
          round: 2.4,
          simple: true,
          alpha: 0.9,
        ),
        false => const StrokeOpts(poly: true, round: 2.4, simple: true),
      },
    );
    ink
      ..stroke(
        ellipsePoly(hole.x, hole.y, 1.9, 1.9, 12),
        switch (disabled) {
          true => PenName.pencilFine,
          false => PenName.inkFine,
        },
        const StrokeOpts(poly: true, round: 0, simple: true, alpha: 0.85),
      )
      ..poly(
        Material.top,
        ellipsePoly(hole.x, hole.y, 1.3, 1.3, 10),
        PaintKey.slip,
      );
  });
}
