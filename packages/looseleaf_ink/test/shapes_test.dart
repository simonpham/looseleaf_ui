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

T? _enum<T extends Enum>(List<T> values, Object? name) => switch (name) {
  final String n => values.byName(n),
  _ => null,
};

StrokeOpts? _opts(Object? v) => switch (v) {
  final Map<String, dynamic> o => StrokeOpts(
    tier: _enum(Tier.values, o['tier']),
    wobble: _od(o['wobble']),
    speed: _od(o['speed']),
    start: _enum(StrokeStart.values, o['start']),
    end: _enum(StrokeEnd.values, o['end']),
    width: _od(o['width']),
    alpha: _od(o['alpha']),
    color: switch (o['color']) {
      final String c => PaintKey.byId(c),
      _ => null,
    },
    poly: o['poly'] as bool?,
    round: _od(o['round']),
    raw: o['raw'] as bool?,
    dry: _od(o['dry']),
    simple: o['simple'] as bool?,
  ),
  _ => null,
};

PenName? _pen(Object? v) => switch (v) {
  final String id => PenName.byId(id),
  _ => null,
};

Map<String, Object?> _optsJson(StrokeOpts o) => {
  'tier': ?o.tier?.name,
  'wobble': ?o.wobble,
  'speed': ?o.speed,
  'start': ?o.start?.name,
  'end': ?o.end?.name,
  'width': ?o.width,
  'alpha': ?o.alpha,
  'color': ?o.color?.id,
  'poly': ?o.poly,
  'round': ?o.round,
  'raw': ?o.raw,
  'dry': ?o.dry,
  'simple': ?o.simple,
};

List<Map<String, Object?>> _linesJson(List<Line> lines) => [
  for (final l in lines)
    {
      'pts': [
        for (final (x, y) in l.pts) [x, y],
      ],
      'o': switch (l.o) {
        final StrokeOpts o => _optsJson(o),
        null => null,
      },
      'pen': switch (l.pen) {
        final PenName p => p.id,
        _ => null,
      },
    },
];

List<Line> _lines(
  String fn,
  Rng rng,
  List<dynamic> a,
  Map<String, dynamic> o,
) => switch (fn) {
  'chain' => [
    Line(
      chain(_pts(a[0]), [for (final b in a[1] as List) _d(b)], _d(a[2]), rng),
    ),
  ],
  'lineLines' => lineLines(_d(a[0]), _d(a[1]), _d(a[2]), _d(a[3])),
  'squiggleLines' => squiggleLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    h: _od(o['h']),
    amp: _od(o['amp']),
    wl: _od(o['wl']),
  ),
  'underlineLines' => underlineLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    kind: _enum(UnderlineKind.values, o['kind']),
  ),
  'strikeLines' => strikeLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    doubled: o['double'] == true,
  ),
  'boxLines' => boxLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    corner: _od(o['corner']),
    loose: _od(o['loose']),
    wobble: _od(o['wobble']),
  ),
  'loopLines' => loopLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    turns: _od(o['turns']),
    a0: _od(o['a0']),
    drift: _od(o['drift']),
    breathe: _od(o['breathe']),
    loose: _od(o['loose']),
    clean: o['clean'] == true,
  ),
  'arrowLines' => arrowLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    head: _enum(ArrowHead.values, o['head']),
    curl: o['curl'] == true,
    curve: _od(o['curve']),
    headLen: _od(o['headLen']),
  ),
  'checkLines' => checkLines(rng, _d(a[0]), _d(a[1]), _d(a[2])),
  'crossLines' => crossLines(rng, _d(a[0]), _d(a[1]), _d(a[2])),
  'asteriskLines' => asteriskLines(rng, _d(a[0]), _d(a[1]), _d(a[2])),
  'spiralLines' => spiralLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    turns: _od(o['turns']),
    steps: _oi(o['steps']),
    shrink: _od(o['shrink']),
  ),
  'starLines' => starLines(rng, _d(a[0]), _d(a[1]), _d(a[2])),
  'tallyLines' => tallyLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    (a[2] as num).toInt(),
    _d(a[3]),
  ).lines,
  'bracketLines' => bracketLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    kind: _enum(BracketKind.values, o['kind']),
    dir: _oi(o['dir']),
  ),
  'cloudLines' => cloudLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    bulge: _od(o['bulge']),
  ),
  'scribbleLines' => scribbleLines(rng, _d(a[0]), _d(a[1]), _d(a[2]), _d(a[3])),
  'burstLines' => burstLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    rays: _oi(o['rays']),
  ),
  'focusRingLines' => focusRingLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    shape: _enum(FocusShape.values, o['shape']),
    gap: _od(o['gap']),
    r: _od(o['r']),
    ticks: o['ticks'] == true,
  ),
  'dashedBoxLines' => dashedBoxLines(
    rng,
    _d(a[0]),
    _d(a[1]),
    _d(a[2]),
    _d(a[3]),
    r: _od(o['r']),
    dash: _od(o['dash']),
    gap: _od(o['gap']),
  ),
  _ => throw UnimplementedError(fn),
};

void _draw(Ink ink, String call, List<dynamic> a, Map<String, dynamic> o) {
  final pen = _pen(o['pen']);
  final opts = _opts(o['opts']);
  switch (call) {
    case 'line':
      line(ink, _d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), pen: pen, opts: opts);
    case 'squiggle':
      squiggle(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        h: _od(o['h']),
      );
    case 'underline':
      underline(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        kind: _enum(UnderlineKind.values, o['kind']),
      );
    case 'strike':
      strike(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        doubled: o['double'] == true,
      );
    case 'box':
      box(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
        corner: _od(o['corner']),
        loose: _od(o['loose']),
      );
    case 'loop':
      loop(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
        clean: o['clean'] == true,
      );
    case 'arrow':
      arrow(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
        head: _enum(ArrowHead.values, o['head']),
        curl: o['curl'] == true,
      );
    case 'check':
      check(ink, _d(a[0]), _d(a[1]), _d(a[2]), pen: pen, opts: opts);
    case 'cross':
      cross(ink, _d(a[0]), _d(a[1]), _d(a[2]), pen: pen, opts: opts);
    case 'asterisk':
      asterisk(ink, _d(a[0]), _d(a[1]), _d(a[2]), pen: pen, opts: opts);
    case 'spiral':
      spiral(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        turns: _od(o['turns']),
      );
    case 'star':
      star(ink, _d(a[0]), _d(a[1]), _d(a[2]), pen: pen, opts: opts);
    case 'tally':
      tally(
        ink,
        _d(a[0]),
        _d(a[1]),
        (a[2] as num).toInt(),
        _d(a[3]),
        pen: pen,
        opts: opts,
      );
    case 'bracket':
      bracket(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        kind: _enum(BracketKind.values, o['kind']),
      );
    case 'cloud':
      cloud(ink, _d(a[0]), _d(a[1]), _d(a[2]), _d(a[3]), pen: pen, opts: opts);
    case 'scribble':
      scribble(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
      );
    case 'burst':
      burst(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        pen: pen,
        opts: opts,
        rays: _oi(o['rays']),
      );
    case 'focusRing':
      focusRing(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
        shape: _enum(FocusShape.values, o['shape']),
        r: _od(o['r']),
        ticks: o['ticks'] == true,
      );
    case 'dashedBox':
      dashedBox(
        ink,
        _d(a[0]),
        _d(a[1]),
        _d(a[2]),
        _d(a[3]),
        pen: pen,
        opts: opts,
        r: _od(o['r']),
      );
    default:
      throw UnimplementedError(call);
  }
}

void main() {
  final fixture = _fixture('shapes');

  group('lines', () {
    for (final (i, c)
        in (fixture['lines'] as List).cast<Map<String, dynamic>>().indexed) {
      test('#$i ${c['fn']} ${c['seed']}', () {
        final fn = c['fn'] as String;
        final args = c['args'] as List<dynamic>;
        final o = c['o'] as Map<String, dynamic>;
        expect(
          _linesJson(_lines(fn, Rng(c['seed'] as String), args, o)),
          c['out'],
        );
        if (fn == 'tallyLines') {
          final t = tallyLines(
            Rng(c['seed'] as String),
            _d(args[0]),
            _d(args[1]),
            (args[2] as num).toInt(),
            _d(args[3]),
          );
          expect(t.width, c['width']);
        }
      });
    }
  });

  group('markup', () {
    for (final (i, c)
        in (fixture['draws'] as List).cast<Map<String, dynamic>>().indexed) {
      test('#$i ${c['name']}', () {
        final ink = Ink(
          c['seed'] as String,
          tier: Tier.values.byName(c['tier'] as String),
        );
        _draw(
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
        expect(res.layers.map((l) => l.name), out['layers']);
      });
    }
  });
}
