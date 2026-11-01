import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// What a navigation menu tab does: open a panel or go to a link.
enum NavTabRole { trigger, link }

/// Navigation menu tab params.
///
/// Mirrors `NavTabParams` in `src/lib/ink/recipes/navigation-menu-ink.ts`.
final class NavTabParams {
  /// Params.
  const NavTabParams({required this.role, this.disabled = false});

  final NavTabRole role;
  final bool disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'role': role.name,
    if (disabled) 'disabled': true,
  };
}

const double _r = 5.5;

List<Pt> _vertices(double w, double h, bool rtl, [double grow = 0]) {
  final vs = <Pt>[
    (0.6, h + grow),
    (0.6, 0.6),
    (w - 0.6, 0.6),
    (w - 0.6, h + grow),
  ];
  if (!rtl) return vs;
  return [for (final p in vs) (w - p.x, p.y)];
}

void _outline(
  Ink ink,
  double w,
  double h,
  bool rtl,
  Pen pen, {
  double? grow,
  double? alpha,
  double? width,
}) {
  final pts = chain(
    _vertices(w, h, rtl, grow ?? 0),
    const [0, 0, 0],
    _r,
    ink.next('tab'),
  );
  ink.stroke(pts, pen, ruler.merge(StrokeOpts(alpha: alpha, width: width)));
}

/// A navigation menu tab: a pencil tab outline, a highlighter wash on hover,
/// an inked lifted tab when open (trigger) or current (link).
///
/// Mirrors `navTabRecipe` in `src/lib/ink/recipes/navigation-menu-ink.ts`.
final Recipe<NavTabParams> navTabRecipe = defineRecipe<NavTabParams>(
  id: 'navigation-menu-tab',
  kind: 'tab',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.open,
    LayerName.checked,
    LayerName.focus,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: _drawTab,
);

void _drawTab(Ink ink, Box size, NavTabParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final rtl = ctx.dir == Dir.rtl;
  final calm = ctx.calm;
  if (!params.disabled) {
    ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: _r));
  }
  if (ctx.lazyOnly) return;
  if (params.disabled) {
    ink.layer(
      LayerName.disabled,
      () => dashedBox(
        ink,
        0.5,
        0.5,
        w - 1,
        h - 1,
        r: _r,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(alpha: 0.5),
      ),
    );
    return;
  }
  final body = roundRectPoly(1.5, 1.5, w - 3, h + 2, _r);
  final on = switch (params.role) {
    NavTabRole.trigger => LayerName.open,
    NavTabRole.link => LayerName.checked,
  };
  ink
    ..layer(LayerName.rest, () {
      ink.group(
        GroupAttrs(hideOn: on.name),
        () => _outline(
          ink,
          w,
          h,
          rtl,
          PenName.pencilFine,
          alpha: switch (calm) {
            true => 0.62,
            false => 0.58,
          },
          width: switch (calm) {
            true => 0.9,
            false => 1.02,
          },
        ),
        Material.pencil,
      );
    })
    ..layer(LayerName.hover, () {
      wash(ink, body, PaintKey.hi, alpha: 0.4);
      if (!calm) {
        _outline(ink, w, h, rtl, PenName.inkFine, alpha: 0.55, width: 0.9);
      }
    })
    ..layer(on, () {
      _onFill(ink, body, params.role, calm);
      _outline(
        ink,
        w,
        h,
        rtl,
        switch (calm) {
          true => PenName.inkFine,
          false => PenName.ink,
        },
        grow: 1.5,
      );
    });
}

void _onFill(Ink ink, List<Pt> body, NavTabRole role, bool calm) {
  if (role == NavTabRole.trigger) {
    wash(
      ink,
      body,
      PaintKey.hi,
      alpha: switch (calm) {
        true => 0.35,
        false => 0.5,
      },
    );
    return;
  }
  ink.part('fill', () {
    if (calm) return wash(ink, body, PaintKey.hi, alpha: 0.7);
    return blobFill(ink, body, PaintKey.hi, alpha: 0.9);
  });
}

/// The baseline under a navigation menu's tabs.
///
/// Mirrors `navBaselineRecipe` in `src/lib/ink/recipes/navigation-menu-ink.ts`.
final Recipe<NoParams> navBaselineRecipe = defineRecipe<NoParams>(
  id: 'navigation-menu-baseline',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 8,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ink.layer(
      LayerName.rest,
      () => line(
        ink,
        0,
        h,
        w,
        h,
        pen: switch (ctx.calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        opts: switch (w > 360) {
          true => const StrokeOpts(simple: true),
          false => null,
        },
      ),
    );
  },
);

/// A standalone blue underline mark ([w] × [h], 96 × 8 by default) for the
/// active navigation link.
///
/// Mirrors `underlineMark` in `src/lib/ink/recipes/navigation-menu-ink.ts`.
InkResult underlineMark(
  Object seed, {
  double? w,
  double? h,
  Tier? tier,
  bool? calm,
}) {
  final width = w ?? 96;
  final height = h ?? 8;
  final quiet = calm ?? false;
  final ink = Ink(seed, tier: tier, calm: calm);
  underline(
    ink,
    3,
    height / 2 + 1,
    width - 6,
    kind: UnderlineKind.single,
    pen: switch (quiet) {
      true => PenName.blueFine,
      false => PenName.blue,
    },
    opts: StrokeOpts(
      width: switch (quiet) {
        true => 1.1,
        false => 1.35,
      },
    ),
  );
  ink.grow(BBox(0, 0, width, height));
  return ink.toSvg(w: width, h: height, pad: 3);
}
