import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

T _by<T extends Enum>(List<T> values, Object? id, [String Function(T)? key]) =>
    values.firstWhere((v) => (key?.call(v) ?? v.name) == id);

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

final class _Entry<P> {
  _Entry(this.recipe, this.decode, this.json);

  final Recipe<P> recipe;
  final P Function(_Json p) decode;
  final Map<String, Object?> Function(P p) json;

  (RawFrame, String) run(_Json c) {
    final params = decode(c['params'] as _Json);
    final knobs = c['knobs'] as _Json;
    final frame = runRecipe(
      recipe,
      RunRequest<P>(
        box: Box(_d(c['w']), _d(c['h'])),
        params: params,
        seed: c['seed'] as String,
        tier: Tier.values.byName(c['tier'] as String),
        density: Density.values.byName(c['density'] as String),
        dir: Dir.values.byName(c['dir'] as String),
        knobs: Knobs(
          wobble: _d(knobs['wobble']),
          misreg: _d(knobs['misreg']),
          bleed: _d(knobs['bleed']),
          width: _d(knobs['width']),
        ),
        lazy: _layers(c['lazy']),
        lazyOnly: c['lazyOnly'] == true,
        pad: _od(c['pad']),
      ),
    );
    return (frame, stableStringify(json(params)));
  }
}

PaintKey _paint(Object? v) => _by(PaintKey.values, v, (k) => k.id);

final Map<String, _Entry<Object?>> _entries = {
  'polaroid-photo': _Entry<PolaroidPhotoParams>(
    polaroidPhotoRecipe,
    (p) => PolaroidPhotoParams(scene: _by(PolaroidScene.values, p['scene'])),
    (p) => p.toJson(),
  ),
  'rating': _Entry<RatingParams>(
    ratingRecipe,
    (p) => RatingParams(
      icon: switch (p['icon']) {
        final String id => _by(RatingIcon.values, id),
        _ => null,
      },
      disabled: p['disabled'] as bool?,
      invalid: p['invalid'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'receipt-circle': _Entry<ReceiptCircleParams>(
    receiptCircleRecipe,
    (p) => ReceiptCircleParams(pen: _by(ReceiptPen.values, p['pen'])),
    (p) => p.toJson(),
  ),
  'reveal-nib': _Entry<RevealNibParams>(
    revealNibRecipe,
    (p) => RevealNibParams(
      color: switch (p['color']) {
        final String id => _paint(id),
        _ => null,
      },
    ),
    (p) => p.toJson(),
  ),
  'ribbon': _Entry<RibbonParams>(
    ribbonRecipe,
    (p) => RibbonParams(
      variant: _by(RibbonVariant.values, p['variant']),
      tone: _by(RibbonTone.values, p['tone']),
      size: _by(RibbonSize.values, p['size'], (s) => s.id),
      hoverable: p['hoverable'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'stamp-button': _Entry<StampButtonParams>(
    stampButtonRecipe,
    (p) => StampButtonParams(
      ink: _by(StampButtonInk.values, p['ink'], (i) => i.id),
      disabled: p['disabled'] as bool?,
    ),
    (p) => p.toJson(),
  ),
};

List<List<double>> _pts(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

List<List<double>> _expectPts(Object? v) => [
  for (final p in v as List) [for (final c in p as List) _d(c)],
];

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/marks_scenes.json').readAsStringSync(),
          )
          as _Json;
  group('frames', () {
    for (final c in (fixture['frames'] as List).cast<_Json>()) {
      test(c['name'], () {
        final entry = _entries[c['recipe']];
        if (entry == null) fail('no entry for ${c['recipe']}');
        final (frame, key) = entry.run(c);
        final out = c['out'] as _Json;
        expect(key, c['key']);
        expect(frame.layers.map((l) => l.name), out['layers']);
        expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
        expect(
          [frame.pad, frame.w, frame.h],
          [out['pad'], out['w'], out['h']],
        );
        final parts = out['parts'] as _Json;
        expect(frame.parts.keys.map((k) => k.name), parts.keys);
        for (final MapEntry(:key, :value) in parts.entries) {
          expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
        }
      });
    }
  });

  test('confetti colours', () {
    expect(
      ConfettiColor.values.map((c) => c.paint.id),
      fixture['colors'] as List,
    );
  });

  group('confetti pieces', () {
    for (final c in (fixture['pieces'] as List).cast<_Json>()) {
      test('${c['kind']} ${c['color']} ${c['variant']}', () {
        final piece = confettiPiece(
          _by(ConfettiKind.values, c['kind']),
          _paint(c['color']),
          c['variant'] as int,
        );
        final out = c['out'] as _Json;
        expect(piece.svg, out['svg']);
        expect([piece.w, piece.h], [out['w'], out['h']]);
        expect(
          identical(
            piece,
            confettiPiece(
              _by(ConfettiKind.values, c['kind']),
              _paint(c['color']),
              c['variant'] as int,
            ),
          ),
          isTrue,
        );
      });
    }
  });

  group('flights', () {
    for (final (i, c) in (fixture['flights'] as List).cast<_Json>().indexed) {
      test('flight $i', () {
        final o = c['o'] as _Json;
        final opts = FlightOptions(
          count: o['count'] as int,
          spread: _d(o['spread']),
          angle: _d(o['angle']),
          velocity: _d(o['velocity']),
          gravity: _d(o['gravity']),
          drift: _d(o['drift']),
          duration: _d(o['duration']),
          seed: o['seed'] as num,
        );
        final flights = switch (c['kinds']) {
          final List kinds => simulate(
            opts,
            [for (final k in kinds) _by(ConfettiKind.values, k)],
            [
              for (final k in c['colors'] as List) _by(ConfettiColor.values, k),
            ],
          ),
          _ => simulate(opts),
        };
        final out = (c['out'] as List).cast<_Json>();
        expect(flights.length, out.length);
        for (final (j, f) in flights.indexed) {
          final want = out[j];
          expect(
            [f.kind.name, f.color.name, f.variant, f.scale],
            [want['kind'], want['color'], want['variant'], want['scale']],
          );
          final frames = (want['frames'] as List).cast<_Json>();
          expect(f.frames.length, frames.length);
          for (final (k, fr) in f.frames.indexed) {
            final w = frames[k];
            expect(
              [fr.x, fr.y, fr.rot, fr.flip, fr.opacity],
              [
                _d(w['x']),
                _d(w['y']),
                _d(w['rot']),
                _d(w['flip']),
                _d(w['opacity']),
              ],
              reason: 'piece $j frame $k',
            );
          }
        }
      });
    }
  });

  group('barcodes', () {
    for (final c in (fixture['barcodes'] as List).cast<_Json>()) {
      test('"${c['value']}"', () {
        final code = barcode(c['value'] as String, _d(c['w']), _d(c['h']));
        final out = c['out'] as _Json;
        expect(code.d, out['d']);
        expect(
          [
            for (final (x, w) in code.bars) [x, w],
          ],
          _expectPts(out['bars']),
        );
      });
    }
  });

  group('crescents', () {
    for (final (i, c) in (fixture['crescents'] as List).cast<_Json>().indexed) {
      test('crescent $i', () {
        final a = [for (final v in c['args'] as List) _d(v)];
        final pts = crescent(a[0], a[1], a[2], a[3], a[4], a[5], a[6].toInt());
        expect(_pts(pts), _expectPts(c['out']));
      });
    }
  });
}
