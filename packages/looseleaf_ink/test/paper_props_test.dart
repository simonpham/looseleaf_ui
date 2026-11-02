import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

final Map<String, dynamic> _fx =
    jsonDecode(
          File('test/fixtures/paper_props.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

Tier? _tier(Object? v) => switch (v) {
  final String t => Tier.values.byName(t),
  _ => null,
};

Accent? _accent(Object? v) => switch (v) {
  final String a when a != 'steel' => Accent.values.byName(a),
  _ => null,
};

PaintKey? _paint(Object? v) => switch (v) {
  final String id => PaintKey.byId(id),
  _ => null,
};

InkResult _run(
  String fn,
  String seed,
  List<dynamic> a,
  Map<String, dynamic> o,
) {
  final tier = _tier(o['tier']);
  final calm = o['calm'] as bool?;
  return switch (fn) {
    'tape' => tape(
      seed,
      tier: tier,
      calm: calm,
      kind: switch (o['kind']) {
        final String k => TapeKind.values.firstWhere((t) => t.id == k),
        _ => TapeKind.masking,
      },
      length: _od(o['length']) ?? 72,
      height: _od(o['height']) ?? 22,
      ends: switch (o['ends']) {
        final String e => TapeEnds.values.byName(e),
        _ => null,
      },
      color: _accent(o['color']),
    ),
    'clip' => paperClip(
      seed,
      tier: tier,
      calm: calm,
      height: _od(o['height']) ?? 64,
      tone: _accent(o['tone']),
      angle: _od(o['angle']),
    ),
    'pin' => pushPin(
      seed,
      tier: tier,
      calm: calm,
      size: _od(o['size']) ?? 24,
      color: _accent(o['color']) ?? Accent.tomato,
    ),
    'staple' => staple(
      seed,
      tier: tier,
      calm: calm,
      length: _od(o['length']) ?? 20,
      doubled: o['double'] == true,
    ),
    'binderClip' => binderClip(
      seed,
      tier: tier,
      calm: calm,
      width: _od(o['width']) ?? 52,
    ),
    'stitches' => stitches(
      seed,
      _d(a[0]),
      _d(a[1]),
      tier: tier,
      calm: calm,
      inset: _od(o['inset']) ?? 8,
      radius: _od(o['radius']) ?? 6,
      color: _paint(o['color']) ?? PaintKey.marker,
      stitch: _od(o['stitch']) ?? 7,
      gap: _od(o['gap']) ?? 4,
    ),
    'rubberBand' => rubberBand(
      seed,
      _d(a[0]),
      _d(a[1]),
      tier: tier,
      calm: calm,
      color: _accent(o['color']) ?? Accent.tangerine,
    ),
    'coffeeRing' => coffeeRing(
      seed,
      tier: tier,
      calm: calm,
      radius: _od(o['radius']) ?? 48,
    ),
    'stickyCurl' => stickyCurl(
      seed,
      _d(a[0]),
      tier: tier,
      calm: calm,
      color: _paint(o['color']) ?? PaintKey.stickyYellow,
    ),
    'ruler' => rulerProp(
      seed,
      _d(a[0]),
      tier: tier,
      calm: calm,
      height: _od(o['height']) ?? 30,
    ),
    _ => throw UnimplementedError(fn),
  };
}

void main() {
  for (final c in (_fx['cases'] as List).cast<Map<String, dynamic>>()) {
    test('${c['fn']} ${c['seed']} ${c['o']}', () {
      final res = _run(
        c['fn'] as String,
        c['seed'] as String,
        c['args'] as List<dynamic>,
        c['o'] as Map<String, dynamic>,
      );
      final out = c['out'] as Map<String, dynamic>;
      expect(res.svg, out['svg']);
      expect([res.w, res.h, res.pad], [out['w'], out['h'], out['pad']]);
    });
  }
  test('curlMarkup', () {
    final c = _fx['curl'] as Map<String, dynamic>;
    expect(
      curlMarkup(
        Rng(c['seed'] as String),
        c['id'] as String,
        _d(c['c']),
        PaintKey.stickyGreen,
      ),
      c['out'],
    );
  });
}
