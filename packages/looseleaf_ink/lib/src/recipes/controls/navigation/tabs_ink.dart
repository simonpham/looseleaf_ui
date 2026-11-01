import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Tab styles; `id` is the upstream name (`folder` is upstream's
/// `default`).
enum TabsVariant {
  folder('default'),
  line('line');

  const TabsVariant(this.id);

  /// The upstream name.
  final String id;
}

/// The direction a tab list runs.
enum TabsOrientation { horizontal, vertical }

/// Tabs trigger params.
///
/// Mirrors `TabsParams` in `src/lib/ink/recipes/tabs-ink.ts`.
final class TabsParams {
  /// Params.
  const TabsParams({
    required this.variant,
    required this.orientation,
    this.disabled = false,
  });

  final TabsVariant variant;
  final TabsOrientation orientation;
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.id,
    'orientation': orientation.name,
    if (disabled) 'disabled': true,
  };
}

const double _r = 5.5;
const double _hair = 1.2;
const double _edge = 1.6;
const double _reach = 2;
const double _lift = 2;

List<Pt> _tabEdge(double w, double h, bool vertical, bool rtl, double grow) {
  final r = math.max(
    1.0,
    math.min(
      _r,
      switch (vertical) {
                true => h,
                false => w,
              } /
              2 -
          1,
    ),
  );
  final out = <Pt>[];
  void arc(double cx, double cy, double a0, double a1) {
    for (var i = 0; i <= 8; i++) {
      final a = a0 + ((a1 - a0) * i) / 8;
      out.add((cx + r * JsMath.cos(a), cy + r * JsMath.sin(a)));
    }
  }

  const x0 = 0.6, y0 = 0.6;
  if (vertical) {
    final y1 = h - 0.6;
    out.add((w + grow, y0));
    arc(x0 + r, y0 + r, 1.5 * JsMath.pi, JsMath.pi);
    arc(x0 + r, y1 - r, JsMath.pi, 0.5 * JsMath.pi);
    out.add((w + grow, y1));
  }
  if (!vertical) {
    final x1 = w - 0.6;
    out.add((x0, h + grow));
    arc(x0 + r, y0 + r, JsMath.pi, 1.5 * JsMath.pi);
    arc(x1 - r, y0 + r, 1.5 * JsMath.pi, 2 * JsMath.pi);
    out.add((x1, h + grow));
  }
  if (!rtl) return out;
  return [for (final p in out) (w - p.x, p.y)];
}

List<Pt> _ribbon(List<Pt> pts, double width) {
  final hw = width / 2;
  final left = <Pt>[], right = <Pt>[];
  for (var i = 0; i < pts.length; i++) {
    final a = pts[math.max(0, i - 1)], b = pts[math.min(pts.length - 1, i + 1)];
    final tx = b.x - a.x, ty = b.y - a.y;
    final l = JsMath.or(JsMath.hypot(tx, ty), 1);
    final nx = -ty / l, ny = tx / l;
    left.add((pts[i].x + nx * hw, pts[i].y + ny * hw));
    right.add((pts[i].x - nx * hw, pts[i].y - ny * hw));
  }
  return [...left, ...right.reversed];
}

void _rule(
  Ink ink,
  List<Pt> pts,
  PaintKey color,
  double width, [
  double alpha = 1,
]) {
  flatFill(ink, _ribbon(pts, width), color, alpha, Material.text);
}

/// A tab trigger: a folder tab whose lifted, highlighted copy shows when
/// checked, or (the `line` variant) a baseline with a blue swipe.
///
/// Mirrors `tabsRecipe` in `src/lib/ink/recipes/tabs-ink.ts`.
final Recipe<TabsParams> tabsRecipe = defineRecipe<TabsParams>(
  id: 'tabs',
  kind: 'tab',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.checked,
    LayerName.focus,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, TabsParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final variant = params.variant;
  final vertical = params.orientation == TabsOrientation.vertical;
  final rtl = ctx.dir == Dir.rtl;
  void base(PaintKey color, [double width = _hair, double alpha = 1]) {
    if (vertical) {
      final x = switch (rtl) {
        true => 0.0,
        false => w,
      };
      _rule(ink, [(x, -_reach), (x, h + _reach)], color, width, alpha);
      return;
    }
    _rule(ink, [(-_reach, h), (w + _reach, h)], color, width, alpha);
  }

  if (!params.disabled) {
    ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: _r));
  }
  if (ctx.lazyOnly) return;

  if (params.disabled) {
    ink.layer(LayerName.disabled, () {
      base(PaintKey.pencilMark, _hair, 0.6);
      if (variant == TabsVariant.folder) {
        _rule(
          ink,
          _tabEdge(w, h, vertical, rtl, 0),
          PaintKey.pencilMark,
          _hair,
          0.45,
        );
      }
    });
    return;
  }

  if (variant == TabsVariant.line) {
    ink
      ..layer(LayerName.rest, () => base(PaintKey.pencilMark))
      ..layer(LayerName.hover, () => base(PaintKey.pencil))
      ..layer(LayerName.checked, () {
        ink.part('swipe', () {
          if (vertical) {
            final x = switch (rtl) {
              true => 1.4,
              false => w - 1.4,
            };
            _rule(ink, [(x, 3), (x, h - 3)], PaintKey.inkYou, 2.4);
            return;
          }
          _rule(ink, [(3, h - 1.4), (w - 3, h - 1.4)], PaintKey.inkYou, 2.4);
        }, Material.top);
      });
    return;
  }

  final outline = _tabEdge(w, h, vertical, rtl, 0);
  ink
    ..layer(LayerName.rest, () {
      ink.group(GroupAttrs(hideOn: 'checked'), () {
        base(PaintKey.pencilMark);
        _rule(ink, outline, PaintKey.pencilMark, _hair);
      }, Material.text);
    })
    ..layer(LayerName.hover, () {
      wash(ink, outline, PaintKey.hi, alpha: 0.35);
      _rule(ink, outline, PaintKey.pencil, _hair);
    })
    ..layer(LayerName.checked, () {
      final lifted = _tabEdge(
        w,
        h,
        vertical,
        rtl,
        switch (vertical) {
          true => -_lift,
          false => _lift,
        },
      );
      ink.part('fill', () => flatFill(ink, lifted, PaintKey.hi, 0.92));
      _rule(ink, lifted, PaintKey.ink, _edge);
    });
}
