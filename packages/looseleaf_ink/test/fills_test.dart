import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num n => n.toDouble(),
  _ => null,
};

int? _oi(Object? v) => switch (v) {
  final num n => n.toInt(),
  _ => null,
};

List<Pt> _pts(Object? v) => [
  for (final p in v as List) (_d((p as List)[0]), _d(p[1])),
];

List<List<double>> _out(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

PaintKey _paint(Object? v) =>
    PaintKey.byId(v as String) ?? (throw ArgumentError('paint $v'));

Material? _material(Object? v) => switch (v) {
  final String m => Material.values.byName(m),
  _ => null,
};

PenName? _pen(Object? v) => switch (v) {
  final String id => PenName.byId(id),
  _ => null,
};

void main() {
  final fixture = _fixture('fills');
  final polys = {
    for (final MapEntry(:key, :value)
        in (fixture['polys'] as Map<String, dynamic>).entries)
      key: _pts(value),
  };

  List<Pt> poly(Object? v) {
    final s = v as String;
    if (s.startsWith('rect:')) {
      final [x, y, w, h] = [
        for (final p in s.substring(5).split(',')) double.parse(p),
      ];
      return rectRegion(x, y, w, h);
    }
    return polys[s] ?? (throw ArgumentError('poly $s'));
  }

  InkOffset? draw(
    Ink ink,
    String call,
    List<dynamic> a,
    Map<String, dynamic> o,
  ) {
    final alpha = _od(o['alpha']);
    final material = _material(o['material']);
    switch (call) {
      case 'solidFill':
        return solidFill(
          ink,
          poly(a[0]),
          _paint(a[1]),
          alpha: alpha,
          inset: _od(o['inset']),
          rough: _od(o['rough']),
          material: material,
        );
      case 'flatFill':
        flatFill(
          ink,
          poly(a[0]),
          _paint(a[1]),
          _od(a.elementAtOrNull(2)) ?? 0.5,
          _material(a.elementAtOrNull(3)) ?? Material.marker,
        );
        return null;
      case 'bandFill':
        return bandFill(
          ink,
          poly(a[0]),
          _paint(a[1]),
          alpha: alpha,
          passes: _oi(o['passes']),
          material: material,
        );
      case 'clipFill':
        return clipFill(
          ink,
          poly(a[0]),
          _paint(a[1]),
          alpha: alpha,
          rough: _od(o['rough']),
          material: material,
        );
      case 'blobFill':
        return blobFill(
          ink,
          poly(a[0]),
          _paint(a[1]),
          alpha: alpha,
          rough: _od(o['rough']),
          material: material,
        );
      case 'wash':
        return wash(
          ink,
          poly(a[0]),
          _paint(a[1]),
          alpha: alpha,
          inset: _od(o['inset']),
          shift: _od(o['shift']),
          wobble: _od(o['wobble']),
          material: material,
        );
      case 'polyFill':
        return polyFill(ink, poly(a[0]), _paint(a[1]), alpha: alpha);
      case 'sweepFill':
        sweepFill(
          ink,
          _d(a[0]),
          _d(a[1]),
          _d(a[2]),
          _d(a[3]),
          _paint(a[4]),
          alpha: alpha,
        );
        return null;
      case 'hatch':
        final cross = o['cross'];
        hatch(
          ink,
          poly(a[0]),
          angle: _od(o['angle']),
          gap: _od(o['gap']),
          cross: cross == true,
          crossAngle: _od(cross),
          tones: _oi(o['tones']),
          skip: _od(o['skip']),
          pen: _pen(o['pen']),
          alpha: alpha,
          width: _od(o['width']),
        );
        return null;
      case 'edgeBand':
        edgeBand(
          ink,
          _d(a[0]),
          _d(a[1]),
          _d(a[2]),
          _d(a[3]),
          EdgeSide.values.byName(a[4] as String),
          thick: _od(o['thick']),
          gap: _od(o['gap']),
          inset: _od(o['inset']),
          pen: _pen(o['pen']),
          alpha: alpha,
          width: _od(o['width']),
        );
        return null;
      case 'stipple':
        stipple(
          ink,
          _d(a[0]),
          _d(a[1]),
          _d(a[2]),
          _d(a[3]),
          (a[4] as num).toInt(),
          pen: _pen(o['pen']),
          alpha: alpha,
        );
        return null;
      case 'contourArcs':
        contourArcs(
          ink,
          _d(a[0]),
          _d(a[1]),
          _d(a[2]),
          _d(a[3]),
          n: _oi(o['n']),
          dir: _oi(o['dir']),
          alpha: alpha,
        );
        return null;
      case 'highlight':
        final opts = switch (o['opts']) {
          final Map<String, dynamic> m => StrokeOpts(
            end: switch (m['end']) {
              final String e => StrokeEnd.values.byName(e),
              _ => null,
            },
            width: _od(m['width']),
          ),
          _ => null,
        };
        highlight(
          ink,
          _d(a[0]),
          _d(a[1]),
          _d(a[2]),
          _d(a[3]),
          k: _od(o['k']),
          pen: _pen(o['pen']),
          opts: opts,
        );
        return null;
      default:
        throw UnimplementedError(call);
    }
  }

  group('markup', () {
    for (final (i, c)
        in (fixture['draws'] as List).cast<Map<String, dynamic>>().indexed) {
      test('#$i ${c['name']}', () {
        final ink = Ink(
          c['seed'] as String,
          tier: Tier.values.byName(c['tier'] as String),
        );
        final offset = draw(
          ink,
          c['call'] as String,
          c['args'] as List<dynamic>,
          c['o'] as Map<String, dynamic>,
        );
        final res = ink.toSvg(w: _d(c['w']), h: _d(c['h']));
        final out = c['out'] as Map<String, dynamic>;
        expect(res.svg, out['svg']);
        expect(res.pad, out['pad']);
        expect(res.bbox.toList(), out['bbox']);
        if (c['offset'] case final Map<String, dynamic> want) {
          expect([offset?.dx, offset?.dy], [want['dx'], want['dy']]);
        }
      });
    }
  });

  test('misreg', () {
    final body = polys['body'] ?? const [];
    for (final c
        in (fixture['misc']['misreg'] as List).cast<Map<String, dynamic>>()) {
      final o = c['o'] as Map<String, dynamic>;
      final out = misreg(
        body,
        Rng(c['seed'] as String),
        amt: _d(c['amt']),
        bias: _od(o['bias']),
        tilt: _od(o['tilt']),
        grow: _od(o['grow']),
      );
      expect(_out(out), c['out']);
    }
  });

  test('defaultMis', () {
    expect([
      for (final k in ['body', 'tri', 'disc']) defaultMis(polys[k] ?? const []),
    ], fixture['misc']['defaultMis']);
  });

  test('rough', () {
    for (final c
        in (fixture['misc']['rough'] as List).cast<Map<String, dynamic>>()) {
      expect(
        _out(
          rough(
            polys['tri'] ?? const [],
            Rng(c['seed'] as String),
            _d(c['amt']),
            _d(c['step']),
          ),
        ),
        c['out'],
      );
    }
  });

  test('bandPoly', () {
    for (final c
        in (fixture['misc']['bandPoly'] as List).cast<Map<String, dynamic>>()) {
      final out = bandPoly(
        (3, 4),
        (180, 30),
        _d(c['width']),
        Rng(c['seed'] as String),
        _d(c['chisel']),
        (c['maxPts'] as num).toInt(),
      );
      expect(_out(out), c['out']);
    }
  });
}
