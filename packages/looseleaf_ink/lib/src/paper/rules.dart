import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';

/// Printed rules on a sheet.
///
/// Mirrors `RuleName` in `src/lib/ink/paper/stocks.ts`.
enum RuleName {
  none('none'),
  ruled('ruled'),
  ruledHand('ruled-hand'),
  indexCard('index'),
  graph('graph'),
  dots('dots'),
  ledger('ledger'),
  pad('pad'),
  window('window');

  const RuleName(this.id);

  /// The upstream name, e.g. `ruled-hand`.
  final String id;
}

/// CSS declarations by camel-cased property name, in insertion order.
///
/// Mirrors `CssDecls` in `src/lib/ink/paper/stocks.ts`.
typedef CssDecls = Map<String, String>;

/// The CSS variable that shifts rules to the text baseline
/// (`RULE_OFFSET_VAR`).
const String ruleOffsetVar = '--ll-rule-offset';

/// Kevin Sans' baseline as a fraction of the font size (`KALAM_BASELINE`).
const double kalamBaseline = 0.266;

/// How far rules of [pitch] sit above a [fs] px text baseline.
///
/// Mirrors `ruleOffsetFor` in `src/lib/ink/paper/stocks.ts`.
double ruleOffsetFor(double pitch, [double fs = 17]) =>
    JsMath.round(pitch / 2 - kalamBaseline * fs - 1.95);

/// Where a sheet's rules fall.
///
/// Mirrors `RuleGeometry` in `src/lib/ink/paper/stocks.ts`.
final class RuleGeometry {
  /// Rule geometry.
  const RuleGeometry({
    required this.kind,
    required this.pitch,
    required this.first,
    required this.offset,
    this.margin,
    this.major,
    this.cols,
  });

  /// The rules.
  final RuleName kind;

  /// Line spacing.
  final double pitch;

  /// The first line, from the top.
  final double first;

  /// The baseline offset ([ruleOffsetFor]), 0 for grids.
  final double offset;

  /// The red margin line, from the left.
  final double? margin;

  /// The major grid spacing.
  final double? major;

  /// Ledger columns: quantity from the left, total from the right.
  final (double, double)? cols;
}

/// The geometry of [kind] rules; [calm] tightens them, [first] moves the
/// first line.
///
/// Mirrors `ruleGeometry` in `src/lib/ink/paper/stocks.ts`.
RuleGeometry ruleGeometry(RuleName kind, {bool calm = false, double? first}) {
  switch (kind) {
    case RuleName.ruled || RuleName.ruledHand:
      final pitch = switch (calm) {
        true => 24.0,
        false => 28.0,
      };
      return RuleGeometry(
        kind: kind,
        pitch: pitch,
        first: first ?? 16 + pitch,
        offset: ruleOffsetFor(pitch),
        margin: switch (calm) {
          true => null,
          false => 44,
        },
      );
    case RuleName.pad:
      return RuleGeometry(
        kind: kind,
        pitch: 30,
        first: first ?? 40,
        offset: ruleOffsetFor(30),
      );
    case RuleName.indexCard:
      return RuleGeometry(
        kind: kind,
        pitch: 30,
        first: first ?? 49,
        offset: ruleOffsetFor(30),
      );
    case RuleName.graph:
      return RuleGeometry(
        kind: kind,
        pitch: 16,
        first: 0,
        offset: 0,
        major: 64,
      );
    case RuleName.dots:
      return RuleGeometry(
        kind: kind,
        pitch: 20,
        first: 10,
        offset: 0,
        major: 100,
      );
    case RuleName.ledger:
      final pitch = switch (calm) {
        true => 22.0,
        false => 24.0,
      };
      return RuleGeometry(
        kind: kind,
        pitch: pitch,
        first: 40,
        offset: ruleOffsetFor(pitch, 15),
        cols: (54, 70),
      );
    case RuleName.window:
      return RuleGeometry(kind: kind, pitch: 0, first: 0, offset: 0);
    case RuleName.none:
      return const RuleGeometry(
        kind: RuleName.none,
        pitch: 0,
        first: 0,
        offset: 0,
      );
  }
}

/// The CSS that prints a sheet's rules, with their pitch and geometry.
///
/// Mirrors `RulesLayer` in `src/lib/ink/paper/stocks.ts`.
final class RulesLayer {
  /// A rules layer.
  const RulesLayer({
    required this.style,
    required this.pitch,
    required this.geo,
  });

  /// The CSS declarations.
  final CssDecls style;

  /// Line spacing.
  final double pitch;

  /// The geometry.
  final RuleGeometry geo;
}

final class _BgLayer {
  const _BgLayer(
    this.image,
    this.size, {
    this.position,
    this.repeat,
    this.clip,
  });

  final String image;
  final String size;
  final String? position;
  final String? repeat;
  final String? clip;
}

CssDecls _layersToDecls(List<_BgLayer> layers) {
  String join(String Function(_BgLayer) f) => layers.map(f).join(', ');
  return {
    'backgroundImage': join((l) => l.image),
    'backgroundSize': join((l) => l.size),
    'backgroundPosition': join((l) => l.position ?? '0 0'),
    'backgroundRepeat': join((l) => l.repeat ?? 'repeat'),
    'backgroundOrigin': join((l) => 'border-box'),
    'backgroundClip': join((l) => l.clip ?? 'border-box'),
  };
}

String _s(double v) => JsMath.numberToString(v);

String _up(double y, RuleGeometry geo) {
  if (geo.offset == 0) return '${_s(y)}px';
  return 'calc(${_s(y)}px - var($ruleOffsetVar, ${_s(geo.offset)}px))';
}

String _upClamped(double y, RuleGeometry geo) {
  if (geo.offset == 0) return '${_s(y)}px';
  return 'max(0px, ${_up(y, geo)})';
}

String _soft(String token, int pct) =>
    'color-mix(in srgb, var(--ll-$token) $pct%, transparent)';

String _hline(String color, [double w = 0.9]) =>
    'linear-gradient(to bottom, transparent calc(100% - ${_s(w)}px), $color calc(100% - ${_s(w)}px))';

String _vline(
  String color,
  double x, [
  double w = 1.2,
  bool fromRight = false,
]) {
  String at(double v) => switch (fromRight) {
    true => 'calc(100% - ${_s(x - v)}px)',
    false => '${_s(x + v)}px',
  };
  return 'linear-gradient(to right, transparent ${at(-w / 2)}, $color ${at(-w / 2)} ${at(w / 2)}, transparent ${at(w / 2)})';
}

const String _drift =
    'linear-gradient(90deg, rgb(0 0 0 / .86), rgb(0 0 0) 19%, rgb(0 0 0 / .8) 47%, rgb(0 0 0 / .96) 71%, rgb(0 0 0 / .84))';

/// The CSS rules layer of [kind], or null for `none` and `ruled-hand`
/// (drawn as ink instead).
///
/// Mirrors `rulesLayer` in `src/lib/ink/paper/stocks.ts`.
RulesLayer? rulesLayer(RuleName kind, {bool calm = false, double? first}) {
  if (kind == RuleName.none || kind == RuleName.ruledHand) return null;
  final geo = ruleGeometry(kind, calm: calm, first: first);
  CssDecls withMask(CssDecls style) {
    if (calm) return style;
    return {...style, 'maskImage': _drift, 'WebkitMaskImage': _drift};
  }

  switch (kind) {
    case RuleName.window:
      return RulesLayer(
        pitch: 0,
        geo: geo,
        style: {
          'inset': '10px 10px 26%',
          'backgroundColor': _soft('paper-shade', 55),
          'boxShadow':
              'inset 0 2px 4px rgb(var(--ll-shade) / calc(0.26 * var(--ll-shadow-k))), inset 0 0 0 1px rgb(var(--ll-shade) / calc(0.1 * var(--ll-shadow-k)))',
        },
      );
    case RuleName.ruled || RuleName.pad || RuleName.indexCard:
      return _lined(kind, geo, withMask);
    case RuleName.graph:
      final fine = _soft('check-rule', 46);
      final bold = _soft('check-rule', 72);
      return RulesLayer(
        pitch: 16,
        geo: geo,
        style: withMask(
          _layersToDecls([
            _BgLayer(
              'linear-gradient(to right, $bold 1px, transparent 1px)',
              '64px 64px',
              position: '0 0',
            ),
            _BgLayer(
              'linear-gradient(to bottom, $bold 1px, transparent 1px)',
              '64px 64px',
              position: '0 0',
            ),
            _BgLayer(
              'linear-gradient(to right, $fine 1px, transparent 1px)',
              '16px 16px',
              position: '0 0',
            ),
            _BgLayer(
              'linear-gradient(to bottom, $fine 1px, transparent 1px)',
              '16px 16px',
              position: '0 0',
            ),
          ]),
        ),
      );
    case RuleName.dots:
      final dot =
          'radial-gradient(circle at center, ${_soft('pencil-mark', 90)} 0 .8px, transparent 1.15px)';
      final big =
          'radial-gradient(circle at center, ${_soft('pencil', 70)} 0 1.05px, transparent 1.5px)';
      return RulesLayer(
        pitch: 20,
        geo: geo,
        style: _layersToDecls([
          _BgLayer(big, '100px 100px', position: '10px 10px'),
          _BgLayer(dot, '20px 20px', position: '10px 10px'),
        ]),
      );
    default:
      return _ledger(geo, withMask);
  }
}

RulesLayer _lined(
  RuleName kind,
  RuleGeometry geo,
  CssDecls Function(CssDecls) withMask,
) {
  final pitch = geo.pitch;
  final first = geo.first;
  final isPad = kind == RuleName.pad;
  final isIndex = kind == RuleName.indexCard;
  final rule = switch (isPad) {
    true => _soft('pad-rule', 100),
    false => _soft('rule-blue', 82),
  };
  final red = _soft('rule-red', 88);
  final layers = <_BgLayer>[];
  if (geo.margin case final margin?) {
    layers.add(_BgLayer(_vline(red, margin), '100% 100%', repeat: 'no-repeat'));
  }
  if (isIndex) {
    layers.add(
      _BgLayer(
        _hline(red, 1.2),
        '100% ${_up(first + 1, geo)}',
        repeat: 'no-repeat',
      ),
    );
  }
  final blueFirst = switch (isIndex) {
    true => first + pitch,
    false => first,
  };
  layers.add(
    _BgLayer(
      _hline(rule),
      '100% ${_s(pitch)}px',
      position: '0 ${_up(blueFirst - pitch + 1, geo)}',
      repeat: 'repeat-y',
      clip: 'content-box',
    ),
  );
  final padTop = math.max(
    0.0,
    switch (isIndex) {
      true => first + 2,
      false => blueFirst - 1,
    },
  );
  return RulesLayer(
    pitch: pitch,
    geo: geo,
    style: withMask({
      ..._layersToDecls(layers),
      'paddingTop': _upClamped(padTop, geo),
    }),
  );
}

RulesLayer _ledger(RuleGeometry geo, CssDecls Function(CssDecls) withMask) {
  final pitch = geo.pitch;
  final line = _soft('check-rule', 62);
  final strong = _soft('check-rule', 100);
  final (qty, total) = geo.cols ?? (0.0, 0.0);
  return RulesLayer(
    pitch: pitch,
    geo: geo,
    style: withMask({
      ..._layersToDecls([
        _BgLayer(_vline(strong, qty, 1), '100% 100%', repeat: 'no-repeat'),
        _BgLayer(
          _vline(strong, total, 1, true),
          '100% 100%',
          repeat: 'no-repeat',
        ),
        _BgLayer(
          _hline(strong, 1.1),
          '100% ${_up(40, geo)}',
          position: '0 0',
          repeat: 'no-repeat',
        ),
        _BgLayer(
          _hline(line),
          '100% ${_s(pitch)}px',
          position: '0 ${_up(40 - pitch + 1, geo)}',
          repeat: 'repeat-y',
          clip: 'content-box',
        ),
      ]),
      'paddingTop': _upClamped(40, geo),
    }),
  );
}
