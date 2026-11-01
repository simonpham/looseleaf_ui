import 'package:looseleaf_ink/src/art/art.dart';
import 'package:test/test.dart';

Object? _hand(Hand? h) => switch (h) {
  final Hand hand => [hand.start?.name, hand.end?.name, hand.taper],
  null => null,
};

List<Object?> _part(ArtPart p) => switch (p) {
  FillPart(:final colour, :final d, :final mis) => ['f', colour.id, d, mis],
  StrokePart(:final d, :final width, :final hand) => [
    's',
    d,
    width,
    _hand(hand),
  ],
  ColourStrokePart(:final colour, :final d, :final width, :final hand) => [
    'c',
    colour.id,
    d,
    width,
    _hand(hand),
  ],
  DotPart(:final x, :final y, :final r) => ['d', x, y, r],
  HighlightPart(:final d, :final width) => ['h', d, width],
  TextPart(
    :final text,
    :final x,
    :final y,
    :final size,
    :final colour,
    :final font,
  ) =>
    ['t', text, x, y, size, colour?.id, font?.name],
};

List<Object?>? _parts(List<ArtPart>? parts) => parts?.map(_part).toList();

Map<String, Object?> _def(ArtDef d) => {
  'grid': [d.grid.w, d.grid.h, d.grid.pair],
  'parts': _parts(d.parts),
  'small': _parts(d.small),
  'micro': _parts(d.micro),
  'hi': _parts(d.hi),
  'accent': d.accent?.name,
  'nibK': d.nibK,
  'tags': d.tags,
  'shade': d.shade,
  'tilt': d.tilt,
  'kind': d.kind?.name,
};

void main() {
  test('pose() rebuilds every catalog pose', () {
    final built = buildMascotPoses();
    expect(built.keys, mascotPoses.keys);
    for (final MapEntry(:key, :value) in mascotPoses.entries) {
      final def = built[key];
      if (def == null) fail('no pose $key');
      expect(_def(def), _def(value), reason: key);
    }
  });

  test('the frame builders rebuild every catalog frame', () {
    final built = buildMascotFrames();
    expect(built.keys, mascotFrames.keys);
    for (final MapEntry(:key, :value) in mascotFrames.entries) {
      final def = built[key];
      if (def == null) fail('no frame $key');
      expect(_def(def), _def(value), reason: key);
    }
  });

  test('a new pose draws', () {
    final def = pose(
      PoseSpec(
        face: const Face(eyes: EyeKind.x, mouth: MouthKind.gritted),
        turn: const Xf(rot: 12),
        acc: stopSign,
      ),
    );
    expect(drawMascot(def, 96, 'new').svg, isNotEmpty);
    expect(validateArt(def), isEmpty);
  });
}
