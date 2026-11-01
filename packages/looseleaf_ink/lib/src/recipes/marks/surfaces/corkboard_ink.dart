import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/controls.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The default width of the corkboard's wooden frame.
///
/// Mirrors `CORK_FRAME` in `src/lib/ink/recipes/corkboard-ink.ts`.
const double corkFrame = 12;

const int _tile = 128;

/// Corkboard recipe params.
///
/// Mirrors `CorkBoardParams` in `src/lib/ink/recipes/corkboard-ink.ts`.
final class CorkBoardParams {
  /// Params.
  const CorkBoardParams({this.frame});

  /// The frame width; defaults to [corkFrame].
  final double? frame;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {if (frame case final double f) 'frame': f};
}

String _ell(double cx, double cy, double rx, double ry, [double rot = 0]) {
  final c = JsMath.cos(rot), s = JsMath.sin(rot);
  String p(double x, double y) =>
      '${n(cx + x * c - y * s, 10)} ${n(cy + x * s + y * c, 10)}';
  final arc = '${n(rx, 10)} ${n(ry, 10)} ${n((rot * 180) / JsMath.pi, 10)}';
  return 'M${p(-rx, 0)}A$arc 1 0 ${p(rx, 0)}A$arc 1 0 ${p(-rx, 0)}Z';
}

String _fillPath(String d, PaintKey fill, double op) =>
    '<path d="$d" fill="var(--ll-${fill.id})" fill-opacity="${n(op, 100)}"/>';

String _corkPattern(Ink ink) {
  final rng = ink.next('cork');
  final dots = <String, String>{};
  final chunk = StringBuffer();
  final warm = StringBuffer();
  void wrap(
    double cx,
    double cy,
    double r,
    void Function(double x, double y) draw,
  ) {
    final xs = switch ((cx < r, cx > _tile - r)) {
      (true, _) => const [0, _tile],
      (_, true) => const [0, -_tile],
      _ => const [0],
    };
    final ys = switch ((cy < r, cy > _tile - r)) {
      (true, _) => const [0, _tile],
      (_, true) => const [0, -_tile],
      _ => const [0],
    };
    for (final dx in xs) {
      for (final dy in ys) {
        draw(cx + dx, cy + dy);
      }
    }
  }

  void dot(String kind, double x, double y, double width) {
    final key = '$kind|${JsMath.numberToString(width)}';
    wrap(
      x,
      y,
      width,
      (px, py) =>
          dots[key] = '${dots[key] ?? ''}M${n(px, 10)} ${n(py, 10)}l.01 0',
    );
  }

  const big = [1.1, 1.8, 2.6, 3.6];
  const small = [0.9, 1.5, 2.2];
  for (var i = 0; i < 190; i++) {
    final kind = switch (i % 3) {
      0 => 'soft',
      _ => 'ink',
    };
    final x = rng() * _tile;
    final y = rng() * _tile;
    dot(kind, x, y, big[(rng() * rng() * 4).floor()]);
  }
  for (var i = 0; i < 90; i++) {
    final x = rng() * _tile;
    final y = rng() * _tile;
    dot('light', x, y, small[(rng() * rng() * 3).floor()]);
  }
  for (var i = 0; i < 9; i++) {
    final x = rng() * _tile, y = rng() * _tile;
    final r = 3 + rng() * 5;
    wrap(x, y, r + 2, (px, py) {
      chunk.write(_ell(px, py, r, r * (0.55 + rng() * 0.4), rng() * JsMath.pi));
    });
  }
  for (var i = 0; i < 4; i++) {
    final x = rng() * _tile, y = rng() * _tile;
    final r = 9 + rng() * 9;
    wrap(x, y, r + 2, (px, py) {
      warm.write(_ell(px, py, r, r * (0.7 + rng() * 0.3), rng() * JsMath.pi));
    });
  }
  final id = 'll-cork-${ink.seed.toRadixString(36)}';
  final dotMarkup = StringBuffer();
  for (final MapEntry(:key, value: d) in dots.entries) {
    final [kind, width] = key.split('|');
    final (color, op) = switch (kind) {
      'ink' => (PaintKey.ink, 0.22),
      'soft' => (PaintKey.inkSoft, 0.3),
      _ => (PaintKey.photo, 0.45),
    };
    dotMarkup.write(
      '<path d="$d" fill="none" stroke="var(--ll-${color.id})" '
      'stroke-opacity="${n(op, 100)}" stroke-width="$width" '
      'stroke-linecap="round"/>',
    );
  }
  ink.raw(
    '<defs><pattern id="$id" width="$_tile" height="$_tile" '
    'patternUnits="userSpaceOnUse">'
    '${_fillPath('$warm', PaintKey.marker, 0.09)}'
    '${_fillPath('$chunk', PaintKey.ink, 0.08)}$dotMarkup</pattern></defs>',
    Material.under,
  );
  return id;
}

/// A corkboard: a kraft frame, a cork field filled with a seeded speckle
/// pattern and a bevel; a flat kraft rect when calm.
///
/// Mirrors `corkBoardRecipe` in `src/lib/ink/recipes/corkboard-ink.ts`.
final Recipe<CorkBoardParams> corkBoardRecipe = defineRecipe<CorkBoardParams>(
  id: 'corkboard',
  kind: 'corkboard',
  layers: const [LayerName.rest],
  pad: 12,
  draw: _drawBoard,
);

void _drawBoard(Ink ink, Box size, CorkBoardParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final f = params.frame ?? corkFrame;
  final fs = JsMath.numberToString(f);
  ink.layer(LayerName.rest, () {
    if (ctx.calm) {
      ink.raw(
        '<rect x="$fs" y="$fs" width="${n(w - 2 * f)}" '
        'height="${n(h - 2 * f)}" fill="var(--ll-kraft)"/>',
        Material.top,
      );
      box(ink, 0, 0, w, h, pen: PenName.pencilFine, corner: 3);
      return;
    }
    for (final (x, y, sw, sh) in [
      (1.0, 1.0, w - 2, f),
      (1.0, h - f - 1, w - 2, f),
      (1.0, 1.0, f, h - 2),
      (w - f - 1, 1.0, f, h - 2),
    ]) {
      bandFill(
        ink,
        roundRectPoly(x, y, sw, sh, 2),
        PaintKey.kraft,
        alpha: 0.95,
        mis: 1.6,
        ends: BandEnds.square,
        passes: 2,
      );
    }
    String ring(double a) =>
        'M${n(a)} ${n(a)}H${n(w - a)}V${n(h - a)}H${n(a)}Z'
        'M${n(f)} ${n(f)}V${n(h - f)}H${n(w - f)}V${n(f)}Z';
    ink.flat(
      Material.wash,
      ring(3),
      PaintKey.marker,
      op: 0.4,
      evenOdd: true,
      bbox: BBox(0, 0, w, h),
    );
    box(ink, 0, 0, w, h, pen: PenName.inkFine, corner: 3);
    final g = ink.next('grain');
    for (var i = 0; i < 4; i++) {
      final on = i.isEven;
      final off = 2.5 + g() * (f - 6);
      final a = g() * 0.35, b = 0.55 + g() * 0.4;
      final List<Pt> pts = switch (on) {
        true => [(w * a, off), (w * b, off + (g() - 0.5) * 1.4)],
        false => [(w * a, h - off), (w * b, h - off + (g() - 0.5) * 1.4)],
      };
      ink.lines(
        [
          Line(
            [
              pts[0],
              ((pts[0].x + pts[1].x) / 2, pts[0].y + (g() - 0.5) * 1.2),
              pts[1],
            ],
            o: const StrokeOpts(start: StrokeStart.soft, end: StrokeEnd.soft),
          ),
        ],
        PenName.pencilFine,
        const StrokeOpts(alpha: 0.5, simple: true),
      );
    }
    final pid = _corkPattern(ink);
    final field = rough(
      roundRectPoly(f, f, w - 2 * f, h - 2 * f, 2, 2),
      ink.next('edge'),
      0.8,
      28,
    );
    final fieldPath = smoothClosed(field, tierCfg(ink.tier));
    ink
      ..raw(
        '<defs><path id="$pid-f" d="$fieldPath"/></defs>'
        '<use href="#$pid-f" fill="var(--ll-kraft)"/>'
        '<use href="#$pid-f" fill="var(--ll-marker)" fill-opacity=".13"/>'
        '<use href="#$pid-f" fill="url(#$pid)"/>',
        Material.top,
      )
      ..flat(
        Material.top,
        'M$fs ${fs}H${n(w - f)}V${n(f + 3)}H${n(f + 3)}V${n(h - f)}H${fs}Z',
        PaintKey.ink,
        op: 0.2,
      )
      ..flat(
        Material.top,
        'M${n(w - f)} ${n(f + 3)}V${n(h - f)}H${n(f + 3)}'
        'V${n(h - f - 1.6)}H${n(w - f - 1.6)}V${n(f + 3)}Z',
        PaintKey.photo,
        op: 0.22,
      );
  });
}

/// Corkboard pin recipe params.
///
/// Mirrors `CorkPinParams` in `src/lib/ink/recipes/corkboard-ink.ts`.
final class CorkPinParams {
  /// Params.
  const CorkPinParams({required this.color});

  /// The pin head's paint.
  final PaintKey color;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'color': color.id};
}

/// A push pin: a cast shadow, a coloured head, an ink ring and a shine.
///
/// Mirrors `corkPinRecipe` in `src/lib/ink/recipes/corkboard-ink.ts`.
final Recipe<CorkPinParams> corkPinRecipe = defineRecipe<CorkPinParams>(
  id: 'corkboard-pin',
  kind: 'corkboard-pin',
  layers: const [LayerName.rest],
  pad: 6,
  draw: _drawPin,
);

void _drawPin(Ink ink, Box size, CorkPinParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  final cx = w / 2, cy = h / 2 - 1;
  final r = math.min(w, h) * 0.33;
  ink.layer(LayerName.rest, () {
    ink.flat(
      Material.wash,
      _ell(cx + 3.2, cy + 4.6, r * 0.95, r * 0.7, 0.5),
      PaintKey.ink,
      op: 0.26,
    );
    blobFill(
      ink,
      roundRectPoly(cx - r, cy - r, 2 * r, 2 * r, r),
      params.color,
      alpha: 0.95,
      mis: 0.8,
    );
    loop(ink, cx, cy, r + 0.6, r + 0.4, pen: PenName.inkFine, turns: 1.06);
    ink.flat(
      Material.top,
      _ell(cx - r * 0.35, cy - r * 0.4, r * 0.32, r * 0.22, -0.7),
      PaintKey.photo,
      op: 0.85,
    );
  });
}

/// A note pinned to the corkboard: only a lazy focus ring.
///
/// Mirrors `corkNoteRecipe` in `src/lib/ink/recipes/corkboard-ink.ts`.
final Recipe<NoParams> corkNoteRecipe = defineRecipe<NoParams>(
  id: 'corkboard-note',
  kind: 'corkboard-note',
  layers: const [LayerName.focus],
  lazy: const [LayerName.focus],
  pad: 12,
  draw: (ink, size, params, ctx) {
    final Box(:w, :h) = size;
    ctx.lazy(
      LayerName.focus,
      (f) => focusRing(
        f,
        -2,
        -2,
        w + 4,
        h + 4,
        r: clamp(math.min(w, h) * 0.05, 2, 5),
      ),
    );
  },
);
