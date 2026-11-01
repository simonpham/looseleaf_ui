import 'package:looseleaf_ink/src/core/core.dart';

/// A theme paint token, drawn as `var(--ll-<id>)`.
///
/// Mirrors `PaintKey` in `src/lib/ink/paint.ts`.
enum PaintKey {
  ink('ink'),
  inkSoft('ink-soft'),
  inkYou('ink-you'),
  pencil('pencil'),
  pencilMark('pencil-mark'),
  red('red'),
  green('green'),
  marker('marker'),
  hi('hi'),
  focus('focus'),
  paper('paper'),
  paperShade('paper-shade'),
  slip('slip'),
  card('card'),
  graph('graph'),
  kraft('kraft'),
  check('check'),
  photo('photo'),
  desk('desk'),
  deskDeep('desk-deep'),
  ruleBlue('rule-blue'),
  ruleRed('rule-red'),
  pad('pad'),
  padRule('pad-rule'),
  checkRule('check-rule'),
  inkMuted('ink-muted'),
  pencilText('pencil-text'),
  orangeText('orange-text'),
  hiDeep('hi-deep'),
  tape('tape'),
  tapeEdge('tape-edge'),
  tomato('tomato'),
  tangerine('tangerine'),
  lemon('lemon'),
  grass('grass'),
  teal('teal'),
  sky('sky'),
  grape('grape'),
  bubblegum('bubblegum'),
  stickyYellow('sticky-yellow'),
  stickyGreen('sticky-green'),
  stickyOrange('sticky-orange'),
  stickyPink('sticky-pink'),
  stickyBlue('sticky-blue'),
  current('current');

  const PaintKey(this.id);

  /// The upstream key, e.g. `ink-soft`.
  final String id;

  /// The key with this [id], or null.
  static PaintKey? byId(String id) {
    for (final key in values) {
      if (key.id == id) return key;
    }
    return null;
  }
}

/// The blend mode variable used on marker and highlighter groups.
const String blend = 'var(--ll-blend)';

/// The CSS paint for [key]: `var(--ll-<id>)`, or `currentColor`.
String paint(PaintKey key) => switch (key) {
  PaintKey.current => 'currentColor',
  _ => 'var(--ll-${key.id})',
};

/// Formats [k] units of `1/q` as the shortest decimal (`q` is 10, 20 or 100).
///
/// Mirrors `fmtUnits` in `src/lib/ink/paint.ts`.
String fmtUnits(int k, int q) {
  if (k == 0) return '0';
  final neg = k < 0;
  final a = k.abs();
  final whole = a ~/ q;
  final frac = a - whole * q;
  var s = switch (whole) {
    0 => '',
    _ => '$whole',
  };
  if (frac != 0) {
    final digits = switch (q) {
      10 => 1,
      _ => 2,
    };
    final scale = switch (digits) {
      1 => 10 ~/ q,
      _ => 100 ~/ q,
    };
    final f = '${frac * scale}'
        .padLeft(digits, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    s += '.$f';
  }
  if (neg) return '-$s';
  return s;
}

/// Rounds [v] to `1/q` and formats it (`n` upstream).
String n(double v, [int q = 20]) {
  if (!v.isFinite) return '0';
  return fmtUnits(JsMath.roundInt(v * q), q);
}

/// Escapes text for SVG attributes and content.
String esc(String s) => s.replaceAllMapped(RegExp('[&<>"\']'), (match) {
  return switch (match[0]) {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    _ => '&#39;',
  };
});
