import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// How far the thumb's center stays from the track ends.
///
/// Mirrors `THUMB_INSET` in `src/lib/ink/recipes/slider-ink.ts`.
const double thumbInset = 10;

Pt _along(bool vertical, double t, double c) => switch (vertical) {
  true => (c, t),
  false => (t, c),
};

/// Slider track params.
///
/// Mirrors `SliderTrackParams` in `src/lib/ink/recipes/slider-ink.ts`.
final class SliderTrackParams {
  /// Params.
  const SliderTrackParams({
    this.vertical = false,
    this.ticks,
    this.disabled = false,
    this.invalid = false,
  });

  final bool vertical;

  /// The number of tick intervals under the track (none when null or 0).
  final int? ticks;
  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (vertical) 'vertical': true,
    'ticks': ?ticks,
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The slider track: a shaded pill groove in a fine ink box, with optional
/// ticks below.
///
/// Mirrors `sliderTrackRecipe` in `src/lib/ink/recipes/slider-ink.ts`.
final Recipe<SliderTrackParams> sliderTrackRecipe =
    defineRecipe<SliderTrackParams>(
      id: 'slider-track',
      kind: 'slider',
      layers: const [LayerName.rest],
      pad: 12,
      draw: _drawTrack,
    );

void _drawTrack(
  Ink ink,
  Box size,
  SliderTrackParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final vertical = params.vertical;
  final ticks = params.ticks ?? 0;
  final disabled = params.disabled;
  final len = switch (vertical) {
    true => h,
    false => w,
  };
  final th = switch (vertical) {
    true => w,
    false => h,
  };
  final calm = ctx.calm;
  final c0 = th * 0.12;
  final c1 = th * 0.88;
  ink.layer(LayerName.rest, () {
    if (disabled) {
      final groove = switch (vertical) {
        true => roundRectPoly(c0, 0, c1 - c0, len, 2),
        false => roundRectPoly(0, c0, len, c1 - c0, 2),
      };
      wash(
        ink,
        groove,
        PaintKey.pencilMark,
        alpha: 0.3,
        material: Material.wash,
      );
      const opts = StrokeOpts(color: PaintKey.pencil, width: 1);
      if (vertical) {
        dashedBox(
          ink,
          c0,
          0,
          c1 - c0,
          len,
          r: 2,
          pen: PenName.pencil,
          opts: opts,
        );
      }
      if (!vertical) {
        dashedBox(
          ink,
          0,
          c0,
          len,
          c1 - c0,
          r: 2,
          pen: PenName.pencil,
          opts: opts,
        );
      }
    }
    if (!disabled) _groove(ink, vertical, len, th, calm, params.invalid);
    if (ticks > 0) _ticks(ink, vertical, len, th, ticks, disabled);
  });
}

void _groove(
  Ink ink,
  bool vertical,
  double len,
  double th,
  bool calm,
  bool invalid,
) {
  final pill = switch (vertical) {
    true => pillPoly(0.7, 0, th - 1.4, len),
    false => pillPoly(0, 0.7, len, th - 1.4),
  };
  solidFill(ink, pill, PaintKey.paperShade, alpha: 1, material: Material.wash);
  box(
    ink,
    switch (vertical) {
      true => 0.7,
      false => 0,
    },
    switch (vertical) {
      true => 0,
      false => 0.7,
    },
    switch (vertical) {
      true => th - 1.4,
      false => len,
    },
    switch (vertical) {
      true => len,
      false => th - 1.4,
    },
    pen: switch ((invalid, calm)) {
      (true, true) => PenName.redFine,
      (true, false) => PenName.red,
      (false, _) => PenName.inkFine,
    },
    corner: (th - 1.4) / 2,
    opts: StrokeOpts(width: 1.15, simple: len > 500),
  );
}

void _ticks(
  Ink ink,
  bool vertical,
  double len,
  double th,
  int ticks,
  bool disabled,
) {
  final inset = math.min(thumbInset, len / 4);
  for (var i = 0; i <= ticks; i++) {
    final t = inset + ((len - 2 * inset) * i) / ticks;
    final major = i == 0 || i == ticks;
    final from = th + 2.2;
    final to =
        from +
        switch (major) {
          true => 7.5,
          false => 5,
        };
    ink.stroke(
      [_along(vertical, t, from), _along(vertical, t + 0.3, to)],
      switch (disabled) {
        true => PenName.pencil,
        false => PenName.inkFine,
      },
      StrokeOpts(
        width: switch (major) {
          true => 1.1,
          false => 0.95,
        },
        alpha: switch (disabled) {
          true => 0.6,
          false => 0.9,
        },
        start: StrokeStart.soft,
        end: StrokeEnd.flick,
        wobble: 0.3,
        simple: true,
      ),
    );
  }
}

/// The slider range's marker; `id` is the upstream name.
enum SliderTone {
  marker('marker', PaintKey.marker),
  hi('hi', PaintKey.hi),
  blue('blue', PaintKey.inkYou);

  const SliderTone(this.id, this.paint);

  /// The upstream name.
  final String id;

  /// The fill paint.
  final PaintKey paint;
}

/// Slider range params.
///
/// Mirrors `SliderRangeParams` in `src/lib/ink/recipes/slider-ink.ts`.
final class SliderRangeParams {
  /// Params.
  const SliderRangeParams({
    this.vertical = false,
    this.tone,
    this.disabled = false,
  });

  final bool vertical;

  /// The marker, [SliderTone.marker] when null.
  final SliderTone? tone;
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (vertical) 'vertical': true,
    'tone': ?tone?.id,
    if (disabled) 'disabled': true,
  };
}

/// The filled part of a slider: a solid marker pill.
///
/// Mirrors `sliderRangeRecipe` in `src/lib/ink/recipes/slider-ink.ts`.
final Recipe<SliderRangeParams> sliderRangeRecipe =
    defineRecipe<SliderRangeParams>(
      id: 'slider-range',
      kind: 'slider',
      layers: const [LayerName.rest],
      pad: 12,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final len = switch (params.vertical) {
          true => h,
          false => w,
        };
        final th = switch (params.vertical) {
          true => w,
          false => h,
        };
        ink.layer(LayerName.rest, () {
          final color = switch (params.disabled) {
            true => PaintKey.pencilMark,
            false => (params.tone ?? SliderTone.marker).paint,
          };
          final pill = switch (params.vertical) {
            true => pillPoly(1.6, 0, th - 3.2, len),
            false => pillPoly(0, 1.6, len, th - 3.2),
          };
          solidFill(
            ink,
            pill,
            color,
            alpha: switch (params.disabled) {
              true => 0.5,
              false => 0.96,
            },
          );
        });
      },
    );

/// Slider thumb params.
///
/// Mirrors `SliderThumbParams` in `src/lib/ink/recipes/slider-ink.ts`.
final class SliderThumbParams {
  /// Params.
  const SliderThumbParams({this.disabled = false, this.invalid = false});

  final bool disabled;
  final bool invalid;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (disabled) 'disabled': true,
    if (invalid) 'invalid': true,
  };
}

/// The slider thumb: a slip disc in an inked loop, highlighted on hover.
///
/// Mirrors `sliderThumbRecipe` in `src/lib/ink/recipes/slider-ink.ts`.
final Recipe<SliderThumbParams> sliderThumbRecipe =
    defineRecipe<SliderThumbParams>(
      id: 'slider-thumb',
      kind: 'thumb',
      layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
      lazy: const [LayerName.focus],
      pad: 12,
      draw: _drawThumb,
    );

void _drawThumb(
  Ink ink,
  Box size,
  SliderThumbParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final disabled = params.disabled;
  final d = math.min(w, h);
  final cx = w / 2;
  final cy = h / 2;
  final rad = d / 2 - 1;
  final calm = ctx.calm;
  if (!disabled) {
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, 0, 0, w, h, shape: FocusShape.ellipse),
    );
  }
  if (ctx.lazyOnly) return;
  final disc = ellipsePoly(cx, cy, rad + 0.4, rad + 0.4, 24);
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, disc, PaintKey.slip);
    if (disabled) {
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
      wash(
        ink,
        ellipsePoly(cx, cy, 2.6, 2.6, 12),
        PaintKey.pencilMark,
        alpha: 0.6,
        material: Material.wash,
      );
      return;
    }
    loop(
      ink,
      cx,
      cy,
      rad,
      rad,
      pen: switch ((params.invalid, calm)) {
        (true, true) => PenName.redFine,
        (true, false) => PenName.red,
        (false, true) => PenName.pencilFine,
        (false, false) => PenName.ink,
      },
      clean: true,
    );
  });
  if (disabled) return;
  ink.layer(LayerName.hover, () {
    if (calm) {
      loop(
        ink,
        cx,
        cy,
        rad - 1.6,
        rad - 1.6,
        pen: PenName.pencilFine,
        turns: 1.05,
        opts: const StrokeOpts(alpha: 0.75, simple: true),
      );
      return;
    }
    solidFill(
      ink,
      ellipsePoly(cx, cy, rad - 1.2, rad - 1.2, 24),
      PaintKey.hi,
      alpha: 0.55,
    );
  });
}
