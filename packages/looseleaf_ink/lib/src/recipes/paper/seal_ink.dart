import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/art.dart';
import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/recipes/paper/paper.dart';

const Hand _checkHand = Hand(start: StrokeStart.pool, end: StrokeEnd.flick);

bool _isPhoto(ArtColour c) => c.id == PaintKey.photo.id;

List<ArtPart> _withMark(
  List<ArtPart> parts,
  SealMark mark,
  bool small,
  bool tiny,
) {
  final out = <ArtPart>[];
  for (var i = 0; i < parts.length; i++) {
    final p = parts[i];
    if (tiny && p is ColourStrokePart && _isPhoto(p.colour)) {
      if (i + 1 < parts.length) {
        if (parts[i + 1] case StrokePart(:final d) when d == p.d) i++;
      }
      continue;
    }
    if (p is! TextPart) {
      out.add(p);
      continue;
    }
    final TextPart(:x, :y, size: em) = p;
    final cy = y - 0.745 * em * 0.5;
    final s =
        em *
        switch (tiny) {
          true => 1.5,
          false => 1.05,
        };
    if (mark == SealMark.check) {
      final width = switch ((tiny, small)) {
        (true, _) => 2.6,
        (false, true) => 1.9,
        (false, false) => 1.75,
      };
      out.add(StrokePart(sealCheckPath(x, cy, s), width, _checkHand));
      continue;
    }
    out.addAll([
      FillPart(const ArtColour(PaintKey.lemon), sealStarPath(x, cy, s * 0.5)),
      StrokePart(sealStarPath(x, cy, s * 0.52), switch (small) {
        true => 1.1,
        false => 0.9,
      }),
    ]);
  }
  return out;
}

List<ArtPart> _recolour(List<ArtPart> parts, PaintKey? ribbon) {
  if (ribbon == null || ribbon == PaintKey.tomato) return [...parts];
  var seen = 0;
  return [
    for (final (i, p) in parts.indexed)
      switch (p) {
        FillPart(:final colour, :final d, :final mis)
            when colour.id == PaintKey.tomato.id && i < 2 && seen++ < 2 =>
          FillPart(ArtColour(ribbon), d, mis),
        _ => p,
      },
  ];
}

ArtDef _copyDef(ArtDef base, List<ArtPart> parts, List<ArtPart> small) =>
    ArtDef(
      grid: base.grid,
      parts: parts,
      small: small,
      micro: base.micro,
      hi: base.hi,
      accent: base.accent,
      nibK: base.nibK,
      tags: base.tags,
      shade: base.shade,
      tilt: base.tilt,
      rtlFlip: base.rtlFlip,
      mirror: base.mirror,
      kind: base.kind,
    );

ArtDef _badgeDef(SealParams p, double px) {
  final shape = BadgeShape.values.byName(p.variant.name);
  final text = p.text ?? '';
  final base = badgeSkeleton(
    switch (text) {
      '' => 'A',
      _ => text,
    },
    BadgeOpts(
      shape: shape,
      color: p.tone ?? PaintKey.bubblegum,
      sub: switch (p.variant) {
        SealVariant.ticket => null,
        _ => p.sub,
      },
      deco: p.deco,
      textColor: p.textColor,
    ),
  );
  var parts = [...base.parts];
  var small = [...base.small ?? base.parts];
  if (p.mark case final SealMark mark) {
    parts = _withMark(parts, mark, false, false);
    small = _withMark(small, mark, true, px < 40);
  }
  if (p.mark == null && text.isEmpty) {
    parts = [
      for (final q in parts)
        if (q is! TextPart) q,
    ];
    small = [
      for (final q in small)
        if (q is! TextPart) q,
    ];
  }
  if (p.variant == SealVariant.rosette || p.variant == SealVariant.medal) {
    parts = _recolour(parts, p.ribbon);
    small = _recolour(small, p.ribbon);
  }
  return _copyDef(base, parts, small);
}

ArtDef _ringDef(SealParams p) {
  final tone = ArtColour(p.tone ?? PaintKey.sky);
  final outer = scalloped(32, 32, 27.2, 30.4, 20, 0.12);
  const bandOut = 'O 32 32 24.2 24.4';
  const bandIn = 'O 32 32 16.4 16.6';
  List<ArtPart> parts(bool small) {
    double pick(double s, double m) => switch (small) {
      true => s,
      false => m,
    };
    final out = <ArtPart>[
      FillPart(tone, outer),
      StrokePart(outer, pick(1.15, 1.05)),
      const ColourStrokePart(ArtColour(PaintKey.photo), bandOut, 0.5),
      const StrokePart(bandOut, 0.5),
      const FillPart(ArtColour(PaintKey.paper), 'O 32 32 15.8', 0.4),
      StrokePart(bandIn, pick(0.8, 0.6)),
    ];
    final text = (p.text ?? '').toUpperCase();
    const cy = 32.0;
    switch (p.mark) {
      case SealMark.check:
        out.add(
          StrokePart(sealCheckPath(32, cy, 13), pick(1.7, 1.5), _checkHand),
        );
      case SealMark.star:
        out.addAll([
          FillPart(const ArtColour(PaintKey.lemon), sealStarPath(32, cy, 8)),
          StrokePart(sealStarPath(32, cy, 8.3), 0.8),
        ]);
      case null when text.isNotEmpty:
        final em = clamp(28 / (text.length * 0.6), 5, pick(11, 12));
        out.add(
          TextPart(
            text,
            32,
            sealRound(cy + 0.745 * em * 0.5),
            sealRound(em),
            ArtColour(p.textColor ?? PaintKey.ink),
            LetterFont.hand,
          ),
        );
      case null:
        break;
    }
    return out;
  }

  return ArtDef(
    grid: ArtGrid.doodle,
    nibK: 0.05,
    parts: parts(false),
    small: parts(true),
    kind: ArtKind.sticker,
  );
}

void _ringLetters(
  Ink ink,
  String text,
  double size,
  double k,
  PaintKey colour,
) {
  final src = [
    for (final rune in text.toUpperCase().trim().runes)
      String.fromCharCode(rune),
  ];
  if (src.isEmpty) return;
  final unit = [...src, ' ', '•', ' '];
  final per = unit.length;
  final repeats = math.max(1, JsMath.roundInt(22 / per));
  final seq = [for (var i = 0; i < repeats; i++) ...unit];
  final rng = ink.rng.fork('ring');
  final em = 4.3 * k;
  final cap = 0.68 * em;
  final mid = 20.3 * k;
  final c = size / 2;
  for (final (i, ch) in seq.indexed) {
    if (ch == ' ') continue;
    final ang = -90 + ((i + 0.5) / seq.length) * 360;
    final a = (ang * JsMath.pi) / 180;
    final rr = mid - cap / 2;
    final t = textPath(
      ch,
      c + JsMath.cos(a) * rr,
      c + JsMath.sin(a) * rr,
      em,
      rng.fork('c$i'),
      TextOpts(font: LetterFont.type, rot: ang + 90, jitter: 0.12),
    );
    ink.flat(Material.text, t.d, colour, bbox: t.bbox);
  }
}

/// A seal or award badge of [size] px: a die-cut badge, a scalloped ring
/// (with text around it from 72 px) or a wax seal.
///
/// Mirrors `sealArt` in `src/lib/ink/recipes/seal-ink.ts`.
InkResult sealArt(
  SealParams p,
  double size,
  String seed, [
  Tier tier = Tier.lo,
]) {
  final px = math.max(16, JsMath.round(size)).toDouble();
  final ink = Ink('seal:$seed:${p.variant.name}', tier: tier);
  if (p.variant == SealVariant.wax) {
    waxSeal(ink, px, p);
    return ink.toSvg(w: px, h: px, pad: (px * 0.12).ceilToDouble());
  }
  const opts = DrawOpts(kind: ArtKind.sticker, tone: ArtTone.doodle);
  final def = switch (p.variant) {
    SealVariant.ring => _ringDef(p),
    _ => _badgeDef(p, px),
  };
  final r = paintSkeleton(ink, def, px, opts);
  if (p.variant == SealVariant.ring && (p.ring ?? '').isNotEmpty && px >= 72) {
    _ringLetters(ink, p.ring ?? '', px, px / 64, PaintKey.ink);
  }
  return ink.toSvg(w: r.w, h: r.h, pad: (px * 0.06).ceilToDouble());
}
