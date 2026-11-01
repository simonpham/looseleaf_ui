import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// `var(--ll-<name>)`.
String tok(String name) => 'var(--ll-$name)';

/// A number on the 0.1 px grid.
String num10(double v) => n(v, 10);

/// A plain JS number, `String(v)`.
String js(num v) => JsMath.numberToString(v);

/// A `<path>` with [fill] (or `none`), an optional round-joined [stroke]
/// of width [sw], opacity [op] (written below 0.995 on the stroke or the
/// fill), a [transform] and [extra] attributes.
///
/// Mirrors `pathTag` in `src/lib/ink/paper/props.ts`.
String pathTag(
  String d, {
  String? fill,
  String? stroke,
  double? sw,
  double? op,
  String? transform,
  String cap = 'round',
  String? extra,
}) {
  final s = StringBuffer('<path d="$d"');
  s.write(switch (fill) {
    final String f when f.isNotEmpty => ' fill="$f"',
    _ => ' fill="none"',
  });
  final stroked = stroke != null && stroke.isNotEmpty;
  if (stroked) {
    s.write(
      ' stroke="$stroke" stroke-width="${n(sw ?? 1)}" stroke-linecap="$cap" stroke-linejoin="round"',
    );
  }
  if (op case final o? when o < 0.995) {
    final filled = fill != null && fill.isNotEmpty;
    final target = switch (stroked && !filled) {
      true => 'stroke',
      false => 'fill',
    };
    s.write(' $target-opacity="${n(o, 100)}"');
  }
  if (transform case final t? when t.isNotEmpty) s.write(' transform="$t"');
  if (extra case final e? when e.isNotEmpty) s.write(' $e');
  s.write('/>');
  return s.toString();
}

/// An open (or [close]d) polyline path on the 0.1 px grid.
String polyD(List<Pt> pts, [bool close = false]) {
  final body = pts.map((p) => '${num10(p.x)} ${num10(p.y)}').join('L');
  return switch (close) {
    true => 'M${body}Z',
    false => 'M$body',
  };
}

/// A circle as two arcs.
String circleD(double cx, double cy, double r) =>
    'M${num10(cx - r)} ${num10(cy)}a${num10(r)} ${num10(r)} 0 1 0 ${num10(2 * r)} 0a${num10(r)} ${num10(r)} 0 1 0 ${num10(-2 * r)} 0z';

/// A new [Ink] for a prop.
Ink propInk(Object seed, Tier? tier, bool? calm) =>
    Ink(seed, tier: tier, calm: calm);

/// The ink seed in base 36, for ids.
String seedTag(Ink ink) => ink.seed.toRadixString(36);
