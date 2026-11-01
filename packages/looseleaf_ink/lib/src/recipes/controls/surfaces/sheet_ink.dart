import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The sheet edge a binding runs along.
///
/// Mirrors `BindingEdge` in `src/lib/ink/recipes/sheet-ink.ts`.
enum BindingEdge { left, right, top, bottom }

/// A wire spiral or punched holes.
///
/// Mirrors `BindingKind` in `src/lib/ink/recipes/sheet-ink.ts`.
enum BindingKind { spiral, holes }

/// Sheet binding params.
///
/// Mirrors `SheetBindingParams` in `src/lib/ink/recipes/sheet-ink.ts`.
final class SheetBindingParams {
  /// Params.
  const SheetBindingParams({required this.edge, required this.kind});

  final BindingEdge edge;
  final BindingKind kind;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'edge': edge.name, 'kind': kind.name};
}

String _tok(String name) => 'var(--ll-$name)';

String _num(double v) => n(v, 10);

/// A notebook binding along one edge of a sheet: a wire spiral through
/// punched holes, or three reinforced holes.
///
/// Mirrors `sheetBindingRecipe` in `src/lib/ink/recipes/sheet-ink.ts`.
final Recipe<SheetBindingParams> sheetBindingRecipe =
    defineRecipe<SheetBindingParams>(
      id: 'sheet-binding',
      kind: 'binding',
      layers: const [LayerName.rest],
      pad: 26,
      draw: _draw,
    );

void _draw(Ink ink, Box size, SheetBindingParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final edge = params.edge;
  final horizontal = edge == BindingEdge.top || edge == BindingEdge.bottom;
  final along = switch (horizontal) {
    true => w,
    false => h,
  };
  final holes = params.kind == BindingKind.holes;
  final holeAt = switch (holes) {
    true => 17.0,
    false => 13.0,
  };
  final r = ink.next('binding');
  Pt map(double v, double u) => switch (edge) {
    BindingEdge.left => (v, u),
    BindingEdge.right => (w - v, u),
    BindingEdge.top => (u, v),
    BindingEdge.bottom => (u, h - v),
  };
  String pt(double v, double u) {
    final (x, y) = map(v, u);
    return '${_num(x)} ${_num(y)}';
  }

  String ellipse(double v, double u, double rv, double ru) {
    final (cx, cy) = map(v, u);
    final (rx, ry) = switch (horizontal) {
      true => (ru, rv),
      false => (rv, ru),
    };
    return 'M${_num(cx - rx)} ${_num(cy)}a${_num(rx)} ${_num(ry)} 0 1 0 '
        '${_num(2 * rx)} 0a${_num(rx)} ${_num(ry)} 0 1 0 ${_num(-2 * rx)} 0z';
  }

  final spots = <double>[];
  if (holes) {
    for (final f in const [0.16, 0.5, 0.84]) {
      spots.add(clamp(f * along, 26, along - 26));
    }
  }
  if (!holes) {
    final pitch = switch (ctx.calm) {
      true => 32,
      false => 28,
    };
    final count = math.max(2, ((along - 20) / pitch).floor());
    final first = (along - (count - 1) * pitch) / 2;
    for (var i = 0; i < count; i++) {
      spots.add(
        first +
            i * pitch +
            r.gauss(0, switch (ctx.calm) {
              true => 0,
              false => 0.7,
            }),
      );
    }
  }
  double jit(double s) => r.gauss(0, s);

  if (holes) {
    final disc = StringBuffer(), ring = StringBuffer(), hole = StringBuffer();
    for (final u in spots) {
      disc.write(ellipse(holeAt, u, 11.2 + jit(0.2), 11 + jit(0.2)));
      ring.write(ellipse(holeAt, u, 11.4 + jit(0.2), 11.1 + jit(0.2)));
      hole.write(ellipse(holeAt, u, 6.6 + jit(0.2), 6.3 + jit(0.2)));
    }
    ink.layer(LayerName.rest, () {
      ink
        ..raw(
          '<path d="$disc" fill="${_tok('photo')}" fill-opacity=".95"/>',
          Material.top,
        )
        ..raw(
          '<path d="$ring" fill="none" stroke="${_tok('pencil')}" '
          'stroke-width=".8" stroke-opacity=".55"/>',
          Material.top,
        )
        ..raw(
          '<path d="$hole" fill="${_tok('ink')}" fill-opacity=".78" '
          'stroke="${_tok('ink')}" stroke-width=".7" stroke-opacity=".8"/>',
          Material.top,
        );
    });
    ink.grow(BBox(0, 0, w, h));
    return;
  }

  final holePaths = StringBuffer(),
      rims = StringBuffer(),
      wires = StringBuffer();
  for (final u in spots) {
    final lean = switch (ctx.calm) {
      true => 0.0,
      false => jit(1.2),
    };
    holePaths.write(ellipse(holeAt, u, 5.4 + jit(0.3), 4.6 + jit(0.3)));
    final a = map(holeAt - 4.6, u + 2.9);
    final b = map(holeAt + 3.8, u + 3.6);
    final c = map(holeAt - 1, u + 4.6);
    rims.write(
      'M${_num(a.x)} ${_num(a.y)}Q${_num(c.x)} ${_num(c.y)} '
      '${_num(b.x)} ${_num(b.y)}',
    );
    final List<Pt> p = [
      (2.6, 2.4 + jit(0.3)),
      (-2.4, -0.2 + jit(0.3) + lean),
      (-8.5 + jit(0.5), -3.6 + jit(0.4) + lean),
      (-14.5 + jit(0.6), -4.2 + jit(0.4) + lean),
      (-20 + jit(0.6), -1.2 + jit(0.5) + lean),
      (-22.4 + jit(0.5), 2.2 + jit(0.5) + lean),
    ];
    String at(int i) => pt(holeAt + p[i].x, u + p[i].y);
    String mid(int i) => pt(
      holeAt + (p[i].x + p[i + 1].x) / 2,
      u + (p[i].y + p[i + 1].y) / 2,
    );
    wires.write(
      'M${at(0)}Q${at(1)} ${mid(1)}Q${at(2)} ${mid(2)}Q${at(3)} ${mid(3)}'
      'Q${at(4)} ${at(5)}',
    );
  }
  final wire = 'll-wr${ink.seed.toRadixString(36)}';
  String reuse(String stroke, double sw, double op, String tf) {
    final transform = switch (tf.isEmpty) {
      true => '',
      false => ' transform="$tf"',
    };
    return '<use href="#$wire" fill="none" stroke="$stroke" '
        'stroke-width="${JsMath.numberToString(sw)}" '
        'stroke-opacity="${JsMath.numberToString(op)}" stroke-linecap="round" '
        'stroke-linejoin="round"$transform/>';
  }

  ink.layer(LayerName.rest, () {
    ink
      ..raw(
        '<path d="$holePaths" fill="${_tok('ink')}" fill-opacity=".78"/>',
        Material.top,
      )
      ..raw(
        '<path d="$rims" fill="none" stroke="${_tok('photo')}" '
        'stroke-width=".7" stroke-opacity=".7" stroke-linecap="round"/>',
        Material.top,
      )
      ..raw(
        '<defs><path id="$wire" d="$wires"/></defs>'
        '${reuse(_tok('ink'), 1.2, 0.36, 'translate(.3 1.1)')}'
        '${reuse(_tok('pencil'), 1.7, 1, '')}'
        '${reuse(_tok('photo'), 0.55, 0.85, 'translate(-.1 -.7)')}',
        Material.top,
      );
  });
  ink.grow(BBox(0, 0, w, h));
}
