import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// Clipboard board recipe params.
///
/// Mirrors `ClipboardBoardParams` in `src/lib/ink/recipes/clipboard-ink.ts`.
final class ClipboardBoardParams {
  /// Params.
  const ClipboardBoardParams({this.tone});

  /// A coloured plastic board; grained hardboard when null.
  final Accent? tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': tone?.name ?? 'hardboard'};
}

/// A clipboard: hardboard with a wood grain, or glossy coloured plastic,
/// with bevelled edges and a lifted shadow.
///
/// Mirrors `clipboardBoardRecipe` in `src/lib/ink/recipes/clipboard-ink.ts`.
final Recipe<ClipboardBoardParams> clipboardBoardRecipe =
    defineRecipe<ClipboardBoardParams>(
      id: 'clipboard-board',
      kind: 'sheet',
      layers: const [LayerName.rest],
      pad: 4,
      draw: _drawBoard,
    );

void _drawBoard(
  Ink ink,
  Box size,
  ClipboardBoardParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final r = ink.next('board');
  double j() => r.gauss(0, 0.25);
  const rad = 11.0;
  final d =
      'M${num10(rad)} ${num10(j())}H${num10(w - rad)}Q${num10(w)} 0 '
      '${num10(w + j())} ${num10(rad)}V${num10(h - rad)}Q${num10(w)} ${num10(h)} '
      '${num10(w - rad)} ${num10(h + j())}H${num10(rad)}Q0 ${num10(h)} '
      '${num10(j())} ${num10(h - rad)}V${num10(rad)}Q0 0 ${num10(rad)} 0z';
  final id = 'll-cb${ink.seed.toRadixString(36)}';
  ink.layer(LayerName.rest, () {
    final tone = params.tone;
    final rect = 'M0 0H${num10(w)}V${num10(h)}H0z';
    final s = StringBuffer('<clipPath id="${id}c"><path d="$d"/></clipPath>')
      ..write(pathTag(d, fill: tok(tone?.name ?? 'kraft')))
      ..write('<g clip-path="url(#${id}c)">');
    s.write(switch (tone) {
      null => _hardboard(r, id, w, h, rect),
      _ => _gloss(id, rect),
    });
    s
      ..write(
        pathTag(
          'M12 2.2H${num10(w - 12)}M2.2 12V${num10(h - 12)}',
          stroke: tok('photo'),
          sw: 2,
          op: 0.5,
        ),
      )
      ..write(
        pathTag(
          'M12 ${num10(h - 2)}H${num10(w - 12)}M${num10(w - 2)} 12V${num10(h - 12)}',
          stroke: tok('ink'),
          sw: 2.4,
          op: 0.22,
        ),
      )
      ..write('</g>')
      ..write(pathTag(d, stroke: tok('ink'), sw: 0.9, op: 0.42))
      ..write(litEdge('M12 0.7H${num10(w - 12)}', 0.45));
    ink
      ..raw(
        '${shadowMark(SheetShadowKind.lift, const [11, 11, 11, 11])}$s',
        Material.under,
      )
      ..grow(BBox(-1, -1, w + 1, h + 1));
    if (tone != null && !ctx.calm) {
      box(
        ink,
        0.5,
        0.5,
        w - 1,
        h - 1,
        pen: PenName.inkFine,
        corner: 11,
        opts: StrokeOpts(alpha: 0.55, simple: w > 360),
      );
    }
  });
}

String _hardboard(Rng r, String id, double w, double h, String rect) {
  final g = StringBuffer();
  for (var y = 5.0; y < h; y += r.range(9, 15)) {
    final y0 = y + r.gauss(0, 1);
    g.write('M0 ${num10(y0)}');
    for (var k = 0; k < 4; k++) {
      g.write(
        'Q${num10(((k + 0.5) * w) / 4)} ${num10(y0 + r.gauss(0, 1.8))} '
        '${num10(((k + 1) * w) / 4)} ${num10(y0 + r.gauss(0, 0.9))}',
      );
    }
  }
  return '${pathTag(rect, fill: tok('ink'), op: 0.36)}'
      '<defs><path id="${id}g" d="$g"/></defs>'
      '<use href="#${id}g" fill="none" stroke="${tok('ink')}" '
      'stroke-width=".7" stroke-opacity=".13"/>'
      '<use href="#${id}g" fill="none" stroke="${tok('photo')}" '
      'stroke-width=".6" stroke-opacity=".16" transform="translate(0 1.4)"/>';
}

String _gloss(String id, String rect) =>
    '<linearGradient id="${id}s" x1="0" y1="0" x2="0.35" y2="1">'
    '<stop offset="0" stop-color="${tok('photo')}" stop-opacity=".3"/>'
    '<stop offset=".5" stop-color="${tok('photo')}" stop-opacity="0"/>'
    '</linearGradient>'
    '<linearGradient id="${id}d" x1="0" y1="0" x2="1" y2="0">'
    '<stop offset=".6" stop-color="${tok('ink')}" stop-opacity="0"/>'
    '<stop offset="1" stop-color="${tok('ink')}" stop-opacity=".14"/>'
    '</linearGradient>'
    '${pathTag(rect, fill: 'url(#${id}s)')}${pathTag(rect, fill: 'url(#${id}d)')}';

/// The steel clip of a clipboard, [width] px wide (104 by default): a wire
/// arch, a graded plate and two rivets.
///
/// Mirrors `clipboardClip` in `src/lib/ink/recipes/clipboard-ink.ts`.
InkResult clipboardClip(
  Object seed, {
  double? width,
  Tier? tier,
  bool? calm,
}) {
  final ink = Ink(seed, tier: tier, calm: calm);
  final w = width ?? 104;
  final h = w * 0.42;
  final r = ink.next('clip');
  double j() => r.gauss(0, 0.2);
  final id = 'll-cl${ink.seed.toRadixString(36)}';
  final py = h * 0.36;
  final ph = h - py - 1;
  final arch =
      'M${num10(w * 0.16)} ${num10(py + 2)}C${num10(w * 0.16)} ${num10(2)} '
      '${num10(w * 0.24)} ${num10(1.5)} ${num10(w * 0.3)} ${num10(1.5)}'
      'H${num10(w * 0.7)}C${num10(w * 0.76)} ${num10(1.5)} ${num10(w * 0.84)} '
      '${num10(2)} ${num10(w * 0.84)} ${num10(py + 2)}';
  final s = StringBuffer()
    ..write(
      pathTag(
        arch,
        stroke: tok('ink'),
        sw: 4.4,
        op: 0.22,
        transform: 'translate(.8 1.6)',
      ),
    )
    ..write(pathTag(arch, stroke: tok('pencil'), sw: 3.4))
    ..write(
      pathTag(
        arch,
        stroke: tok('photo'),
        sw: 1.2,
        op: 0.85,
        transform: 'translate(-.4 -.7)',
      ),
    );
  final plate =
      'M${num10(3 + j())} ${num10(py + 4)}Q3 ${num10(py)} ${num10(7)} ${num10(py)}'
      'H${num10(w - 7)}Q${num10(w - 3)} ${num10(py)} ${num10(w - 3 + j())} '
      '${num10(py + 4)}V${num10(py + ph - 3)}Q${num10(w - 3)} ${num10(py + ph)} '
      '${num10(w - 7)} ${num10(py + ph)}H${num10(7)}Q3 ${num10(py + ph)} 3 '
      '${num10(py + ph - 3)}z';
  s
    ..write(
      '<linearGradient id="${id}g" x1="0" y1="0" x2="0" y2="1">'
      '<stop offset="0" stop-color="${tok('photo')}"/>'
      '<stop offset=".38" stop-color="${tok('pencil-mark')}"/>'
      '<stop offset="1" stop-color="${tok('pencil')}"/></linearGradient>',
    )
    ..write(
      pathTag(
        plate,
        fill: tok('ink'),
        op: 0.22,
        transform: 'translate(.9 2)',
      ),
    )
    ..write(pathTag(plate, fill: 'url(#${id}g)'))
    ..write(pathTag(plate, stroke: tok('ink'), sw: 0.8, op: 0.5))
    ..write(
      pathTag(
        'M8 ${num10(py + 1.6)}H${num10(w - 8)}',
        stroke: tok('photo'),
        sw: 1,
        op: 0.9,
      ),
    );
  for (final x in [w * 0.16, w * 0.84]) {
    final rivet = circleD(x, py + ph / 2 + 0.5, 2.5);
    s
      ..write(pathTag(rivet, fill: tok('pencil-mark')))
      ..write(pathTag(rivet, stroke: tok('ink'), sw: 0.6, op: 0.5))
      ..write(
        pathTag(
          circleD(x - 0.6, py + ph / 2 - 0.2, 0.8),
          fill: tok('photo'),
          op: 0.95,
        ),
      );
  }
  ink
    ..raw('$s', Material.top)
    ..grow(BBox(0, 0, w, h));
  return ink.toSvg(w: w, h: h, pad: 3);
}
