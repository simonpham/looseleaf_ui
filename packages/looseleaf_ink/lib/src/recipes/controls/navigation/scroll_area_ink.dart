import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The direction a scroll bar runs.
enum ScrollOrientation { vertical, horizontal }

/// Scroll track and thumb params.
///
/// Mirrors `{ orientation: ScrollOrientation }` in
/// `src/lib/ink/recipes/scroll-area-ink.ts`.
final class ScrollBarParams {
  /// Params.
  const ScrollBarParams({required this.orientation});

  final ScrollOrientation orientation;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'orientation': orientation.name};
}

List<Pt> _along(ScrollOrientation o, double len, double mid, double inset) {
  final end = inset + math.max(1, len - 2 * inset);
  return switch (o) {
    ScrollOrientation.vertical => [(mid, inset), (mid, end)],
    ScrollOrientation.horizontal => [(inset, mid), (end, mid)],
  };
}

/// The scroll track: a faint pencil rule.
///
/// Mirrors `scrollTrackRecipe` in `src/lib/ink/recipes/scroll-area-ink.ts`.
final Recipe<ScrollBarParams> scrollTrackRecipe = defineRecipe<ScrollBarParams>(
  id: 'scroll-track',
  kind: 'track',
  layers: const [LayerName.rest],
  pad: 2,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final vertical = params.orientation == ScrollOrientation.vertical;
    final len = switch (vertical) {
      true => h,
      false => w,
    };
    final mid =
        switch (vertical) {
          true => w,
          false => h,
        } /
        2;
    ink.layer(LayerName.rest, () {
      ink.stroke(
        _along(params.orientation, len, mid, 2),
        PenName.pencilFine,
        ruler.merge(const StrokeOpts(alpha: 0.4)),
      );
    });
  },
);

final PenSpec _lead = PenName.pencil.spec.copyWith(
  w: 3.6,
  dryAmt: 0.3,
  dryWl: 9,
  dens: 0.9,
  wob: const Wobble(amp: 0.5, wl: 80, tr: 0.15),
);

final PenSpec _hoverLead = PenName.pencil.spec.copyWith(w: 2, alpha: 0.7);

/// The scroll thumb: a thick graphite lead with two grip ticks, a second
/// pass on hover.
///
/// Mirrors `scrollThumbRecipe` in `src/lib/ink/recipes/scroll-area-ink.ts`.
final Recipe<ScrollBarParams> scrollThumbRecipe = defineRecipe<ScrollBarParams>(
  id: 'scroll-thumb',
  kind: 'thumb',
  layers: const [LayerName.rest, LayerName.hover],
  pad: 1,
  draw: _drawThumb,
);

void _drawThumb(Ink ink, Box size, ScrollBarParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final orientation = params.orientation;
  final vertical = orientation == ScrollOrientation.vertical;
  final len = switch (vertical) {
    true => h,
    false => w,
  };
  final mid =
      switch (vertical) {
        true => w,
        false => h,
      } /
      2;
  ink.layer(LayerName.rest, () {
    ink.stroke(
      _along(orientation, len, mid, 1),
      switch (ctx.calm) {
        true => PenName.pencilFine,
        false => _lead,
      },
      ruler.merge(
        StrokeOpts(
          width: switch (ctx.calm) {
            true => 1.5,
            false => 1,
          },
        ),
      ),
    );
  });
  if (!ctx.calm && len > 44) {
    ink.layer(LayerName.rest, () {
      for (final d in const [-3.2, 3.2]) {
        final c = len / 2 + d;
        final Pt a = switch (vertical) {
          true => (mid - 3.6, c),
          false => (c, mid - 3.6),
        };
        final Pt b = switch (vertical) {
          true => (mid + 3.6, c),
          false => (c, mid + 3.6),
        };
        ink.stroke(
          [a, b],
          PenName.pencilFine,
          ruler.merge(const StrokeOpts(alpha: 0.85, simple: true)),
        );
      }
    });
  }
  ink.layer(LayerName.hover, () {
    ink.stroke(_along(orientation, len, mid + 0.7, 2), _hoverLead, ruler);
  });
}
