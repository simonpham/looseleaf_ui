import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Stamp pad inks; `id` is the upstream name, [paint] the die colour and
/// [rule] the felt pen that outlines the die.
enum StampButtonInk {
  red('red', PaintKey.red, PenName.redfelt, PenName.redfeltFine),
  inkYou('ink-you', PaintKey.inkYou, PenName.blue, PenName.blueFine),
  green('green', PaintKey.green, PenName.greenfelt, PenName.greenfeltFine),
  ink('ink', PaintKey.ink, PenName.ink, PenName.inkFine);

  const StampButtonInk(this.id, this.paint, this.rule, this.ruleFine);

  /// The upstream name.
  final String id;
  final PaintKey paint;
  final PenName rule;

  /// The fine version of [rule].
  final PenName ruleFine;
}

/// The height of the stamp's knob and neck above the die.
///
/// Mirrors `STAMP_KNOB` in `src/lib/ink/recipes/stamp-button-ink.ts`.
const double stampKnob = 30;

/// Stamp button recipe params.
///
/// Mirrors `StampButtonParams` in `src/lib/ink/recipes/stamp-button-ink.ts`.
final class StampButtonParams {
  /// Params.
  const StampButtonParams({required this.ink, this.disabled});

  final StampButtonInk ink;
  final bool? disabled;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'ink': ink.id,
    if (disabled case final bool d) 'disabled': d,
  };
}

/// A rubber stamp tool: kraft knob and flange over an inked die; the die
/// washes on hover and press, a pencil outline when disabled.
///
/// Mirrors `stampButtonRecipe` in `src/lib/ink/recipes/stamp-button-ink.ts`.
final Recipe<StampButtonParams> stampButtonRecipe =
    defineRecipe<StampButtonParams>(
      id: 'stamp-button',
      kind: 'stamp-tool',
      layers: const [
        LayerName.rest,
        LayerName.hover,
        LayerName.pressed,
        LayerName.focus,
        LayerName.disabled,
      ],
      lazy: const [LayerName.pressed, LayerName.focus],
      pad: 12,
      draw: _draw,
    );

void _draw(Ink ink, Box size, StampButtonParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final tone = params.ink;
  const knobH = stampKnob;
  final cx = w / 2;
  const dieY = knobH - 3;
  final dieH = h - dieY;
  final colour = tone.paint;
  List<Pt> die() => [
    (2, dieY + 2),
    (w - 2, dieY + 2),
    (w - 2, h - 2),
    (2, h - 2),
  ];
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: 4));
  if (params.disabled == true) {
    if (ctx.lazyOnly) return;
    ink.layer(LayerName.disabled, () {
      dashedBox(
        ink,
        1,
        dieY,
        w - 2,
        dieH - 1,
        r: 3,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencil, width: 1.2),
      );
      final knob = ellipsePoly(cx, 9.5, 14, 8.2, 28);
      ink.stroke(
        [...knob, knob[0]],
        PenName.pencilFine,
        const StrokeOpts(poly: true, round: 1, simple: true, alpha: 0.7),
      );
      line(
        ink,
        cx - 4.6,
        16,
        cx - 4,
        dieY - 1,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(simple: true),
      );
      line(
        ink,
        cx + 4.6,
        16,
        cx + 4,
        dieY - 1,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(simple: true),
      );
    });
    return;
  }
  ctx.lazy(
    LayerName.pressed,
    (p) => wash(p, die(), colour, alpha: 0.22, inset: 0),
  );
  if (ctx.lazyOnly) return;

  ink
    ..layer(LayerName.rest, () {
      final knob = ellipsePoly(cx, 9.5, 14, 8.2, 28);
      final neck = <Pt>[
        (cx - 4.6, 15),
        (cx + 4.6, 15),
        (cx + 3.6, 21.5),
        (cx + 5.4, 23),
        (cx - 5.4, 23),
        (cx - 3.6, 21.5),
      ];
      final flange = roundRectPoly(cx - 15.5, 22.5, 31, dieY - 22.5 + 1.5, 2);
      ink.part('fill', () {
        blobFill(ink, neck, PaintKey.kraft, alpha: 0.95);
        blobFill(ink, flange, PaintKey.kraft, alpha: 0.95);
        return blobFill(ink, knob, PaintKey.kraft, alpha: 0.95);
      });
      wash(ink, knob, PaintKey.orangeText, alpha: 0.28, inset: 1);
      wash(ink, flange, PaintKey.orangeText, alpha: 0.2, inset: 0.5);
      final outline = switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      };
      const rim = StrokeOpts(poly: true, round: 1, simple: true);
      ink
        ..stroke([...knob, knob[0]], outline, rim)
        ..stroke([...flange, flange[0]], outline, rim);
      line(
        ink,
        cx - 4.6,
        16,
        cx - 3.6,
        22,
        pen: outline,
        opts: const StrokeOpts(simple: true),
      );
      line(
        ink,
        cx + 4.6,
        16,
        cx + 3.6,
        22,
        pen: outline,
        opts: const StrokeOpts(simple: true),
      );
      line(
        ink,
        cx - 7.5,
        8.6,
        cx + 5,
        7,
        pen: PenName.pencilFine,
        opts: const StrokeOpts(simple: true, alpha: 0.6),
      );
      ink.part(
        'fill',
        () => bandFill(
          ink,
          die(),
          colour,
          alpha: 0.2,
          passes: 1,
          ends: BandEnds.square,
        ),
      );
      box(
        ink,
        0,
        dieY,
        w,
        dieH,
        pen: tone.rule,
        corner: 3,
        opts: switch (ctx.calm) {
          true => const StrokeOpts(simple: true),
          false => null,
        },
      );
      box(
        ink,
        4.5,
        dieY + 4.5,
        w - 9,
        dieH - 9,
        pen: tone.ruleFine,
        corner: 2,
        opts: const StrokeOpts(simple: true),
      );
    })
    ..layer(LayerName.hover, () {
      if (!ctx.calm) wash(ink, die(), colour, alpha: 0.12, inset: 0);
      ink.lines(
        [
          Line([(6, h + 3.4), (w - 4, h + 3.4)], o: ruler),
        ],
        PenName.inkFine,
        const StrokeOpts(width: 1.2),
      );
    });
}
