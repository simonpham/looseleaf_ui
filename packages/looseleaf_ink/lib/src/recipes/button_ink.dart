import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// shadcn's button variants; `id` is the upstream name (`primary` is
/// upstream's `default`).
enum ButtonVariant {
  primary('default'),
  destructive('destructive'),
  outline('outline'),
  secondary('secondary'),
  ghost('ghost'),
  link('link');

  const ButtonVariant(this.id);

  /// The upstream name.
  final String id;
}

/// shadcn's button sizes; `id` is the upstream name (`regular` is
/// upstream's `default`), [labelPx] the label font size.
enum ButtonSize {
  regular('default', 16),
  xs('xs', 14),
  sm('sm', 15),
  lg('lg', 17),
  icon('icon', 16),
  iconXs('icon-xs', 14),
  iconSm('icon-sm', 16),
  iconLg('icon-lg', 18);

  const ButtonSize(this.id, this.labelPx);

  /// The upstream name.
  final String id;

  /// The label font size, used to place link underlines.
  final double labelPx;
}

/// The button's outline shape.
enum ButtonShape { standard, pill }

/// Button recipe params.
///
/// Mirrors `ButtonParams` in `src/lib/ink/recipes/button-ink.ts`.
final class ButtonParams {
  /// Params.
  const ButtonParams({
    required this.variant,
    required this.size,
    this.disabled = false,
    this.shape,
  });

  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final ButtonShape? shape;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.id,
    'size': size.id,
    if (disabled) 'disabled': true,
    if (shape case final ButtonShape s)
      'shape': switch (s) {
        ButtonShape.standard => 'default',
        ButtonShape.pill => 'pill',
      },
  };
}

const double _widePx = 360;

/// The button: marker fill, inked outline, a drop line on hover, a marker
/// press and a focus ring (both lazy), a dashed outline when disabled.
///
/// Mirrors `buttonRecipe` in `src/lib/ink/recipes/button-ink.ts`.
final Recipe<ButtonParams> buttonRecipe = defineRecipe<ButtonParams>(
  id: 'button',
  kind: 'button',
  layers: const [
    LayerName.rest,
    LayerName.hover,
    LayerName.pressed,
    LayerName.focus,
    LayerName.disabled,
  ],
  lazy: const [LayerName.focus, LayerName.pressed],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, ButtonParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final variant = params.variant;
  ink.lean();
  final pill =
      params.shape == ButtonShape.pill && variant != ButtonVariant.link;
  final r = switch (pill) {
    true => math.min(h, w) / 2 - 0.5,
    false => clamp(h * 0.09, 2.5, 4.4),
  };
  const inset = 0.5;
  final body = roundRectPoly(inset, inset, w - 2 * inset, h - 2 * inset, r);
  final small = math.min(w, h) < 30 || pill;
  final circle = pill && w / h < 1.12;
  final calm = ctx.calm;
  final outlinePen = switch ((calm, variant == ButtonVariant.destructive)) {
    (true, true) => PenName.redFine,
    (true, false) => PenName.pencilFine,
    (false, true) => PenName.redfelt,
    (false, false) => PenName.ink,
  };
  final wide = w > _widePx;
  final outlineOpts = switch (wide) {
    true => const StrokeOpts(simple: true),
    false => null,
  };
  final underlineY = h / 2 + params.size.labelPx * 0.56;

  if (params.disabled) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      if (variant == ButtonVariant.link) {
        underline(
          ink,
          w * 0.14,
          underlineY,
          w * 0.72,
          pen: PenName.pencilFine,
          kind: UnderlineKind.single,
          opts: const StrokeOpts(alpha: 0.6),
        );
        return;
      }
      if (variant != ButtonVariant.ghost) {
        wash(
          ink,
          body,
          PaintKey.paperShade,
          alpha: 0.9,
          material: Material.wash,
        );
      }
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

  ctx
    ..lazy(LayerName.focus, (fink) => focusRing(fink, 0, 0, w, h, r: r))
    ..lazy(
      LayerName.pressed,
      (pink) =>
          _pressed(pink, variant, w, h, body, underlineY, circle, outlinePen),
    );
  if (ctx.lazyOnly) return;

  ink
    ..layer(
      LayerName.rest,
      () => _rest(
        ink,
        variant,
        w,
        h,
        r,
        body,
        underlineY,
        small,
        circle,
        calm,
        outlinePen,
        outlineOpts,
      ),
    )
    ..layer(
      LayerName.hover,
      () => _hover(
        ink,
        variant,
        w,
        h,
        r,
        body,
        underlineY,
        calm,
        wide,
        outlinePen,
      ),
    );
}

void _pressed(
  Ink pink,
  ButtonVariant variant,
  double w,
  double h,
  List<Pt> body,
  double underlineY,
  bool circle,
  PenName outlinePen,
) {
  switch (variant) {
    case ButtonVariant.ghost:
      highlight(pink, 6, h * 0.22, w - 12, h * 0.56, k: 1, pen: PenName.mLemon);
    case ButtonVariant.link:
      underline(
        pink,
        w * 0.06,
        underlineY + 0.5,
        w * 0.88,
        pen: PenName.blueBrush,
        kind: UnderlineKind.single,
      );
    case ButtonVariant.outline:
      wash(pink, body, PaintKey.marker, alpha: 0.32);
    case _ when circle:
      loop(
        pink,
        w / 2,
        h / 2,
        w / 2 - 0.9,
        h / 2 - 0.9,
        pen: outlinePen,
        clean: true,
        opts: const StrokeOpts(alpha: 0.6, width: 0.85),
      );
    case _:
      final color = switch (variant) {
        ButtonVariant.secondary => PaintKey.hi,
        ButtonVariant.destructive => PaintKey.red,
        _ => PaintKey.marker,
      };
      final alpha = switch (variant) {
        ButtonVariant.destructive => 0.18,
        _ => 0.34,
      };
      solidFill(pink, body, color, alpha: alpha);
  }
}

void _rest(
  Ink ink,
  ButtonVariant variant,
  double w,
  double h,
  double r,
  List<Pt> body,
  double underlineY,
  bool small,
  bool circle,
  bool calm,
  PenName outlinePen,
  StrokeOpts? outlineOpts,
) {
  if (variant == ButtonVariant.outline) {
    ink.poly(Material.under, body, PaintKey.slip, 0.9);
  }
  switch (variant) {
    case ButtonVariant.primary:
      ink.part('fill', () {
        if (small) return blobFill(ink, body, PaintKey.marker, alpha: 0.9);
        final passes = switch (calm) {
          true => 1,
          false => 2,
        };
        return bandFill(
          ink,
          body,
          PaintKey.marker,
          passes: passes,
          alpha: 0.84,
        );
      });
    case ButtonVariant.secondary:
      ink.part('fill', () {
        if (small) return blobFill(ink, body, PaintKey.hi, alpha: 0.85);
        return bandFill(ink, body, PaintKey.hi, alpha: 0.8);
      });
    case ButtonVariant.destructive:
      ink.part('fill', () {
        if (small) return blobFill(ink, body, PaintKey.red, alpha: 0.97);
        return bandFill(ink, body, PaintKey.red, passes: 1, alpha: 0.97);
      });
    case ButtonVariant.outline || ButtonVariant.ghost || ButtonVariant.link:
      break;
  }
  if (variant == ButtonVariant.link) {
    underline(
      ink,
      w * 0.1,
      underlineY,
      w * 0.8,
      pen: PenName.blueFine,
      kind: UnderlineKind.single,
    );
    return;
  }
  if (variant == ButtonVariant.ghost && circle) {
    loop(
      ink,
      w / 2,
      h / 2,
      w / 2 - 1.2,
      h / 2 - 1.2,
      pen: PenName.pencilFine,
      clean: true,
      opts: const StrokeOpts(alpha: 0.42),
    );
    return;
  }
  if (variant == ButtonVariant.ghost) {
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: PenName.pencilFine,
      corner: r,
      opts: const StrokeOpts(alpha: 0.42),
    );
    return;
  }
  if (circle) {
    loop(
      ink,
      w / 2,
      h / 2,
      w / 2 - 1.2,
      h / 2 - 1.2,
      pen: outlinePen,
      clean: true,
      opts: outlineOpts,
    );
    return;
  }
  box(ink, 0, 0, w, h, pen: outlinePen, corner: r, opts: outlineOpts);
}

void _hover(
  Ink ink,
  ButtonVariant variant,
  double w,
  double h,
  double r,
  List<Pt> body,
  double underlineY,
  bool calm,
  bool wide,
  PenName outlinePen,
) {
  final d = 3.6 + h / 40;
  if (variant == ButtonVariant.ghost) {
    ink.part(
      'swipe',
      () => highlight(ink, 6, h * 0.22, w - 12, h * 0.56, k: 1),
      Material.hl,
    );
    return;
  }
  if (variant == ButtonVariant.link) {
    ink.part(
      'swipe',
      () => underline(
        ink,
        w * 0.06,
        underlineY + 0.5,
        w * 0.88,
        pen: PenName.blueBrush,
        kind: UnderlineKind.single,
      ),
      Material.top,
    );
    return;
  }
  if (variant == ButtonVariant.outline) {
    wash(ink, body, PaintKey.hi, alpha: 0.5);
  }
  if (calm) {
    box(
      ink,
      1.2,
      1.2,
      w - 2.4,
      h - 2.4,
      pen: outlinePen,
      corner: r,
      loose: 0.6,
      opts: const StrokeOpts(alpha: 0.7, simple: true),
    );
    return;
  }
  final drop = chain(
    [(r + d + 2, h + d), (w + d, h + d), (w + d, r + d + 2)],
    [0.25, -0.2],
    math.max(2.5, r + 1),
    ink.next('drop'),
  );
  ink.lines(
    [
      Line(
        drop,
        o: const StrokeOpts(
          start: StrokeStart.soft,
          end: StrokeEnd.soft,
          wobble: 0.25,
          dry: 0,
        ),
      ),
    ],
    PenName.inkFine,
    StrokeOpts(width: 1.35, simple: wide),
  );
}
