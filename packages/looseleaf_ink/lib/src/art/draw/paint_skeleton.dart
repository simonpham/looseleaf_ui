import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/draw/draw_opts.dart';
import 'package:looseleaf_ink/src/art/draw/silhouette.dart';
import 'package:looseleaf_ink/src/art/draw/variant.dart';
import 'package:looseleaf_ink/src/art/dsl/dsl.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/text/text.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';

/// What [paintSkeleton] drew.
final class PaintedSkeleton {
  /// A painted skeleton.
  const PaintedSkeleton({
    required this.silhouette,
    required this.variant,
    required this.kind,
    required this.nib,
    required this.k,
    required this.w,
    required this.h,
  });

  /// The silhouette.
  final Silhouette silhouette;

  /// The variant drawn.
  final Variant variant;

  /// The kind drawn.
  final ArtKind kind;

  /// The nib width.
  final double nib;

  /// Pixels per grid unit.
  final double k;

  /// The drawn width.
  final double w;

  /// The drawn height.
  final double h;
}

typedef _Nib = ({double k, double min, double max});

_Nib _nibOf(ArtKind kind) => switch (kind) {
  ArtKind.icon => (k: 0.068, min: 1.45, max: 3.4),
  ArtKind.doodle => (k: 0.05, min: 1.7, max: 5.2),
  ArtKind.sticker => (k: 0.055, min: 1.8, max: 5.2),
  ArtKind.mascot => (k: 0.05, min: 1.6, max: 5),
  ArtKind.prop => (k: 0.05, min: 1.6, max: 5),
  ArtKind.scene => (k: 0.04, min: 1.4, max: 4),
};

const double _washAlpha = 0.42;

const Set<PaintKey> _dark = {
  PaintKey.ink,
  PaintKey.inkSoft,
  PaintKey.inkYou,
  PaintKey.pencil,
  PaintKey.red,
  PaintKey.green,
  PaintKey.focus,
};

List<Pt> _wander(List<Pt> pts, Rng rng, double k, double amp) {
  var length = 20.0;
  for (var i = 1; i < pts.length; i++) {
    length +=
        JsMath.hypot(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y) * k;
  }
  final nx = noise1(rng.fork('x'), length, 7 * k);
  final ny = noise1(rng.fork('y'), length, 7 * k);
  final ox = rng.gauss(0, amp * 0.6), oy = rng.gauss(0, amp * 0.6);
  var s = 0.0;
  return [
    for (var i = 0; i < pts.length; i++)
      () {
        final (x, y) = pts[i];
        if (i > 0) {
          s += JsMath.hypot(x - pts[i - 1].x, y - pts[i - 1].y) * k;
        }
        return (x * k + ox + nx(s) * amp, y * k + oy + ny(s) * amp);
      }(),
  ];
}

List<Pt> _roundCorners(List<Pt> pts, List<bool> anchor, double r) {
  if (pts.length < 3 || r < 0.2) return pts;
  final out = <Pt>[pts[0]];
  for (var i = 1; i < pts.length - 1; i++) {
    final a = pts[i - 1], b = pts[i], c = pts[i + 1];
    if (!anchor[i]) {
      out.add(b);
      continue;
    }
    final l1 = JsMath.hypot(b.x - a.x, b.y - a.y);
    final l2 = JsMath.hypot(c.x - b.x, c.y - b.y);
    if (l1 < r * 1.6 || l2 < r * 1.6) {
      out.add(b);
      continue;
    }
    final cos =
        ((b.x - a.x) * (c.x - b.x) + (b.y - a.y) * (c.y - b.y)) / (l1 * l2);
    if (cos > 0.85) {
      out.add(b);
      continue;
    }
    final rr = math.min(math.min(r, l1 * 0.4), l2 * 0.4);
    final p1 = (b.x + ((a.x - b.x) / l1) * rr, b.y + ((a.y - b.y) / l1) * rr);
    final p2 = (b.x + ((c.x - b.x) / l2) * rr, b.y + ((c.y - b.y) / l2) * rr);
    for (var t = 0; t <= 4; t++) {
      final u = t / 4, v = 1 - u;
      out.add((
        v * v * p1.x + 2 * u * v * b.x + u * u * p2.x,
        v * v * p1.y + 2 * u * v * b.y + u * u * p2.y,
      ));
    }
  }
  out.add(pts[pts.length - 1]);
  return out;
}

/// An open path through [pts] on the 1/10 grid.
String artOpenPath(List<Pt> pts) {
  final w = PathWriter(10);
  for (var i = 0; i < pts.length; i++) {
    if (i == 0) {
      w.m(pts[i].x, pts[i].y);
      continue;
    }
    w.l(pts[i].x, pts[i].y);
  }
  return w.d;
}

/// The grid of [def] as `(w, h)`.
(double, double) artGridSize(ArtDef def) => (def.grid.w, def.grid.h);

/// Paints [def] at [size] pixels into [ink], offset by [origin]: fills as
/// marker (or wash, for stickers), outlines and brush strokes with a
/// wandering hand, blots and lettering. Returns the silhouette for a die
/// cut.
///
/// Mirrors `paintSkeleton` in `src/lib/ink/art-draw.ts`.
PaintedSkeleton paintSkeleton(
  Ink ink,
  ArtDef def,
  double size, [
  DrawOpts o = const DrawOpts(),
  Pt origin = (0, 0),
]) {
  final kind = o.kind ?? kindOfDef(def);
  final variant = o.variant ?? variantFor(kind, size);
  final parts = partsFor(def, variant);
  final (gw, gh) = artGridSize(def);
  final k = size / math.max(gw, gh);
  final tone =
      o.tone ??
      switch (kind) {
        ArtKind.icon => ArtTone.ui,
        _ => ArtTone.doodle,
      };
  final nibSpec = _nibOf(kind);
  final nib =
      o.nib ?? clamp(size * (def.nibK ?? nibSpec.k), nibSpec.min, nibSpec.max);
  final inkKey =
      o.ink ??
      switch (tone) {
        ArtTone.ui => PaintKey.current,
        ArtTone.doodle => PaintKey.ink,
      };
  final accent = (o.accent ?? def.accent ?? ArtAccent.hi).paint;
  final icon = kind == ArtKind.icon;
  final sticker = kind == ArtKind.sticker;
  final sPen = switch (icon) {
    true => PenName.inkFine.spec.copyWith(
      step: switch (size <= 40) {
        true => 0.7,
        false => 1.2,
      },
    ),
    false => PenName.ink.spec,
  };
  final penW = sPen.w;
  const wob = 0.12;
  final amp = clamp(size * 0.002, 0.04, 0.22);
  final root = ink.rng.fork('skel');
  final sil = Silhouette(nib);
  final seenFills = <PaintKey>{};
  PaintKey? lastFill;
  final shifted = origin.x != 0 || origin.y != 0;
  List<Pt> off(List<Pt> ps) {
    if (!shifted) return ps;
    return [for (final (x, y) in ps) (x + origin.x, y + origin.y)];
  }

  final tilt = def.tilt ?? 0;
  final tc = JsMath.cos((tilt * JsMath.pi) / 180);
  final ts = JsMath.sin((tilt * JsMath.pi) / 180);
  List<Pt> turn(List<Pt> ps) {
    if (tilt == 0) return ps;
    return [
      for (final (x, y) in ps)
        (
          gw / 2 + (x - gw / 2) * tc - (y - gh) * ts,
          gh + (x - gw / 2) * ts + (y - gh) * tc,
        ),
    ];
  }

  final fillAlpha = switch ((sticker, icon)) {
    (true, _) => 1.0,
    (_, true) => 0.9,
    _ => 0.95,
  };
  final fillMaterial = switch (sticker) {
    true => Material.wash,
    false => Material.marker,
  };
  final cornerR = nib * 0.55;

  for (var i = 0; i < parts.length; i++) {
    final pr = root.fork('p$i');
    switch (parts[i]) {
      case FillPart(:final colour, :final d):
        if (colour.isAccent && tone == ArtTone.ui) continue;
        final polys = polygonsOf(d, rnd: pr.call);
        for (var pi = 0; pi < polys.length; pi++) {
          final px = off(_wander(turn(polys[pi]), pr.fork('w$pi'), k, amp));
          sil.fills.add(smoothClosed(px, tierCfg(Tier.lo)));
          for (var q = 0; q < px.length; q += 2) {
            sil.pts.add(px[q]);
          }
          final key = colour.resolve(accent);
          if (key == null) continue;
          if (colour.isAccent || colour.washed) {
            flatFill(ink, px, key, _washAlpha, Material.marker);
            continue;
          }
          final material = switch ((sticker, _dark.contains(key))) {
            (true, _) => Material.wash,
            (_, true) => Material.text,
            _ => fillMaterial,
          };
          void run() => flatFill(ink, px, key, fillAlpha, material);
          final regroup = sticker && seenFills.contains(key) && lastFill != key;
          if (regroup) ink.group(GroupAttrs(), run, Material.wash);
          if (!regroup) run();
          seenFills.add(key);
          lastFill = key;
        }
      case StrokePart(:final d, :final width, :final hand):
        _stroke(
          ink: ink,
          pr: pr,
          d: d,
          width: width,
          hand: hand,
          key: inkKey,
          washed: false,
          brush: false,
          inSilhouette: true,
          ctx: (k: k, amp: amp, turn: turn, off: off, cornerR: cornerR),
          sil: sil,
          pen: sPen,
          nib: nib,
          penW: penW,
          wob: wob,
          crisp: o.crisp,
        );
      case ColourStrokePart(:final colour, :final d, :final width, :final hand):
        if (colour.isAccent && tone == ArtTone.ui) continue;
        final key = colour.resolve(accent);
        if (key == null) continue;
        _stroke(
          ink: ink,
          pr: pr,
          d: d,
          width: width,
          hand: hand,
          key: key,
          washed: colour.washed,
          brush: true,
          inSilhouette: o.silAll ?? false,
          ctx: (k: k, amp: amp, turn: turn, off: off, cornerR: cornerR),
          sil: sil,
          pen: sPen,
          nib: nib,
          penW: penW,
          wob: wob,
          crisp: o.crisp,
        );
      case DotPart(:final x, :final y, :final r):
        final rr = math.max((r ?? 1.4) * k, nib * 0.62);
        final (tx, ty) = turn([(x, y)])[0];
        final dx = tx * k + origin.x, dy = ty * k + origin.y;
        sil.lines.add(artOpenPath([(dx, dy), (dx + 0.01, dy)]));
        sil.pts.add((dx, dy));
        ink.dot(dx, dy, rr, sPen, StrokeOpts(color: inkKey));
      case TextPart(
        :final text,
        :final x,
        :final y,
        size: final em,
        :final colour,
        font: final letterFont,
      ):
        final px = em * k;
        final key = colour?.resolve(accent) ?? inkKey;
        final font = letterFont ?? LetterFont.hand;
        final t = textPath(
          text,
          x * k + origin.x,
          y * k + origin.y,
          px,
          pr.fork('t'),
          TextOpts(font: font, jitter: 0),
        );
        ink.flat(Material.text, t.d, key, op: 1, bbox: t.bbox);
        final cap = capHeight(font, px);
        final mid = y * k + origin.y - cap * 0.5;
        sil.lines.add(artOpenPath([(t.bbox.x0, mid), (t.bbox.x1, mid)]));
        sil.pts.addAll([(t.bbox.x0, t.bbox.y0), (t.bbox.x1, t.bbox.y1)]);
      case HighlightPart():
        continue;
    }
  }

  return PaintedSkeleton(
    silhouette: sil,
    variant: variant,
    kind: kind,
    nib: nib,
    k: k,
    w: gw * k,
    h: gh * k,
  );
}

typedef _Ctx = ({
  double k,
  double amp,
  List<Pt> Function(List<Pt>) turn,
  List<Pt> Function(List<Pt>) off,
  double cornerR,
});

void _stroke({
  required Ink ink,
  required Rng pr,
  required String d,
  required double? width,
  required Hand? hand,
  required PaintKey key,
  required bool washed,
  required bool brush,
  required bool inSilhouette,
  required _Ctx ctx,
  required Silhouette sil,
  required PenSpec pen,
  required double nib,
  required double penW,
  required double wob,
  required bool? crisp,
}) {
  final wm = width ?? 1;
  final subs = parsePath(d, step: math.max(0.35, 0.9 / ctx.k), rnd: pr.call);
  final taper = hand?.taper ?? 0;
  for (var j = 0; j < subs.length; j++) {
    final sub = subs[j];
    if (sub.pts.length < 2) continue;
    final r = pr.fork('s$j');
    final px = ctx.off(_wander(ctx.turn(sub.pts), r.fork('w'), ctx.k, ctx.amp));
    if (inSilhouette) {
      sil.lines.add(artOpenPath(px));
      for (var q = 0; q < px.length; q += 3) {
        sil.pts.add(px[q]);
      }
    }
    final pts = _roundCorners(px, sub.anchor, ctx.cornerR);
    final brushK = switch (brush) {
      true => 1.5,
      false => 1.0,
    };
    final w = (nib * wm * brushK) / penW;
    final alpha = switch ((washed, brush)) {
      (true, _) => 0.5,
      (_, true) => 0.95,
      _ => 1.0,
    };
    ink.stroke(
      pts,
      pen,
      StrokeOpts(
        poly: true,
        color: key,
        width: w,
        alpha: alpha,
        wobble: wob,
        speed: 1,
        dry: 0,
        simple: crisp,
        start: hand?.start ?? StrokeStart.soft,
        end: hand?.end ?? StrokeEnd.soft,
        press: switch (taper != 0 && !taper.isNaN) {
          true => (t) => math.max(0.3, 1 + taper * (0.5 - t) * 1.5),
          false => null,
        },
      ),
    );
  }
}
