import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/paper.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

/// How a notebook is bound.
///
/// Mirrors `NotebookBinding` in `src/lib/ink/recipes/notebook-ink.ts`.
enum NotebookBinding { spiral, rings, stitched, none }

/// Which edge a notebook is bound on.
///
/// Mirrors `NotebookSide` in `src/lib/ink/recipes/notebook-ink.ts`.
enum NotebookSide { start, top }

/// Notebook decor recipe params.
///
/// Mirrors `NotebookParams` in `src/lib/ink/recipes/notebook-ink.ts`.
final class NotebookParams {
  /// Params.
  const NotebookParams({
    required this.binding,
    required this.side,
    required this.pages,
    this.tone,
    this.curl,
  });

  /// The binding.
  final NotebookBinding binding;

  /// The bound edge.
  final NotebookSide side;

  /// How many pages peek out below.
  final int pages;

  /// The wire or thread colour; steel when null.
  final Accent? tone;

  /// A dog-eared bottom-right corner on the stack.
  final bool? curl;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'binding': binding.name,
    'side': side.name,
    'pages': pages,
    'tone': tone?.name ?? 'steel',
    if (curl case final bool c) 'curl': c,
  };
}

/// Notebook binding geometry: the hole x, the spiral pitch and the end
/// inset.
///
/// Mirrors `NOTEBOOK` in `src/lib/ink/recipes/notebook-ink.ts`.
const ({double holeX, double pitch, double inset}) notebookLayout = (
  holeX: 15,
  pitch: 24,
  inset: 20,
);

/// The hole positions along a [len] long bound edge.
///
/// Mirrors `notebookHoles` in `src/lib/ink/recipes/notebook-ink.ts`.
List<double> notebookHoles(double len, NotebookBinding binding) {
  if (binding == NotebookBinding.none) return const [];
  if (binding == NotebookBinding.rings) {
    if (len >= 360) return [len * 0.14, len * 0.5, len * 0.86];
    if (len >= 190) return [len * 0.3, len * 0.7];
    return [len / 2];
  }
  final pitch = switch (binding) {
    NotebookBinding.stitched => 22.0,
    _ => notebookLayout.pitch,
  };
  final room = len - 2 * notebookLayout.inset;
  final count = math.max(1, (room / pitch).floor() + 1);
  if (count == 1) return [len / 2];
  return [
    for (var i = 0; i < count; i++)
      notebookLayout.inset + (room * i) / (count - 1),
  ];
}

String _wire(String d, double w, String base, {String cap = 'round'}) =>
    pathTag(
      d,
      stroke: tok('ink'),
      sw: w + 1.3,
      op: 0.2,
      transform: 'translate(.9 1.7)',
      cap: cap,
    ) +
    pathTag(d, stroke: base, sw: w, cap: cap) +
    pathTag(
      d,
      stroke: tok('ink'),
      sw: w * 0.36,
      op: 0.5,
      transform: 'translate(.5 .7)',
      cap: cap,
    ) +
    pathTag(
      d,
      stroke: tok('photo'),
      sw: w * 0.3,
      op: 0.9,
      transform: 'translate(-.4 -.55)',
      cap: cap,
    );

String _bindingSvg(Ink ink, double len, NotebookParams p) {
  final r = ink.next('binding');
  final base = tok(p.tone?.name ?? 'pencil');
  final ys = notebookHoles(len, p.binding);
  final id = 'll-nb${ink.seed.toRadixString(36)}';
  final holes = StringBuffer();
  var metal = '';
  String gutter(int wd, double op) =>
      '<linearGradient id="${id}g" x1="0" y1="0" x2="1" y2="0">'
      '<stop offset="0" stop-color="${tok('ink')}" stop-opacity="${js(op)}"/>'
      '<stop offset="1" stop-color="${tok('ink')}" stop-opacity="0"/>'
      '</linearGradient><rect x="0" y="0" width="$wd" height="${num10(len)}" '
      'fill="url(#${id}g)"/>';
  switch (p.binding) {
    case NotebookBinding.spiral:
      holes.write(gutter(20, 0.07));
      final x = notebookLayout.holeX;
      final d =
          'M${num10(x + 0.4)} 0.3C${num10(x - 6)} -2.5 ${num10(-2)} -7.2 '
          '${num10(-6.5)} -6.8C${num10(-12.2)} -6.4 ${num10(-13.4)} 0.8 '
          '${num10(-10.4)} 4.2C${num10(-8)} 7.2 ${num10(-3.8)} 8.6 '
          '${num10(0.5)} 8.4';
      holes.write(
        '<defs><g id="${id}c">${holePunch('${id}h', x, 0, 3.9, 20)}'
        '${_wire(d, 2.3, base, cap: 'butt')}</g></defs>',
      );
      for (final y0 in ys) {
        holes.write(
          '<use href="#${id}c" transform="translate(${num10(r.gauss(0, 0.35))} '
          '${num10(y0 + r.gauss(0, 0.5))}) '
          'rotate(${num10(r.gauss(0, 1.6))} ${num10(x)} 0)"/>',
        );
      }
    case NotebookBinding.rings:
      holes.write(gutter(26, 0.08));
      for (final (i, y0) in ys.indexed) {
        final y = y0 + r.gauss(0, 0.6);
        final x = 17 + r.gauss(0, 0.4);
        holes
          ..write(reinforcement(x, y, 6.2))
          ..write(holePunch('${id}h$i', x, y, 6.2, r.range(-25, 25)));
        final ry = 16.5 + r.gauss(0, 0.4);
        final d =
            'M${num10(-3)} ${num10(y - ry)}C${num10(x + 17)} ${num10(y - ry - 1)} '
            '${num10(x + 17)} ${num10(y + ry + 1)} ${num10(-3)} ${num10(y + ry)}';
        metal += _wire(d, 3.1, base);
      }
      final top = ys.first - 26;
      final bot = ys.last + 26;
      final strip =
          'M${num10(-8)} ${num10(top)}H${num10(-1)}V${num10(bot)}H${num10(-8)}z';
      metal =
          pathTag(
            strip,
            fill: tok('ink'),
            op: 0.18,
            transform: 'translate(1 1.6)',
          ) +
          pathTag(strip, fill: tok('pencil-mark')) +
          pathTag(strip, stroke: tok('ink'), sw: 0.7, op: 0.4) +
          pathTag(
            'M${num10(-7)} ${num10(top + 1)}V${num10(bot - 1)}',
            stroke: tok('photo'),
            sw: 1,
            op: 0.85,
          ) +
          metal;
    case NotebookBinding.stitched:
      holes.write(gutter(24, 0.09));
      final thread = tok(p.tone?.name ?? 'ink-you');
      final stitch = StringBuffer();
      final pts = <Pt>[
        for (final y0 in ys)
          (
            notebookLayout.holeX - 3 + r.gauss(0, 0.3),
            y0 + r.gauss(0, 0.4),
          ),
      ];
      for (final (i, (x, y)) in pts.indexed) {
        holes.write(holePunch('${id}h$i', x, y, 2.6, 0));
        if (i + 1 < pts.length && i.isEven) {
          final (nx, ny) = pts[i + 1];
          stitch.write(
            'M${num10(x)} ${num10(y + 2.8)}Q${num10(x + r.gauss(0, 0.5))} '
            '${num10((y + ny) / 2)} ${num10(nx)} ${num10(ny - 2.8)}',
          );
        }
      }
      metal +=
          pathTag(
            '$stitch',
            stroke: tok('ink'),
            sw: 3.1,
            op: 0.16,
            transform: 'translate(.9 1.1)',
          ) +
          pathTag('$stitch', stroke: thread, sw: 2.3) +
          pathTag(
            '$stitch',
            stroke: tok('photo'),
            sw: 0.6,
            op: 0.6,
            transform: 'translate(-.5 -.2)',
          );
    case NotebookBinding.none:
      break;
  }
  return '$holes$metal';
}

/// A notebook's page stack, dog-ear and binding (spiral wire, rings or
/// stitches) along the start or top edge.
///
/// Mirrors `notebookRecipe` in `src/lib/ink/recipes/notebook-ink.ts`.
final Recipe<NotebookParams> notebookRecipe = defineRecipe<NotebookParams>(
  id: 'notebook-decor',
  kind: 'notebook',
  layers: const [LayerName.rest],
  pad: 26,
  draw: (ink, size, p, ctx) {
    final Box(:w, :h) = size;
    final id = 'll-nk${ink.seed.toRadixString(36)}';
    ink.layer(LayerName.rest, () {
      final r = ink.next('stack');
      final s = StringBuffer(stackSvg(w, h, p.pages, r, id));
      if ((p.curl ?? false) && p.pages > 0 && !ctx.calm) {
        const c = 34.0;
        final x0 = w - c;
        final y0 = h - c;
        final notch =
            'M${num10(x0 - 1)} ${num10(h + 1)}H${num10(w + 1)}V${num10(y0 - 1)}z';
        s
          ..write(
            '<linearGradient id="${id}n" gradientUnits="userSpaceOnUse" '
            'x1="${num10(x0 + c / 2)}" y1="${num10(y0 + c / 2)}" '
            'x2="${num10(x0 + c * 0.86)}" y2="${num10(y0 + c * 0.86)}">'
            '<stop offset="0" stop-color="${tok('ink')}" stop-opacity=".16"/>'
            '<stop offset="1" stop-color="${tok('ink')}" stop-opacity="0"/>'
            '</linearGradient>',
          )
          ..write(pathTag(notch, fill: tok('paper-shade')))
          ..write(pathTag(notch, fill: 'url(#${id}n)'));
      }
      if (p.binding != NotebookBinding.none) {
        final top = p.side == NotebookSide.top;
        final len = switch (top) {
          true => w,
          false => h,
        };
        final edge = _bindingSvg(ink, len, p);
        final t = switch ((top, ctx.dir)) {
          (true, _) => 'translate(${num10(w)} 0) rotate(90)',
          (false, Dir.rtl) => mirrorTransform(w),
          _ => '',
        };
        s.write(switch (t.isEmpty) {
          true => edge,
          false => '<g transform="$t">$edge</g>',
        });
      }
      ink
        ..raw('$s', Material.top)
        ..grow(BBox(-26, -26, w + 26, h + 26));
    });
  },
);
