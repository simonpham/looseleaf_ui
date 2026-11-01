import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

final List<Pt> _body = roundRectPoly(0.5, 0.5, 119, 35, 4);
const List<Pt> _curve = [(4, 30), (40, 8), (80, 28), (116, 6)];

typedef _Scenario = ({
  Ink Function(String seed) make,
  void Function(Ink ink) draw,
  List<LayerName>? layers,
  double? pad,
});

_Scenario _s(
  Ink Function(String seed) make,
  void Function(Ink ink) draw, {
  List<LayerName>? layers,
  double? pad,
}) => (make: make, draw: draw, layers: layers, pad: pad);

final Map<String, _Scenario> _scenarios = {
  'layers': _s(Ink.new, (ink) {
    box(ink, 0, 0, 120, 36);
    ink
      ..layer(LayerName.hover, () => wash(ink, _body, PaintKey.hi, alpha: 0.5))
      ..layer(LayerName.focus, () => focusRing(ink, 0, 0, 120, 36, r: 4))
      ..layer(
        LayerName.disabled,
        () => ink.poly(Material.under, _body, PaintKey.paperShade, 0.9),
      );
  }),
  'filtered': _s(
    (seed) => Ink(seed, tier: Tier.hi),
    (ink) {
      ink.layer(LayerName.hover, () => highlight(ink, 6, 8, 108, 20, k: 1));
      box(ink, 0, 0, 120, 36, pen: PenName.pencilFine);
      ink.layer(LayerName.pressed, () => box(ink, 0, 0, 120, 36));
    },
    layers: [LayerName.hover, LayerName.rest],
    pad: 7,
  ),
  'parts': _s(Ink.new, (ink) {
    ink
      ..lean()
      ..part(
        'fill',
        () => bandFill(ink, _body, PaintKey.marker, passes: 2, alpha: 0.84),
      )
      ..part(
        'fill2',
        () => wash(ink, _body, PaintKey.hi, alpha: 0.5),
        Material.marker,
      )
      ..part('swipe', () => highlight(ink, 6, 8, 108, 20, k: 1), Material.hl)
      ..part(
        'under',
        () => underline(
          ink,
          10,
          30,
          100,
          pen: PenName.blueFine,
          kind: UnderlineKind.single,
        ),
        Material.top,
      );
    box(ink, 0, 0, 120, 36);
  }),
  'leanSmall': _s((seed) => Ink(seed, tier: Tier.hi), (ink) {
    ink
      ..lean()
      ..part('fill', () => blobFill(ink, _body, PaintKey.red, alpha: 0.97));
    box(ink, 0, 0, 120, 36, pen: PenName.redfelt);
    ink
      ..stroke(_curve, PenName.pencil)
      ..stroke(_curve, PenName.mLemon);
  }),
  'groups': _s(Ink.new, (ink) {
    final clip = ink.clipDef('M0 0h120v36H0z');
    ink
      ..group(
        GroupAttrs(
          transform: 'translate(3 4)',
          opacity: 0.5,
          id: 'g<1>',
          clip: 'M0 0h60v36H0z',
          hideOn: 'hover',
          mask: 'm1',
        ),
        () {
          ink
            ..stroke(_curve, PenName.ink)
            ..flat(
              Material.marker,
              'M0 0h10v10z',
              PaintKey.marker,
              op: 0.4,
              clip: clip,
            );
        },
      )
      ..group(
        GroupAttrs(part: 'plain', vars: {'a': 1.234, 'b': -0.5}),
        () => ink.stroke(_curve, PenName.blueFine),
        Material.felt,
      )
      ..group(GroupAttrs(opacity: 1), () => ink.dot(20, 20, 3, PenName.ink));
  }),
  'defs': _s((seed) => Ink(seed, tier: Tier.hi), (ink) {
    final id = ink.define(() {
      ink
        ..stroke([(0, 0), (10, 6)], PenName.inkFine)
        ..dot(5, 5, 2, PenName.pencil);
    });
    ink
      ..use(id, x: 10, y: 0)
      ..use(id, x: 0, y: 12.35, transform: 'rotate(45)', at: Material.felt)
      ..use(ink.define(() => ink.raw('<circle r="2"/>')));
  }),
  'flats': _s(Ink.new, (ink) {
    ink
      ..flat(
        Material.felt,
        'M0 0L10 10',
        PaintKey.ink,
        op: 0.8,
        stroke: PaintKey.ink,
        sw: 1.25,
        bbox: BBox(0, 0, 10, 10),
      )
      ..flat(Material.felt, 'M2 2L12 12', PaintKey.ink, stroke: PaintKey.red)
      ..flat(
        Material.marker,
        'M0 0h5v5z',
        PaintKey.marker,
        op: 0.5,
        evenOdd: true,
      )
      ..flat(Material.marker, 'M0 0h6v6z', PaintKey.marker, op: 0.502)
      ..flat(Material.marker, 'M1 1h6v6z', PaintKey.marker, op: 0.499)
      ..flat(Material.marker, '', PaintKey.marker, op: 0.5)
      ..poly(Material.wash, [(0, 0), (1, 1)], PaintKey.hi)
      ..raw('')
      ..raw('<rect width="3" height="3"/>', Material.stamp)
      ..text(
        10,
        20,
        'Hi & <bye> "x" \'y\'',
        size: 14.5,
        fill: PaintKey.inkSoft,
        anchor: 'middle',
        weight: 600,
      )
      ..text(0, 0, 'plain')
      ..text(5, 5, 'font', size: 12, font: 'Kevin "Sans"');
  }),
  'calm': _s(
    (seed) => Ink(
      seed,
      calm: true,
      tier: Tier.hi,
      knobs: Knobs(wobble: 2, misreg: 3, bleed: 1.5, width: 1.2),
    ),
    (ink) {
      wash(ink, _body, PaintKey.marker, alpha: 0.32);
      box(ink, 0, 0, 120, 36);
      ink.dot(10, 10, 2);
    },
  ),
  'knobs': _s(
    (seed) => Ink(
      seed,
      tier: Tier.hi,
      knobs: Knobs(wobble: 0.5, misreg: 2, bleed: 1.6, width: 1.3),
    ),
    (ink) {
      wash(ink, _body, PaintKey.hi);
      ink
        ..lines(
          [
            const Line(_curve, o: StrokeOpts(width: 2, alpha: 0.5)),
            Line([for (final (x, y) in _curve) (x, y + 6)], pen: PenName.red),
          ],
          PenName.blue,
          const StrokeOpts(width: 0.5, alpha: 0.8, simple: true),
        )
        ..lines([const Line(_curve)], PenName.pencil)
        ..dot(30, 30, 3, PenName.blue, const StrokeOpts(width: 2));
    },
  ),
  'noGrain': _s((seed) => Ink(seed, grain: false, tier: Tier.hi), (ink) {
    ink.lean();
    wash(ink, _body, PaintKey.hi);
    box(ink, 0, 0, 120, 36);
    ink
      ..stroke(_curve, PenName.pencil)
      ..stroke(_curve, PenName.red)
      ..stroke(_curve, PenName.hi);
  }),
  'empty': _s(Ink.new, (_) {}),
};

void main() {
  final fixture = _fixture('builder');

  group('scenarios', () {
    final cases = (fixture['scenarios'] as List).cast<Map<String, dynamic>>();
    test(
      'covers every scenario',
      () =>
          expect(cases.map((c) => c['name']).toSet(), _scenarios.keys.toSet()),
    );
    for (final c in cases) {
      test(c['name'], () {
        final s =
            _scenarios[c['name']] ?? (throw StateError('missing ${c['name']}'));
        final ink = s.make('builder-${c['name']}');
        s.draw(ink);
        final res = ink.toSvg(w: 120, h: 36, pad: s.pad, layers: s.layers);
        expect(ink.seed, c['seed']);
        expect(ink.variant, c['variant']);
        expect(ink.tier.name, c['tier']);
        expect(ink.knobs.toJson(), c['knobs']);
        expect(res.svg, c['svg']);
        expect(res.pad, c['pad']);
        expect(res.layers.map((l) => l.name), c['layers']);
        expect({
          for (final MapEntry(:key, :value) in res.parts.entries)
            key.name: value,
        }, c['parts']);
        expect(res.bbox.toList(), c['bbox']);
        expect(inkViewBox(w: res.w, h: res.h, pad: res.pad), c['viewBox']);
      });
    }
  });

  test('masks', () {
    final masks = fixture['masks'] as Map<String, dynamic>;
    expect(maskIds, masks['ids']);
    expect([
      for (final v in [-7, -1, 0, 5, 6, 13]) maskId(GrainKind.felt, v),
    ], masks['wrapped']);
    for (final p in (masks['phases'] as List).cast<Map<String, dynamic>>()) {
      final phase = maskPhase(p['v'] as int);
      expect({'x': phase.x, 'y': phase.y, 'rot': phase.rot}, p['phase']);
      expect({'x': phase.x, 'y': phase.y, 'rot': phase.rot}, p['grain']);
    }
    expect([
      grainMaskId(GrainKind.marker),
      grainMaskId(GrainKind.waxy, variant: 8),
      grainMaskId(GrainKind.stamp, variant: -1, prefix: 'x'),
      grainMaskUrl(GrainKind.felt, variant: 2),
    ], masks['grainIds']);
    expect([
      for (final s in [0, 1, 42, 0x9e3779b9, 4294967295, 123456789])
        grainVariantFor(s),
    ], masks['variants']);
  });
}
