import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// Confetti piece shapes.
///
/// Mirrors `CONFETTI_KINDS` in `src/lib/ink/recipes/confetti-ink.ts`.
enum ConfettiKind { strip, dot, star, triangle, curl, scrap }

/// Confetti colours.
///
/// Mirrors `CONFETTI_COLORS` in `src/lib/ink/recipes/confetti-ink.ts`.
enum ConfettiColor {
  tomato(PaintKey.tomato),
  tangerine(PaintKey.tangerine),
  lemon(PaintKey.lemon),
  grass(PaintKey.grass),
  teal(PaintKey.teal),
  sky(PaintKey.sky),
  grape(PaintKey.grape),
  bubblegum(PaintKey.bubblegum);

  const ConfettiColor(this.paint);

  /// The paint.
  final PaintKey paint;
}

/// One drawn confetti piece: its markup and size.
///
/// Mirrors `ConfettiPiece` in `src/lib/ink/recipes/confetti-ink.ts`.
typedef ConfettiPiece = ({String svg, double w, double h});

final Map<String, ConfettiPiece> _cache = {};

void _outline(Ink ink, double x, double y, double w, double h) => box(
  ink,
  x,
  y,
  w,
  h,
  pen: PenName.inkFine,
  corner: 1,
  opts: const StrokeOpts(width: 0.55, alpha: 0.6),
);

/// The confetti piece of [kind] in [color]; [variant] picks one of a few
/// shapes. Cached by kind, colour and variant.
///
/// Mirrors `confettiPiece` in `src/lib/ink/recipes/confetti-ink.ts`.
ConfettiPiece confettiPiece(
  ConfettiKind kind,
  PaintKey color, [
  int variant = 0,
]) {
  final key = '${kind.name}|${color.id}|$variant';
  if (_cache[key] case final ConfettiPiece hit) return hit;
  final ink = Ink('confetti|$key', grain: false);
  void fill(List<Pt> poly, [double alpha = 0.95, double mis = 0.55]) =>
      blobFill(
        ink,
        poly,
        color,
        alpha: alpha,
        mis: mis,
        rough: 0.35,
        material: Material.top,
      );
  void printed(List<Pt> pts) {
    ink
      ..flat(
        Material.top,
        polyPath([for (final (x, y) in pts) (x + 0.55, y + 0.4)], 10),
        color,
        op: 0.95,
      )
      ..flat(
        Material.top,
        polyPath(pts, 10),
        PaintKey.ink,
        op: 0.6,
        stroke: PaintKey.ink,
        sw: 0.6,
      );
  }

  final (w, h) = switch (kind) {
    ConfettiKind.strip => (9.0, 17.0),
    ConfettiKind.dot => (14.0, 14.0),
    ConfettiKind.star => (20.0, 20.0),
    ConfettiKind.triangle => (16.0, 15.0),
    ConfettiKind.curl => (26.0, 14.0),
    ConfettiKind.scrap => (16.0, 16.0),
  };
  ink.layer(LayerName.rest, () {
    switch (kind) {
      case ConfettiKind.strip:
        fill(roundRectPoly(1.5, 1.5, 6, 14, 0.8));
        ink.flat(
          Material.top,
          'M4.5 2.5V14.5H7.5V2.5Z',
          PaintKey.ink,
          op: 0.13,
        );
        _outline(ink, 1.5, 1.5, 6, 14);
      case ConfettiKind.dot:
        fill(ellipsePoly(7, 7, 4.8, 4.6, 14));
        ink.flat(
          Material.top,
          'M9.6 5.2a1.5 1.5 0 1 1-.01 0Z',
          PaintKey.photo,
          op: 0.55,
        );
      case ConfettiKind.star:
        final r = Rng('star$variant');
        final pts = <Pt>[];
        for (var i = 0; i < 10; i++) {
          final a = -JsMath.pi / 2 + (i * JsMath.pi) / 5 + r.gauss(0, 0.04);
          final rad =
              switch (i % 2) {
                0 => 8.8,
                _ => 4.4,
              } *
              (1 + r.gauss(0, 0.05));
          pts.add((10 + JsMath.cos(a) * rad, 10.4 + JsMath.sin(a) * rad));
        }
        printed(pts);
      case ConfettiKind.triangle:
        printed([(8, 1.4), (14.8, 13.4), (1.3, 13)]);
      case ConfettiKind.curl:
        final pts = <Pt>[
          for (var i = 0; i <= 14; i++)
            (2 + i * 1.65, 7 + JsMath.sin(i * 0.9 + variant) * 4.2),
        ];
        ink.stroke(
          pts,
          PenName.ink,
          StrokeOpts(
            color: color,
            width: 1.35,
            wobble: 0.3,
            start: StrokeStart.soft,
            end: StrokeEnd.soft,
          ),
        );
      case ConfettiKind.scrap:
        final r = Rng('scrap$variant');
        final pts = <Pt>[];
        final count = 6 + (variant % 2);
        for (var i = 0; i < count; i++) {
          final a = (i / count) * JsMath.pi * 2 + r.gauss(0, 0.2);
          final rad = 4.6 + r() * 3.4;
          pts.add((8 + JsMath.cos(a) * rad, 8 + JsMath.sin(a) * rad));
        }
        fill(pts, 0.95, 0.6);
    }
  });
  final res = ink.toSvg(w: w, h: h, pad: 1);
  final ConfettiPiece out = (svg: res.svg, w: w, h: h);
  _cache[key] = out;
  return out;
}

/// How a burst of confetti flies.
///
/// Mirrors `FlightOptions` in `src/lib/ink/recipes/confetti-ink.ts`.
final class FlightOptions {
  /// Flight options.
  const FlightOptions({
    required this.count,
    required this.spread,
    required this.angle,
    required this.velocity,
    required this.gravity,
    required this.drift,
    required this.duration,
    required this.seed,
  });

  /// Pieces.
  final int count;

  /// Launch cone, in degrees.
  final double spread;

  /// Launch direction, in degrees (90 is up).
  final double angle;
  final double velocity;
  final double gravity;

  /// Sideways wind.
  final double drift;

  /// Flight length, in milliseconds.
  final double duration;
  final num seed;
}

/// One frame of a piece in flight.
typedef FlightFrame = ({
  double x,
  double y,
  double rot,
  double flip,
  double opacity,
});

/// One piece's flight: which piece it is and a frame every [stepMs].
///
/// Mirrors `Flight` in `src/lib/ink/recipes/confetti-ink.ts`.
typedef Flight = ({
  ConfettiKind kind,
  ConfettiColor color,
  int variant,
  List<FlightFrame> frames,
  double scale,
});

/// Milliseconds between flight frames.
///
/// Mirrors `STEP_MS` in `src/lib/ink/recipes/confetti-ink.ts`.
const int stepMs = 50;

/// Simulates a confetti burst: drag, gravity, drift, sway, spin and flip.
///
/// Mirrors `simulate` in `src/lib/ink/recipes/confetti-ink.ts`.
List<Flight> simulate(
  FlightOptions o, [
  List<ConfettiKind> kinds = ConfettiKind.values,
  List<ConfettiColor> colors = ConfettiColor.values,
]) {
  final rng = Rng('flight|${JsMath.numberToString(o.seed)}');
  const dt = stepMs / 1000;
  final steps = math.max(2, JsMath.roundInt(o.duration / stepMs));
  final out = <Flight>[];
  for (var i = 0; i < o.count; i++) {
    final r = rng.fork(i);
    final a = ((o.angle + (r() - 0.5) * o.spread) * JsMath.pi) / 180;
    final speed = o.velocity * (0.35 + 0.65 * JsMath.sqrt(r()));
    var vx = JsMath.cos(a) * speed, vy = -JsMath.sin(a) * speed;
    final drag = 2.6 + r() * 1.2;
    final sway = 10 + r() * 22, swayW = 3.5 + r() * 3, swayP = r() * 6.28;
    final spin = (r() - 0.5) * 900, flipW = 4 + r() * 6, flipP = r() * 6.28;
    var x = 0.0, y = 0.0;
    final frames = <FlightFrame>[];
    for (var s = 0; s <= steps; s++) {
      final t = s * dt;
      final p = s / steps;
      frames.add((
        x: x + JsMath.sin(t * swayW + swayP) * sway * clamp(t * 1.5, 0, 1),
        y: y,
        rot: spin * t * JsMath.exp(-t * 0.6),
        flip: JsMath.cos(flipP + flipW * t),
        opacity: switch (p < 0.72) {
          true => 1.0,
          false => math.max(0, 1 - (p - 0.72) / 0.28).toDouble(),
        },
      ));
      vx += (o.drift - drag * vx) * dt;
      vy += (o.gravity - drag * vy) * dt;
      x += vx * dt;
      y += vy * dt;
    }
    out.add((
      kind: kinds[(r() * kinds.length).floor()],
      color: colors[(r() * colors.length).floor()],
      variant: (r() * 3).floor(),
      frames: frames,
      scale: 0.85 + r() * 0.5,
    ));
  }
  return out;
}
