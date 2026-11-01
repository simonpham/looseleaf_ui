import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/stubby/xf.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// The detail level of the mascot: master, small or micro.
///
/// Mirrors `Tier` in `src/lib/ink/art/mascots/body.ts`.
enum MascotTier { m, s, u }

/// The pencil tip: sharp graphite or snapped.
enum PencilTip { graphite, snapped }

ArtPart _fill(PaintKey key, String d) => FillPart(ArtColour(key), d);

ArtPart _outline(String d, double w) => StrokePart(d, w);

const List<Pt> _out = [
  (14, 58.6),
  (12.8, 46),
  (13.2, 34),
  (13.8, 26.6),
  (21.6, 15.4),
  (28.4, 8.2),
  (32.4, 4.2),
  (36.4, 8.6),
  (43.4, 16.4),
  (51.2, 26.8),
  (51.8, 38),
  (51.6, 50),
  (50.6, 58.8),
  (46.2, 65.8),
  (38, 68.4),
  (28, 68.6),
  (19.4, 66.2),
];

final String _outline0 = mascotSpline(
  _out,
  closed: true,
  corners: [6],
  z: true,
);

/// The scalloped line where the sharpened wood meets the paint.
const String mascotScallop =
    'M13.8 26.6 Q19.8 34.4 26.6 27.8 Q32.8 34.8 39.2 27.6 Q45.4 33.8 51.2 26.8';

final String _cone =
    '${mascotSpline([(14.4, 26.2), (21.8, 15.8), (28.6, 8.6), (32.4, 4.8), (36.3, 9), (43.3, 16.8), (50.6, 26.4)], corners: [3])} '
    'Q45.4 33.6 39.2 27.4 Q32.8 34.6 26.6 27.6 Q19.8 34.2 14.4 26.2 Z';

const String _barrel =
    'M17.6 24.4 L47.6 24.4 L50.6 27.2 L51 42 L50.4 57 L50.2 60.2 L15.8 60.6 '
    'L14.8 58 L13.6 42 L14.6 27 Z';

final String _eraser = mascotSpline(
  [
    (14.6, 57.8),
    (50.8, 57.2),
    (50.3, 60.4),
    (46, 65.2),
    (38, 67.7),
    (28, 67.9),
    (20, 65.6),
    (15.6, 61.6),
  ],
  closed: true,
  corners: [0, 1],
  z: true,
);

const String _tip = 'M32.4 4.8 L38.2 11.2 Q32.4 14.4 26.6 11.4 Z';
const String _tipSnapped = 'M29.4 8 L35.8 8.6 L38 11.2 Q32.4 14.2 26.6 11.4 Z';

final String _blush =
    '${mascotOval(19.8, 46.8, 3.7, 2.3, -4)} ${mascotOval(45.2, 46.4, 3.7, 2.3, 3)}';

/// Stubby's body (a pencil stub): barrel, cone, tip, eraser, blush and
/// outline at tier [t].
///
/// Mirrors `bodyParts` in `src/lib/ink/art/mascots/body.ts`.
List<ArtPart> bodyParts(MascotTier t, {PencilTip? tip, bool? blush}) {
  final tipPath = switch (tip) {
    PencilTip.snapped => _tipSnapped,
    _ => _tip,
  };
  final fills = [
    _fill(PaintKey.lemon, _barrel),
    _fill(PaintKey.kraft, _cone),
    _fill(PaintKey.pencil, tipPath),
    _fill(PaintKey.bubblegum, _eraser),
  ];
  if (t == MascotTier.u) return [...fills, _outline(_outline0, 0.9)];
  return [
    ...fills,
    if (blush != false) _fill(PaintKey.bubblegum, _blush),
    _outline(_outline0, switch (t) {
      MascotTier.s => 1.15,
      _ => 1.05,
    }),
    mascotLine(mascotScallop, switch (t) {
      MascotTier.s => 1,
      _ => 0.85,
    }),
  ];
}

/// The highlights drawn on the body at large sizes.
///
/// Mirrors `bodyHi` in `src/lib/ink/art/mascots/body.ts`.
final List<ArtPart> bodyHi = [
  const ColourStrokePart(
    ArtColour(PaintKey.photo),
    'M18.6 32.4 Q18 38.2 18.8 42.6',
    0.55,
  ),
  mascotLine('M14.2 58 L50.8 57.2', 0.8),
];

/// Stubby peeking over a strip of tape: the top of the body only.
///
/// Mirrors `peekParts` in `src/lib/ink/art/mascots/body.ts`.
List<ArtPart> peekParts(MascotTier t, {bool? blush}) {
  final sides = mascotSpline(
    [
      (13, 47.6),
      (13.2, 34),
      (13.8, 26.6),
      (21.6, 15.4),
      (28.4, 8.2),
      (32.4, 4.2),
      (36.4, 8.6),
      (43.4, 16.4),
      (51.2, 26.8),
      (51.8, 38),
      (51.6, 47.8),
    ],
    corners: [5],
  );
  const strip = 'M7.6 47.2 L57.4 46 L58.4 58.6 L8.4 60.2 Z';
  final fills = [
    _fill(
      PaintKey.lemon,
      'M17.6 24.4 L47.6 24.4 L50.6 27.2 L51 42 L50.6 50 L14.6 51 L13.6 42 '
      'L14.6 27 Z',
    ),
    _fill(PaintKey.kraft, _cone),
    _fill(PaintKey.pencil, _tip),
    const FillPart(ArtColour.wash(PaintKey.tangerine), strip),
  ];
  final lines = [
    _outline(sides, switch (t) {
      MascotTier.m => 1.05,
      MascotTier.s => 1.15,
      MascotTier.u => 1.3,
    }),
    mascotLine('M7.4 47.4 L57.4 46 L58.4 58.6 L8.2 60.2 Z', 0.85),
  ];
  if (t == MascotTier.u) return [...fills, ...lines];
  return [
    ...fills,
    if (blush != false)
      _fill(
        PaintKey.bubblegum,
        '${mascotOval(19.8, 42.4, 3.4, 2.1, -4)} ${mascotOval(45.2, 42, 3.4, 2.1, 3)}',
      ),
    ...lines,
    mascotLine(mascotScallop, switch (t) {
      MascotTier.s => 1,
      _ => 0.85,
    }),
  ];
}
