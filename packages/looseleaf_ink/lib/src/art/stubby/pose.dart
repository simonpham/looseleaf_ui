import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/stubby/body.dart';
import 'package:looseleaf_ink/src/art/stubby/face.dart';
import 'package:looseleaf_ink/src/art/stubby/xf.dart';

/// An accessory per tier: master parts, and optional small and micro ones
/// (small falls back to master, micro to nothing).
///
/// Mirrors `Acc` in `src/lib/ink/art/mascots/body.ts`.
final class Acc {
  /// An accessory.
  const Acc({required this.m, this.s, this.u});

  /// Master parts.
  final List<ArtPart> m;

  /// Small parts.
  final List<ArtPart>? s;

  /// Micro parts.
  final List<ArtPart>? u;

  List<ArtPart> _at(MascotTier t) => switch (t) {
    MascotTier.m => m,
    MascotTier.s => s ?? m,
    MascotTier.u => u ?? const [],
  };
}

/// A pose: the face, a body transform, the tip, peeking, accessories over
/// and under the body, extra detail and tags.
///
/// Mirrors `PoseSpec` in `src/lib/ink/art/mascots/body.ts`.
final class PoseSpec {
  /// A pose.
  const PoseSpec({
    required this.face,
    this.turn,
    this.tip,
    this.peek = false,
    this.acc,
    this.under,
    this.hi,
    this.tags,
  });

  /// The face.
  final Face face;

  /// The body transform.
  final Xf? turn;

  /// The pencil tip.
  final PencilTip? tip;

  /// Peeking over tape.
  final bool peek;

  /// Accessory over the body.
  final Acc? acc;

  /// Accessory under the body.
  final Acc? under;

  /// Extra detail at large sizes.
  final List<ArtPart>? hi;

  /// Search tags.
  final List<String>? tags;
}

/// How much the body is scaled inside its grid.
///
/// Mirrors `BODY_K` in `src/lib/ink/art/mascots/body.ts`.
const double bodyK = 0.9;

/// Builds a mascot definition from a pose: master, small and micro tiers
/// and the large-size highlights, on the `[64, 72]` grid.
///
/// Mirrors `pose` in `src/lib/ink/art/mascots/body.ts`.
ArtDef pose(PoseSpec spec) {
  final t0 = spec.turn ?? const Xf();
  final turn = Xf(
    dx: t0.dx,
    dy: switch (spec.peek) {
      true => 8.8,
      false => t0.dy,
    },
    rot: t0.rot,
    k: t0.k,
    sx: (t0.sx ?? t0.k ?? 1) * bodyK,
    sy: (t0.sy ?? t0.k ?? 1) * bodyK,
    cx: t0.cx,
    cy: t0.cy,
  );
  List<ArtPart> face(MascotTier t) => switch (spec.peek) {
    true => xf(
      xf(faceParts(spec.face, t), const Xf(dy: -4.2, cy: 40, sy: 0.9)),
      turn,
    ),
    false => xf(faceParts(spec.face, t), turn),
  };
  List<ArtPart> at(MascotTier t) => [
    ...?spec.under?._at(t),
    ...xf(switch (spec.peek) {
      true => peekParts(t, blush: spec.face.blush),
      false => bodyParts(t, tip: spec.tip, blush: spec.face.blush),
    }, turn),
    ...face(t),
    ...?spec.acc?._at(t),
  ];
  return ArtDef(
    grid: const ArtGrid(64, 72),
    nibK: 0.05,
    shade: false,
    tags: spec.tags,
    parts: at(MascotTier.m),
    small: at(MascotTier.s),
    micro: at(MascotTier.u),
    hi: switch (spec.peek) {
      true => const [],
      false => [...xf(bodyHi, turn), ...?spec.hi],
    },
    kind: ArtKind.mascot,
  );
}
