import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Sidebar menu item mark params.
///
/// Mirrors `SidebarMarkParams` in `src/lib/ink/recipes/sidebar-ink.ts`.
final class SidebarMarkParams {
  /// Params.
  const SidebarMarkParams({required this.active, required this.outline});

  /// Highlights the item and draws a blue bracket at its start.
  final bool active;

  /// Boxes the item.
  final bool outline;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'active': active, 'outline': outline};
}

/// A sidebar item's mark: a highlighter swipe and a blue pencil bracket when
/// active, an inked box when outlined.
///
/// Mirrors `sidebarMarkRecipe` in `src/lib/ink/recipes/sidebar-ink.ts`.
final Recipe<SidebarMarkParams> sidebarMarkRecipe =
    defineRecipe<SidebarMarkParams>(
      id: 'sidebar-mark',
      kind: 'mark',
      layers: const [LayerName.rest],
      pad: 10,
      draw: _drawMark,
    );

void _drawMark(
  Ink ink,
  Box size,
  SidebarMarkParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final rtl = ctx.dir == Dir.rtl;
  final calm = ctx.calm;
  ink.layer(LayerName.rest, () {
    if (params.active) {
      highlight(
        ink,
        3,
        3,
        math.max(8.0, w - 8),
        math.max(8.0, h - 6),
        pen: PenName.hi,
        k: 0.92,
        opts: StrokeOpts(
          alpha: switch (calm) {
            true => 0.7,
            false => 0.9,
          },
        ),
      );
      ink.part('bracket', () => _bracket(ink, w, h, rtl, calm));
    }
    if (!params.outline) return;
    if (calm) {
      box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: 3);
      return;
    }
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: PenName.inkFine,
      corner: 3,
      opts: switch (w > 360) {
        true => const StrokeOpts(simple: true),
        false => null,
      },
    );
  });
}

void _bracket(Ink ink, double w, double h, bool rtl, bool calm) {
  final dir = switch (rtl) {
    true => -1,
    false => 1,
  };
  final x = switch (rtl) {
    true => w + 5.5,
    false => -5.5,
  };
  const top = 2.0;
  final span = math.max(10.0, h - 4);
  final tip = math.min(7.0, math.max(4.5, span * 0.2));
  final pts = <Pt>[
    (x + dir * tip, top),
    (x + dir * 1.4, top + 0.5),
    (x, top + 3),
    (x, top + span - 3),
    (x + dir * 1.4, top + span - 0.5),
    (x + dir * tip, top + span),
  ];
  ink.stroke(
    pts,
    switch (calm) {
      true => PenName.bluepencilFine,
      false => PenName.bluepencil,
    },
    StrokeOpts(
      raw: true,
      start: StrokeStart.soft,
      end: StrokeEnd.soft,
      dry: 0,
      width: switch (calm) {
        true => 1.1,
        false => 1.7,
      },
    ),
  );
}

/// The sidebar's edge: one wandering pencil rule.
///
/// Mirrors `sidebarRuleRecipe` in `src/lib/ink/recipes/sidebar-ink.ts`.
final Recipe<NoParams> sidebarRuleRecipe = defineRecipe<NoParams>(
  id: 'sidebar-rule',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 6,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final x = switch (ctx.dir) {
      Dir.rtl => w - 0.5,
      Dir.ltr => 0.5,
    };
    ink.layer(LayerName.rest, () {
      final r = ink.next('rule');
      ink.stroke(
        [
          (x + r.gauss(0, 0.3), -1),
          (x + r.gauss(0, 0.5), h / 2),
          (x + r.gauss(0, 0.3), h + 1),
        ],
        switch (ctx.calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.flick,
          wobble: 0.5,
        ),
      );
    });
  },
);
