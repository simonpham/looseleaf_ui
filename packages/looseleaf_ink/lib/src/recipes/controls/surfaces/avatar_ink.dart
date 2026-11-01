import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/controls/no_params.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The marker tones an avatar fallback is filled with.
///
/// Mirrors `AVATAR_TONES` in `src/lib/ink/recipes/avatar-ink.ts`.
enum AvatarTone {
  tomato(PaintKey.tomato),
  tangerine(PaintKey.tangerine),
  lemon(PaintKey.lemon),
  grass(PaintKey.grass),
  teal(PaintKey.teal),
  sky(PaintKey.sky),
  grape(PaintKey.grape),
  bubblegum(PaintKey.bubblegum);

  const AvatarTone(this.paint);

  /// The fill paint.
  final PaintKey paint;
}

/// The tone a [name] always gets.
///
/// Mirrors `avatarTone` in `src/lib/ink/recipes/avatar-ink.ts`.
AvatarTone avatarTone(String name) {
  final h = hashSeed(name.trim().toLowerCase());
  final mixed = JsMath.imul(h ^ (h >> 15), 0x2c1b3c6d) & 0xFFFFFFFF;
  return AvatarTone.values[mixed >> 29];
}

/// The first letters of the first and last words of [name], upper-cased.
///
/// Mirrors `initials` in `src/lib/ink/recipes/avatar-ink.ts`.
String avatarInitials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '';
  String firstOf(String word) => switch (word.runes.firstOrNull) {
    final int rune => String.fromCharCode(rune),
    null => '',
  };
  final first = firstOf(words.first);
  final last = switch (words.length > 1) {
    true => firstOf(words.last),
    false => '',
  };
  return (first + last).toUpperCase();
}

/// The ring drawn around an avatar; `id` is the upstream name.
///
/// Mirrors `AvatarRing` and `RING_PEN` in `src/lib/ink/recipes/avatar-ink.ts`.
enum AvatarRing {
  ink(PenName.inkFine),
  you(PenName.blueFine),
  marker(PenName.terracotta);

  const AvatarRing(this.pen);

  /// The ring's pen.
  final PenName pen;
}

/// Avatar ring params.
///
/// Mirrors the params of `avatarRingRecipe` in
/// `src/lib/ink/recipes/avatar-ink.ts`.
final class AvatarRingParams {
  /// Params.
  const AvatarRingParams({required this.ring});

  final AvatarRing ring;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'ring': ring.name};
}

/// A loop around the avatar: inked, blue for "you", or a thin terracotta
/// marker.
///
/// Mirrors `avatarRingRecipe` in `src/lib/ink/recipes/avatar-ink.ts`.
final Recipe<AvatarRingParams> avatarRingRecipe =
    defineRecipe<AvatarRingParams>(
      id: 'avatar-ring',
      kind: 'avatar',
      layers: const [LayerName.rest],
      pad: 8,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final cx = w / 2, cy = h / 2;
        final s = math.min(w, h);
        ink.layer(LayerName.rest, () {
          if (params.ring == AvatarRing.marker) {
            loop(
              ink,
              cx,
              cy,
              w / 2 + 1,
              h / 2 + 1,
              pen: PenName.terracotta,
              turns: 1.06,
              opts: StrokeOpts(width: clamp(s / 60, 0.28, 0.5), alpha: 0.8),
            );
            return;
          }
          loop(
            ink,
            cx,
            cy,
            w / 2 + 1.6,
            h / 2 + 1.6,
            pen: switch (ctx.calm) {
              true => PenName.pencilFine,
              false => params.ring.pen,
            },
            turns: switch (ctx.calm) {
              true => 1.02,
              false => 1.09,
            },
            opts: StrokeOpts(width: clamp(s / 34, 0.85, 1.35)),
          );
        });
      },
    );

/// Avatar fallback params.
///
/// Mirrors the params of `avatarFallbackRecipe` in
/// `src/lib/ink/recipes/avatar-ink.ts`.
final class AvatarFallbackParams {
  /// Params.
  const AvatarFallbackParams({required this.tone});

  final AvatarTone tone;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'tone': tone.name};
}

/// The disc behind an avatar's initials, filled with its tone.
///
/// Mirrors `avatarFallbackRecipe` in `src/lib/ink/recipes/avatar-ink.ts`.
final Recipe<AvatarFallbackParams> avatarFallbackRecipe =
    defineRecipe<AvatarFallbackParams>(
      id: 'avatar-fallback',
      kind: 'disc',
      layers: const [LayerName.rest],
      pad: 6,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final cx = w / 2, cy = h / 2;
        final body = ellipsePoly(cx, cy, w / 2 - 0.5, h / 2 - 0.5, 28);
        ink.layer(LayerName.rest, () {
          ink.poly(Material.under, body, PaintKey.slip, 0.95);
          final key = params.tone.paint;
          if (ctx.calm) {
            wash(ink, body, key, alpha: 0.5);
            return;
          }
          ink.part(
            'fill',
            () => blobFill(
              ink,
              body,
              key,
              alpha: 0.62,
              mis: clamp(math.min(w, h) * 0.07, 0.8, 2.4),
            ),
          );
        });
      },
    );

/// An avatar's presence status and its paint.
///
/// Mirrors `AvatarStatus` and `STATUS_KEY` in
/// `src/lib/ink/recipes/avatar-ink.ts`.
enum AvatarStatus {
  online(PaintKey.grass),
  away(PaintKey.tangerine),
  busy(PaintKey.tomato),
  offline(PaintKey.pencilMark),
  marker(PaintKey.marker);

  const AvatarStatus(this.paint);

  /// The dot's paint.
  final PaintKey paint;
}

/// Avatar badge params.
///
/// Mirrors the params of `avatarBadgeRecipe` in
/// `src/lib/ink/recipes/avatar-ink.ts`.
final class AvatarBadgeParams {
  /// Params.
  const AvatarBadgeParams({required this.status});

  final AvatarStatus status;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'status': status.name};
}

/// The status dot on an avatar: a marker blob in an inked loop.
///
/// Mirrors `avatarBadgeRecipe` in `src/lib/ink/recipes/avatar-ink.ts`.
final Recipe<AvatarBadgeParams> avatarBadgeRecipe =
    defineRecipe<AvatarBadgeParams>(
      id: 'avatar-badge',
      kind: 'dot',
      layers: const [LayerName.rest],
      pad: 4,
      draw: (ink, size, params, ctx) {
        final Box(:w, :h) = size;
        final status = params.status;
        final cx = w / 2, cy = h / 2;
        ink.layer(LayerName.rest, () {
          ink.poly(
            Material.under,
            ellipsePoly(cx, cy, w / 2 + 0.5, h / 2 + 0.5, 16),
            PaintKey.slip,
            0.95,
          );
          blobFill(
            ink,
            ellipsePoly(cx, cy, w / 2 - 0.4, h / 2 - 0.4, 16),
            status.paint,
            alpha: switch (status) {
              AvatarStatus.offline => 0.55,
              _ => 0.92,
            },
            mis: switch (ctx.calm) {
              true => null,
              false => 0.5,
            },
            rough: 0.4,
          );
          if (ctx.calm) return;
          loop(
            ink,
            cx,
            cy,
            w / 2 + 0.2,
            h / 2 + 0.2,
            pen: PenName.inkFine,
            turns: 1.1,
            opts: const StrokeOpts(width: 0.85),
          );
        });
      },
    );

/// The "+N" disc after a stack of avatars: a shaded, dashed circle.
///
/// Mirrors `avatarCountRecipe` in `src/lib/ink/recipes/avatar-ink.ts`.
final Recipe<NoParams> avatarCountRecipe = defineRecipe<NoParams>(
  id: 'avatar-count',
  kind: 'disc',
  layers: const [LayerName.rest],
  pad: 6,
  draw: (ink, size, _, ctx) {
    final Box(:w, :h) = size;
    final body = ellipsePoly(w / 2, h / 2, w / 2 - 1, h / 2 - 1, 28);
    ink.layer(LayerName.rest, () {
      ink.poly(Material.under, body, PaintKey.slip, 0.95);
      wash(ink, body, PaintKey.paperShade, alpha: 0.9);
      dashedBox(
        ink,
        0.5,
        0.5,
        w - 1,
        h - 1,
        r: math.min(w, h) / 2,
        pen: switch (ctx.calm) {
          true => PenName.pencilFine,
          false => PenName.pencil,
        },
        dash: math.max(4, math.min(w, h) * 0.2),
      );
    });
  },
);
