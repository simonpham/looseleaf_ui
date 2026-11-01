import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

int _i(Object? v) => (v as num).toInt();

Pt _pt(Object? v) => switch (v) {
  [final x, final y] => (_d(x), _d(y)),
  _ => throw ArgumentError('not a point: $v'),
};

List<Pt> _pts(Object? v) => [for (final p in v as List) _pt(p)];

List<List<double>> _out(List<Pt> pts) => [
  for (final (x, y) in pts) [x, y],
];

Tier _tier(Object? v) => Tier.values.byName(v as String);

Map<String, Object> _resample(List<dynamic> a) {
  final r = resample(_pts(a[0]), _d(a[1]));
  return {'X': r.x, 'Y': r.y, 'S': r.s, 'L': r.length};
}

List<List<double>> _xform(List<dynamic> a) {
  final o = a[1] as Map<String, dynamic>;
  return _out(
    xform(
      _pts(a[0]),
      dx: _d(o['dx'] ?? 0),
      dy: _d(o['dy'] ?? 0),
      rot: _d(o['rot'] ?? 0),
      sx: _d(o['sx'] ?? 1),
      sy: switch (o['sy']) {
        final num v => v.toDouble(),
        _ => null,
      },
      about: switch (o['about']) {
        final List<dynamic> p => _pt(p),
        _ => null,
      },
    ),
  );
}

List<Map<String, Object>> _scanSpans(List<dynamic> a) {
  final o = a[4] as Map<String, dynamic>;
  final spans = scanSpans(
    _pts(a[0]),
    _d(a[1]),
    _d(a[2]),
    Rng(a[3] as String),
    jitter: _d(o['jitter'] ?? 0.12),
    inset: _d(o['inset'] ?? 0),
    even: o['even'] as bool? ?? true,
  );
  return [
    for (final s in spans)
      {
        'row': s.row,
        'a': [s.a.x, s.a.y],
        'b': [s.b.x, s.b.y],
        'len': s.len,
      },
  ];
}

Object? _run(String fn, List<dynamic> a) => switch (fn) {
  'seg' => _out(
    seg(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), _d(a[4]), _i(a[5])),
  ),
  'densify' => _out(densify(_pts(a[0]), _d(a[1]))),
  'spline' => _out(spline(_pts(a[0]), _d(a[1]))),
  'fillet' => _out(fillet(_pts(a[0]), _d(a[1]))),
  'rounded' => _out(
    rounded(_pts(a[0]), _d(a[1]), Rng(a[2] as String), _i(a[3])),
  ),
  'pathLength' => pathLength(_pts(a[0])),
  'resample' => _resample(a),
  'simplifyClosed' => _out(simplifyClosed(_pts(a[0]), _d(a[1]))),
  'smoothClosed' => smoothClosed(_pts(a[0]), tierCfg(_tier(a[1]))),
  'simplePath' => simplePath(_pts(a[0]), tierCfg(_tier(a[1]))),
  'polyPath' => polyPath(_pts(a[0]), _i(a[1])),
  'area' => area(_pts(a[0])),
  'bboxOf' => bboxOf(_pts(a[0])).toList(),
  'centroid' => [centroid(_pts(a[0])).x, centroid(_pts(a[0])).y],
  'inside' => inside(_pts(a[0]), _d(a[1]), _d(a[2])),
  'xform' => _xform(a),
  'roundRectPoly' => _out(
    roundRectPoly(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), _d(a[4]), _i(a[5])),
  ),
  'pillPoly' => _out(
    pillPoly(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), _i(a[4])),
  ),
  'ellipsePoly' => _out(
    ellipsePoly(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), _i(a[4]), _d(a[5])),
  ),
  'densifyClosed' => _out(densifyClosed(_pts(a[0]), _d(a[1]))),
  'wobblePoly' => _out(
    wobblePoly(_pts(a[0]), Rng(a[1] as String), _d(a[2]), _d(a[3])),
  ),
  'offsetPoly' => _out(offsetPoly(_pts(a[0]), _d(a[1]), _d(a[2]), _d(a[3]))),
  'scanSpans' => _scanSpans(a),
  'pathWriter' =>
    (PathWriter(20)
          ..m(1.234, -5.5)
          ..l(1.25, -5.5)
          ..l(0.4, 0.45)
          ..quad(3, 3, -2.05, 7.5)
          ..z()
          ..m(10, 10)
          ..l(10.05, 10.1)
          ..z())
        .d,
  _ => throw UnimplementedError(fn),
};

void main() {
  final cases = (_fixture('geom')['cases'] as List)
      .cast<Map<String, dynamic>>();
  for (final (i, c) in cases.indexed) {
    test('${c['fn']} #$i', () {
      expect(_run(c['fn'] as String, c['args'] as List<dynamic>), c['out']);
    });
  }
}
