import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Alert tones: the outline pen, the calm hairline pen and the icon mark
/// paint. `id` is the upstream name (`neutral` is upstream's `default`).
///
/// Mirrors `AlertTone`, `PEN`, `HAIR` and `MARK` in
/// `src/lib/ink/recipes/alert-ink.ts`.
enum AlertTone {
  neutral('default', PenName.ink, PenName.pencilFine, PaintKey.pencilMark),
  destructive('destructive', PenName.redfelt, PenName.redFine, PaintKey.red),
  info('info', PenName.blue, PenName.bluepencilFine, PaintKey.sky),
  success('success', PenName.greenfelt, PenName.greenFine, PaintKey.grass),
  warning('warning', PenName.ink, PenName.pencilFine, PaintKey.tangerine),
  note('note', PenName.ink, PenName.pencilFine, PaintKey.pencilMark);

  const AlertTone(this.id, this.pen, this.hair, this.mark);

  /// The upstream name.
  final String id;

  /// The outline pen.
  final PenName pen;

  /// The calm outline and hairline pen.
  final PenName hair;

  /// The icon mark paint.
  final PaintKey mark;
}

/// Alert params.
///
/// Mirrors `AlertParams` in `src/lib/ink/recipes/alert-ink.ts`.
final class AlertParams {
  /// Params.
  const AlertParams({required this.tone});

  final AlertTone tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': tone.id};
}

/// The alert box: a slip, a tone accent (a band, a wash, margin lines), an
/// icon mark behind the icon and an inked outline. Nothing for `note`.
///
/// Mirrors `alertRecipe` in `src/lib/ink/recipes/alert-ink.ts`.
final Recipe<AlertParams> alertRecipe = defineRecipe<AlertParams>(
  id: 'alert',
  kind: 'alert',
  layers: const [LayerName.rest],
  pad: 12,
  draw: _draw,
);

void _draw(Ink ink, Box size, AlertParams params, RecipeContext ctx) {
  final tone = params.tone;
  if (tone == AlertTone.note) return;
  final Box(:w, :h) = size;
  const r = 3.0;
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  final calm = ctx.calm;
  final rtl = ctx.dir == Dir.rtl;
  double x(double v) => switch (rtl) {
    true => w - v,
    false => v,
  };
  final wide = w > 360;
  final bandX = switch (rtl) {
    true => w - 11,
    false => 3.0,
  };
  ink.layer(LayerName.rest, () {
    ink.poly(Material.under, body, PaintKey.slip, 0.94);
    if (tone == AlertTone.warning) {
      ink.part(
        'fill',
        () => bandFill(
          ink,
          body,
          PaintKey.hi,
          alpha: switch (calm) {
            true => 0.4,
            false => 0.6,
          },
          passes: 1,
          ends: BandEnds.flag,
        ),
      );
    }
    _accent(ink, tone, w, h, body, calm, x, bandX);
    if (!calm) {
      const px = 16.0;
      final py = switch (ctx.density) {
        Density.compact => 10,
        _ => 12,
      };
      final cx = x(px + 8), cy = py + 10.0;
      ink.part('icon-mark', () {
        final off = blobFill(
          ink,
          ellipsePoly(cx, cy, 11.5, 11.5, 20),
          tone.mark,
          alpha: switch (tone) {
            AlertTone.neutral => 0.3,
            _ => 0.32,
          },
          mis: 1.6,
        );
        loop(
          ink,
          cx,
          cy,
          12.5,
          12.5,
          pen: switch (tone) {
            AlertTone.neutral => PenName.pencilFine,
            _ => tone.hair,
          },
          turns: 1.08,
        );
        return off;
      });
    }
    if (calm) {
      box(ink, 0, 0, w, h, pen: tone.hair, corner: r);
      return;
    }
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: tone.pen,
      corner: r,
      opts: switch (wide) {
        true => const StrokeOpts(simple: true),
        false => null,
      },
    );
  });
}

void _accent(
  Ink ink,
  AlertTone tone,
  double w,
  double h,
  List<Pt> body,
  bool calm,
  double Function(double v) x,
  double bandX,
) {
  if (calm) {
    if (tone != AlertTone.neutral && tone != AlertTone.warning) {
      line(
        ink,
        x(6.5),
        4,
        x(6.5),
        h - 4,
        pen: tone.hair,
        opts: const StrokeOpts(alpha: 0.9),
      );
    }
    return;
  }
  switch (tone) {
    case AlertTone.destructive:
      wash(ink, body, PaintKey.red, alpha: 0.04);
      ink.part(
        'fill',
        () => bandFill(
          ink,
          roundRectPoly(bandX, 3.5, 8, h - 7, 2),
          PaintKey.red,
          alpha: 0.9,
          passes: 1,
          ends: BandEnds.square,
          w: 5,
        ),
      );
    case AlertTone.info:
      line(ink, x(5.2), 5, x(5.6), h - 5, pen: PenName.bluepencil);
      line(
        ink,
        x(10),
        5.5,
        x(10.4),
        h - 6,
        pen: PenName.bluepencil,
        opts: const StrokeOpts(alpha: 0.75),
      );
    case AlertTone.success:
      ink.part(
        'fill',
        () => bandFill(
          ink,
          roundRectPoly(bandX, 3.5, 8, h - 7, 2),
          PaintKey.grass,
          alpha: 0.7,
          passes: 1,
          ends: BandEnds.square,
          w: 5,
        ),
      );
    case AlertTone.neutral || AlertTone.warning || AlertTone.note:
      break;
  }
}
