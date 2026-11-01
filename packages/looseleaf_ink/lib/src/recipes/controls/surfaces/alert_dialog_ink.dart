import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// Alert dialog media tones and their fill paint. `id` is the upstream name
/// (`neutral` is upstream's `default`).
///
/// Mirrors `AlertMediaTone` and `FILL` in
/// `src/lib/ink/recipes/alert-dialog-ink.ts`.
enum AlertMediaTone {
  neutral('default', PaintKey.hi),
  danger('danger', PaintKey.tomato),
  info('info', PaintKey.sky);

  const AlertMediaTone(this.id, this.fill);

  /// The upstream name.
  final String id;

  /// The plate's fill.
  final PaintKey fill;
}

/// Alert dialog media params.
///
/// Mirrors `AlertMediaParams` in `src/lib/ink/recipes/alert-dialog-ink.ts`.
final class AlertMediaParams {
  /// Params.
  const AlertMediaParams({required this.tone});

  final AlertMediaTone tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': tone.id};
}

/// The round plate behind an alert dialog's icon: a toned blob in a loop.
///
/// Mirrors `alertMediaRecipe` in `src/lib/ink/recipes/alert-dialog-ink.ts`.
final Recipe<AlertMediaParams> alertMediaRecipe =
    defineRecipe<AlertMediaParams>(
      id: 'alert-media',
      kind: 'plate',
      layers: const [LayerName.rest],
      pad: 8,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final tone = params.tone;
        final cx = w / 2;
        final cy = h / 2;
        ink.layer(LayerName.rest, () {
          ink.part(
            'fill',
            () => blobFill(
              ink,
              ellipsePoly(
                cx,
                cy,
                w * 0.43,
                h * 0.42,
                30,
                ink.next('plate').range(-0.3, 0.3),
              ),
              tone.fill,
              alpha: switch (tone) {
                AlertMediaTone.danger => 0.34,
                _ => 0.62,
              },
            ),
          );
          loop(
            ink,
            cx,
            cy,
            w * 0.45,
            h * 0.44,
            pen: switch ((ctx.calm, tone)) {
              (true, _) => PenName.pencilFine,
              (false, AlertMediaTone.danger) => PenName.redfeltFine,
              (false, _) => PenName.inkFine,
            },
          );
        });
      },
    );
