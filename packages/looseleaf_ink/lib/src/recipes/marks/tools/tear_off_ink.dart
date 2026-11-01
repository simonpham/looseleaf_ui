import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Tear-off seam params.
///
/// Mirrors `TearSeamParams` in `src/lib/ink/recipes/tear-off-ink.ts`.
final class TearSeamParams {
  /// Params.
  const TearSeamParams({this.scissors, this.inset});

  /// Draws little scissors at the start of the seam (default true).
  final bool? scissors;

  /// How far the dashes sit from the centre line (default 5).
  final double? inset;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'scissors': ?scissors, 'inset': ?inset};
}

const StrokeOpts _soft = StrokeOpts(
  start: StrokeStart.soft,
  end: StrokeEnd.soft,
);

/// The perforated seam of a tear-off stub, with scissors.
///
/// Mirrors `tearSeamRecipe` in `src/lib/ink/recipes/tear-off-ink.ts`.
final Recipe<TearSeamParams> tearSeamRecipe = defineRecipe<TearSeamParams>(
  id: 'tear-off-seam',
  kind: 'tear-off-seam',
  layers: const [LayerName.rest],
  pad: 8,
  draw: _drawSeam,
);

void _drawSeam(Ink ink, Box size, TearSeamParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final inset = params.inset ?? 5;
  final scissors = (params.scissors ?? true) && !ctx.calm;
  final vertical = h >= w;
  final len = switch (vertical) {
    true => h,
    false => w,
  };
  Pt at(double along, double across) => switch (vertical) {
    true => (w / 2 + across, along),
    false => (along, h / 2 + across),
  };
  ink.layer(LayerName.rest, () {
    final dashes = <Line>[];
    final from = switch (scissors) {
      true => 34.0,
      false => 6.0,
    };
    for (var a = from; a < len - 6; a += 9.5) {
      dashes.add(
        Line([
          at(a, inset),
          at(math.min(a + 5.2, len - 6), inset + 0.15),
        ], o: _soft),
      );
    }
    ink.lines(
      dashes,
      PenName.pencilFine,
      const StrokeOpts(alpha: 0.85, simple: true),
    );
    if (!scissors) return;
    const s = 1.0;
    ink.lines(
      [
        Line([at(9 * s, -3.4), at(27 * s, 1.6)], o: _soft),
        Line([at(9 * s, 3.4), at(27 * s, -1.6)], o: _soft),
      ],
      PenName.inkFine,
      const StrokeOpts(width: 1.05),
    );
    for (final side in const [-1, 1]) {
      final c = at(4.6, side * 4.6);
      loop(ink, c.x, c.y, 3.1, 3.1, pen: PenName.inkFine, turns: 1.08);
    }
  });
}

/// Which way the tear hint points.
enum TearToward { right, left, down }

/// Tear-off hint params.
///
/// Mirrors `TearHintParams` in `src/lib/ink/recipes/tear-off-ink.ts`.
final class TearHintParams {
  /// Params.
  const TearHintParams({required this.toward});

  final TearToward toward;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'toward': toward.name};
}

/// A pencil arrow hinting which way to tear.
///
/// Mirrors `tearHintRecipe` in `src/lib/ink/recipes/tear-off-ink.ts`.
final Recipe<TearHintParams> tearHintRecipe = defineRecipe<TearHintParams>(
  id: 'tear-off-hint',
  kind: 'tear-off-hint',
  layers: const [LayerName.rest],
  pad: 6,
  draw: _drawHint,
);

void _drawHint(Ink ink, Box size, TearHintParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final cx = w / 2, cy = h / 2;
  final Pt dir = switch (params.toward) {
    TearToward.right => (1, 0),
    TearToward.left => (-1, 0),
    TearToward.down => (0, 1),
  };
  final Pt nrm = (-dir.y, dir.x);
  Pt at(double a, double b) =>
      (cx + dir.x * a + nrm.x * b, cy + dir.y * a + nrm.y * b);
  ink.layer(LayerName.rest, () {
    final from = at(-12, 5), to = at(11, -2), tip = at(13, -2);
    ink.lines(
      [
        Line(
          seg(
            from.x,
            from.y,
            to.x,
            to.y,
            switch (params.toward) {
              TearToward.down => 3,
              _ => -3,
            },
            8,
          ),
          o: _soft,
        ),
      ],
      PenName.pencil,
      const StrokeOpts(width: 1.1, alpha: 0.9),
    );
    ink.lines(
      [
        Line(seg(at(6, 5).x, at(6, 5).y, tip.x, tip.y, 0, 3), o: _soft),
        Line(seg(at(7, -9).x, at(7, -9).y, tip.x, tip.y, 0, 3), o: _soft),
      ],
      PenName.pencil,
      const StrokeOpts(width: 1.1, alpha: 0.9),
    );
  });
}

/// The focus ring of the tear-off stub.
///
/// Mirrors `tearStubRecipe` in `src/lib/ink/recipes/tear-off-ink.ts`.
final Recipe<NoParams> tearStubRecipe = defineRecipe<NoParams>(
  id: 'tear-off-stub',
  kind: 'tear-off-stub',
  layers: const [LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(f, -1, -1, w + 2, h + 2, r: 4),
    );
  },
);
