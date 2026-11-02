import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

final _Json _fx =
    jsonDecode(
          File('test/fixtures/marks_composers.json').readAsStringSync(),
        )
        as _Json;

List<_Json> _list(Object? v) => (v as List).cast<_Json>();

double _num(Object? v) => switch (v) {
  final num x => x.toDouble(),
  'NaN' => double.nan,
  'Infinity' => double.infinity,
  '-Infinity' => double.negativeInfinity,
  _ => throw ArgumentError('not a number: $v'),
};

double? _od(Object? v) => (v as num?)?.toDouble();

String _tile(String name) => '{tile:$name}';

SketchStroke _stroke(_Json s) => SketchStroke(
  id: s['id'] as String,
  tool: DrawTool.values.byName(s['tool'] as String),
  color: SketchColor.values.firstWhere((c) => c.id == s['color']),
  size: _num(s['size']),
  pts: [
    for (final p in (s['pts'] as List).cast<List>())
      (
        _num(p[0]),
        _num(p[1]),
        switch (p.length) {
          3 => _num(p[2]),
          _ => null,
        },
      ),
  ],
);

String? _resolveVar(String name) => switch (name) {
  '--ll-ink' => '#222',
  '--ll-hi' => '',
  _ => null,
};

final RegExp _llVar = RegExp(r'var\(--ll-[a-z-]+\)');

String _resolveSvg(String svg) => svg.replaceAll(_llVar, '#000');

void main() {
  final strokes = {
    for (final s in _list(_fx['strokes'])) s['id'] as String: _stroke(s),
  };

  group('strokesToSvg', () {
    for (final c in _list(_fx['sketch'])) {
      test(c['tag'], () {
        clearStrokeCache();
        final o = c['o'] as _Json;
        final svg = strokesToSvg(
          [
            for (final id in c['ids'] as List)
              strokes[id] ?? (throw StateError('no stroke $id')),
          ],
          _tile,
          width: _num(o['width']),
          height: _num(o['height']),
          tier: switch (o['tier']) {
            final String t => Tier.values.byName(t),
            _ => null,
          },
          background: o['background'] as String?,
          resolve: switch (o['resolve']) {
            true => _resolveVar,
            _ => null,
          },
          margin: _od(o['margin']),
          title: o['title'] as String?,
        );
        expect(svg, c['out']);
      });
    }
  });

  group('composeBoardSvg', () {
    for (final c in _list(_fx['board'])) {
      test(c['tag'], () {
        final o = c['o'] as _Json;
        final items = [
          for (final s in _list(c['items']))
            StickerBoardItem(
              id: s['id'] as String,
              name: s['name'] as String,
              x: _num(s['x']),
              y: _num(s['y']),
              rot: _num(s['rot']),
              scale: _num(s['scale']),
              z: _num(s['z']),
            ),
        ];
        final width = _num(o['width']);
        final height = _num(o['height']);
        final size = _num(o['size']);
        final resolve = switch (o['resolve']) {
          true => _resolveSvg,
          _ => null,
        };
        final svg = switch (o.containsKey('background')) {
          true => composeBoardSvg(
            items,
            _tile,
            width: width,
            height: height,
            size: size,
            background: o['background'] as String?,
            resolve: resolve,
          ),
          false => composeBoardSvg(
            items,
            _tile,
            width: width,
            height: height,
            size: size,
            resolve: resolve,
          ),
        };
        expect(svg, c['out']);
      });
    }
  });
}
