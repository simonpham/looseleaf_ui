import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// How a separator is drawn.
///
/// Mirrors `SeparatorVariant` in `src/lib/ink/recipes/separator-ink.ts`.
enum SeparatorVariant { pencil, dashed, wavy, dotted, tape, stitched, torn }

/// Every separator variant, in upstream order (`separatorVariantList`).
const List<SeparatorVariant> separatorVariants = SeparatorVariant.values;

/// Which way a separator runs.
///
/// Mirrors `SeparatorParams['orientation']` in
/// `src/lib/ink/recipes/separator-ink.ts`.
enum SeparatorOrientation { horizontal, vertical }

/// Separator recipe params.
///
/// Mirrors `SeparatorParams` in `src/lib/ink/recipes/separator-ink.ts`.
final class SeparatorParams {
  /// Params.
  const SeparatorParams({required this.variant, required this.orientation});

  /// The look.
  final SeparatorVariant variant;

  /// The direction.
  final SeparatorOrientation orientation;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'variant': variant.name,
    'orientation': orientation.name,
  };
}

/// A separator rule: a pencil line, dashes, a wavy ink line, dots, a strip
/// of kraft tape, stitches or a torn paper strip (the last three fall back
/// to pencil when calm).
///
/// Mirrors `separatorRecipe` in `src/lib/ink/recipes/separator-ink.ts`.
final Recipe<SeparatorParams> separatorRecipe = defineRecipe<SeparatorParams>(
  id: 'separator',
  kind: 'rule',
  layers: const [LayerName.rest],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    final vertical = params.orientation == SeparatorOrientation.vertical;
    final len = switch (vertical) {
      true => h,
      false => w,
    };
    final c =
        switch (vertical) {
          true => w,
          false => h,
        } /
        2;
    Pt at(double t, [double u = 0]) => switch (vertical) {
      true => (c + u, t),
      false => (t, c + u),
    };
    final kind = switch (params.variant) {
      SeparatorVariant.tape ||
      SeparatorVariant.stitched ||
      SeparatorVariant.torn when ctx.calm => SeparatorVariant.pencil,
      final v => v,
    };
    ink.layer(LayerName.rest, () {
      switch (kind) {
        case SeparatorVariant.pencil:
          final (x1, y1) = at(0);
          final (x2, y2) = at(len);
          line(
            ink,
            x1,
            y1,
            x2,
            y2,
            pen: switch (ctx.calm) {
              true => PenName.pencilFine,
              false => PenName.pencil,
            },
          );
        case SeparatorVariant.dashed:
          ink.lines(
            separatorDashes(len, at),
            PenName.pencil,
            const StrokeOpts(width: 1.35),
          );
        case SeparatorVariant.wavy:
          ink.lines(
            separatorWave(ink.next('wave'), len, at),
            PenName.inkFine,
            const StrokeOpts(width: 1.1),
          );
        case SeparatorVariant.dotted:
          separatorDots(ink, len, at);
        case SeparatorVariant.tape:
          tapeStrip(ink, len, c, vertical, ctx.tier, ctx.calm);
        case SeparatorVariant.stitched:
          stitchLine(ink, len, at);
        case SeparatorVariant.torn:
          tornStrip(ink, len, c, vertical);
      }
    });
  },
);
