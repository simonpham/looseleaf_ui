import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/stubby/body.dart';
import 'package:looseleaf_ink/src/art/stubby/xf.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// Stubby's eyes.
///
/// Mirrors `EyeKind` in `src/lib/ink/art/mascots/body.ts`.
enum EyeKind { dot, happy, closed, wide, squint, dash, x, wink, lens }

/// Stubby's mouths.
///
/// Mirrors `MouthKind` in `src/lib/ink/art/mascots/body.ts`.
enum MouthKind { smile, grin, o, flat, frown, wavy, tongue, yawn, gritted }

/// Stubby's brows.
///
/// Mirrors `BrowKind` in `src/lib/ink/art/mascots/body.ts`.
enum BrowKind { none, up, worry, stern, shrug, one }

/// A face: eyes looking by [look], a mouth, brows and blush.
///
/// Mirrors `Face` in `src/lib/ink/art/mascots/body.ts`.
final class Face {
  /// A face; dot eyes and a smile by default.
  const Face({this.eyes, this.look, this.mouth, this.brows, this.blush});

  /// The eyes.
  final EyeKind? eyes;

  /// Where the eyes look, in grid units.
  final Pt? look;

  /// The mouth.
  final MouthKind? mouth;

  /// The brows.
  final BrowKind? brows;

  /// Blush on the cheeks; on unless false.
  final bool? blush;
}

const double _xl = 25.2, _xr = 39.6, _yl = 41.4, _yr = 41;

double _dotR(MascotTier t) => switch (t) {
  MascotTier.m => 2.7,
  _ => 2.9,
};

double _wid(MascotTier t) => switch (t) {
  MascotTier.m => 1,
  MascotTier.s => 0.95,
  MascotTier.u => 1.5,
};

EyeKind _microEyes(EyeKind k) => switch (k) {
  EyeKind.happy || EyeKind.wide || EyeKind.squint || EyeKind.x => EyeKind.dot,
  EyeKind.closed => EyeKind.dash,
  _ => k,
};

MouthKind _microMouth(MouthKind k) => switch (k) {
  MouthKind.grin || MouthKind.tongue => MouthKind.smile,
  MouthKind.yawn => MouthKind.o,
  MouthKind.wavy || MouthKind.gritted => MouthKind.flat,
  _ => k,
};

List<ArtPart> _eyesOf(EyeKind kind0, MascotTier t, Pt look) {
  final xl = _xl + look.x, yl = _yl + look.y;
  final xr = _xr + look.x, yr = _yr + look.y;
  final w = _wid(t), r = _dotR(t);
  final kind = switch (t) {
    MascotTier.u => _microEyes(kind0),
    _ => kind0,
  };
  String p(double x, double y) => mascotPt(x, y);
  switch (kind) {
    case EyeKind.dot:
      return mascotDots([(xl, yl, r), (xr, yr, r * 0.95)]);
    case EyeKind.happy:
      return [
        mascotLine(
          'M${p(xl - 3.8, yl + 1.8)} Q${p(xl, yl - 4.4)} ${p(xl + 3.8, yl + 1.6)} '
          'M${p(xr - 3.6, yr + 1.6)} Q${p(xr + 0.2, yr - 4.2)} ${p(xr + 3.9, yr + 1.9)}',
          1.1 * w,
        ),
      ];
    case EyeKind.closed:
      return [
        mascotLine(
          'M${p(xl - 3.8, yl - 0.8)} Q${p(xl, yl + 3.8)} ${p(xl + 3.8, yl - 0.6)} '
          'M${p(xr - 3.7, yr - 0.6)} Q${p(xr + 0.2, yr + 3.6)} ${p(xr + 3.8, yr - 0.9)}',
          1.1 * w,
        ),
      ];
    case EyeKind.wide:
      return mascotDots([(xl, yl, r * 1.34), (xr, yr, r * 1.28)]);
    case EyeKind.squint:
      return [
        mascotLine(
          'M${p(xl - 3.6, yl - 3.4)} L${p(xl + 2.6, yl + 0.2)} L${p(xl - 3.4, yl + 3.6)} '
          'M${p(xr + 3.6, yr - 3.4)} L${p(xr - 2.6, yr + 0.2)} L${p(xr + 3.4, yr + 3.6)}',
          1.1 * w,
        ),
      ];
    case EyeKind.dash:
      final a = switch (t) {
        MascotTier.u => 2.4,
        _ => 3.5,
      };
      return [
        mascotLine(
          'M${p(xl - a, yl + 0.2)} L${p(xl + a - 0.3, yl - 0.3)} '
          'M${p(xr - a + 0.2, yr - 0.2)} L${p(xr + a, yr + 0.4)}',
          1.2 * w,
        ),
      ];
    case EyeKind.x:
      return [
        mascotLine(
          'M${p(xl - 3, yl - 3)} L${p(xl + 3, yl + 3.1)} '
          'M${p(xl + 3, yl - 3.1)} L${p(xl - 3, yl + 3)} '
          'M${p(xr - 3.1, yr - 3)} L${p(xr + 3, yr + 3)} '
          'M${p(xr + 3, yr - 3)} L${p(xr - 3.1, yr + 3.1)}',
          1.15 * w,
        ),
      ];
    case EyeKind.wink:
      return [
        mascotDot(xl, yl, r),
        mascotLine(
          'M${p(xr - 3.6, yr + 1.6)} Q${p(xr + 0.2, yr - 4.2)} ${p(xr + 3.9, yr + 1.9)}',
          1.1 * w,
        ),
      ];
    case EyeKind.lens:
      return [mascotDot(xl, yl, r)];
  }
}

const ArtColour _ink = ArtColour(PaintKey.ink);

List<ArtPart> _mouthOf(MouthKind kind0, MascotTier t) {
  final w = _wid(t);
  final kind = switch (t) {
    MascotTier.u => _microMouth(kind0),
    _ => kind0,
  };
  return switch (kind) {
    MouthKind.smile => [mascotLine('M29.4 46.4 Q32.6 50.4 36 46.2', 1 * w)],
    MouthKind.grin => [
      const FillPart(
        _ink,
        'M28.4 46 Q32.6 47.8 37 45.8 Q36.8 52.2 32.6 52.6 Q28.6 52 28.4 46 Z',
      ),
    ],
    MouthKind.o => switch (t) {
      MascotTier.m => [mascotLine('O 32.8 48.8 2.2 2.8', 0.95)],
      MascotTier.s => [mascotDot(32.8, 49, 2.6)],
      MascotTier.u => [mascotDot(32.8, 49, 3)],
    },
    MouthKind.yawn => [
      const FillPart(
        _ink,
        'M30.6 46.6 Q32.6 46 34.8 46.8 Q35.6 50.6 32.8 51.6 Q30 50.8 30.6 46.6 Z',
      ),
    ],
    MouthKind.flat => [mascotLine('M29 48 L36.2 47.6', 1.05 * w)],
    MouthKind.frown => [mascotLine('M29.4 50.2 Q32.8 46.2 36.2 49.6', 1 * w)],
    MouthKind.wavy => [
      mascotLine('M28.6 48.6 Q30.4 46.2 32.4 48.4 Q34.6 50.4 36.6 47.6', 1 * w),
    ],
    MouthKind.gritted => [
      mascotLine('M28.8 47.2 L36.4 47 L36 50.4 L29.2 50.6 Z', 0.85 * w),
      if (t == MascotTier.m) mascotLine('M32.6 47.2 L32.8 50.5', 0.5),
    ],
    MouthKind.tongue => [
      mascotLine('M29.4 46.4 Q32.6 50.4 36 46.2', 1 * w),
      const FillPart(
        ArtColour(PaintKey.tomato),
        'M32.6 49.2 Q32.4 53.4 35 53.2 Q37.2 52.8 36.2 48.6 Z',
      ),
    ],
  };
}

List<ArtPart> _browsOf(BrowKind kind, MascotTier t) {
  if (kind == BrowKind.none || t == MascotTier.u) return [];
  final w =
      switch (t) {
        MascotTier.s => 1.2,
        _ => 1.0,
      } *
      0.85;
  final d = switch (kind) {
    BrowKind.up =>
      'M21.8 35 Q25.2 32.6 28.8 34.4 M36.4 34 Q39.8 31.8 43.2 33.8',
    BrowKind.worry => 'M21.6 36.4 L28.6 33.6 M36.6 33.4 L43.4 36',
    BrowKind.stern => 'M21.8 33.6 L28.8 36 M36.4 35.6 L43.4 33.2',
    BrowKind.shrug => 'M21.8 35.4 Q25.2 32 28.8 33 M36.6 33.8 L43 36',
    BrowKind.one => 'M37 35 Q40 32.8 43.2 34.6',
    BrowKind.none => '',
  };
  return [mascotLine(d, w)];
}

Xf? _faceXf(MascotTier t) => switch (t) {
  MascotTier.s => const Xf(cx: 32.4, cy: 44.4, k: 1.12, dy: 1.2),
  MascotTier.u => const Xf(cx: 32.4, cy: 44.4, k: 1.3, dy: 1.6),
  MascotTier.m => null,
};

/// The face parts at tier [t]; small and micro faces are drawn bigger.
///
/// Mirrors `faceParts` in `src/lib/ink/art/mascots/body.ts`.
List<ArtPart> faceParts(Face f, MascotTier t) {
  final inner = [
    ..._eyesOf(f.eyes ?? EyeKind.dot, t, f.look ?? (0, 0)),
    ..._mouthOf(f.mouth ?? MouthKind.smile, t),
  ];
  final face = switch (_faceXf(t)) {
    final Xf grow => xf(inner, grow),
    null => inner,
  };
  return [..._browsOf(f.brows ?? BrowKind.none, t), ...face];
}
