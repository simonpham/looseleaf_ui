import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Notebook cover recipe params.
///
/// Mirrors `NotebookCoverParams` in `src/lib/ink/recipes/notebook-ink.ts`.
final class NotebookCoverParams {
  /// Params.
  const NotebookCoverParams({this.tone, required this.band});

  /// The cloth colour; ink when null.
  final Accent? tone;

  /// An elastic band near the open edge.
  final bool band;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': tone?.name ?? 'ink', 'band': band};
}

/// The width of a notebook cover's spine.
///
/// Mirrors `SPINE` in `src/lib/ink/recipes/notebook-ink.ts`.
const double notebookSpine = 15;

/// A cloth notebook cover: a woven texture, sheen, the spine with its
/// stitching, an optional elastic band and a lifted shadow.
///
/// Mirrors `notebookCoverRecipe` in `src/lib/ink/recipes/notebook-ink.ts`.
final Recipe<NotebookCoverParams> notebookCoverRecipe =
    defineRecipe<NotebookCoverParams>(
      id: 'notebook-cover',
      kind: 'sheet',
      layers: const [LayerName.rest],
      pad: 6,
      draw: _drawCover,
    );

void _drawCover(
  Ink ink,
  Box size,
  NotebookCoverParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final r = ink.next('cover');
  double j() => r.gauss(0, 0.25);
  final id = 'll-nc${ink.seed.toRadixString(36)}';
  const rad = 9.0;
  const s0 = 3.0;
  final d =
      'M${num10(s0)} ${num10(j())}H${num10(w - rad)}Q${num10(w)} 0 '
      '${num10(w + j())} ${num10(rad)}V${num10(h - rad)}Q${num10(w)} ${num10(h)} '
      '${num10(w - rad)} ${num10(h + j())}H${num10(s0)}Q0 ${num10(h)} '
      '${num10(j())} ${num10(h - s0)}V${num10(s0)}Q0 0 ${num10(s0)} 0z';
  ink.layer(LayerName.rest, () {
    final cloth = tok(params.tone?.name ?? 'ink');
    final s = StringBuffer('<clipPath id="${id}c"><path d="$d"/></clipPath>')
      ..write(pathTag(d, fill: cloth))
      ..write('<g clip-path="url(#${id}c)">');
    final g = StringBuffer();
    for (var x = 2.0; x < w; x += 3.2) {
      g.write('M${num10(x)} 0V${num10(h)}');
    }
    for (var y = 2.0; y < h; y += 3.2) {
      g.write('M0 ${num10(y)}H${num10(w)}');
    }
    s
      ..write(pathTag('$g', stroke: tok('ink'), sw: 0.5, op: 0.07))
      ..write(
        '<linearGradient id="${id}l" x1="0" y1="0" x2="1" y2="1">'
        '<stop offset="0" stop-color="${tok('photo')}" stop-opacity=".3"/>'
        '<stop offset=".45" stop-color="${tok('photo')}" stop-opacity="0"/>'
        '<stop offset="1" stop-color="${tok('ink')}" stop-opacity=".16"/>'
        '</linearGradient>',
      )
      ..write(pathTag('M0 0H${num10(w)}V${num10(h)}H0z', fill: 'url(#${id}l)'))
      ..write(
        pathTag(
          'M0 0H${num10(notebookSpine)}V${num10(h)}H0z',
          fill: tok('ink'),
          op: 0.24,
        ),
      )
      ..write(
        pathTag(
          'M${num10(notebookSpine)} 0V${num10(h)}',
          stroke: tok('ink'),
          sw: 1.2,
          op: 0.3,
        ),
      )
      ..write(
        pathTag(
          'M${num10(notebookSpine + 1.4)} 0V${num10(h)}',
          stroke: tok('photo'),
          sw: 1,
          op: 0.45,
        ),
      )
      ..write(
        pathTag(
          'M${num10(notebookSpine / 2)} 6V${num10(h - 6)}',
          stroke: tok('photo'),
          sw: 1.1,
          op: 0.5,
          extra: 'stroke-dasharray="5 3.4"',
        ),
      );
    if (params.band) {
      final bx = w - math.max(22, w * 0.15);
      s
        ..write(
          pathTag(
            'M${num10(bx)} 0V${num10(h)}',
            stroke: tok('ink'),
            sw: 6.4,
            op: 0.2,
            transform: 'translate(1 .6)',
          ),
        )
        ..write(
          pathTag(
            'M${num10(bx)} 0V${num10(h)}',
            stroke: tok('ink'),
            sw: 5.4,
            op: 0.82,
          ),
        )
        ..write(
          pathTag(
            'M${num10(bx - 1.6)} 0V${num10(h)}',
            stroke: tok('photo'),
            sw: 0.9,
            op: 0.28,
          ),
        );
    }
    s
      ..write('</g>')
      ..write(pathTag(d, stroke: tok('ink'), sw: 0.9, op: 0.4))
      ..write(
        litEdge('M${num10(notebookSpine + 2)} 0.7H${num10(w - rad)}', 0.4),
      );
    final rtl = ctx.dir == Dir.rtl;
    final shadow = shadowMark(SheetShadowKind.lift, switch (rtl) {
      true => const [9, 3, 3, 9],
      false => const [3, 9, 9, 3],
    });
    final body = switch (rtl) {
      true => '<g transform="${mirrorTransform(w)}">$s</g>',
      false => '$s',
    };
    ink
      ..raw('$shadow$body', Material.under)
      ..grow(BBox(-1, -1, w + 1, h + 1));
    if (!ctx.calm) {
      box(
        ink,
        0.5,
        0.5,
        w - 1,
        h - 1,
        pen: PenName.inkFine,
        corner: 9,
        opts: const StrokeOpts(alpha: 0.5, simple: true),
      );
    }
  });
}
