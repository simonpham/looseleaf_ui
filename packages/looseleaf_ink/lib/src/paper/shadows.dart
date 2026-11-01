import 'dart:math' as math;

import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/paper/js_asin.dart';

/// A sheet's drop shadow.
///
/// Mirrors `SheetShadowKind` in `src/lib/ink/paper/shadows.ts`.
enum SheetShadowKind {
  hair,
  loose,
  lift,
  slip,
  card,
  pad,
  check,
  paper,
  sticky,
}

/// One shadow layer: offset, blur, spread and alpha.
typedef ShadowLayer = ({double dy, double blur, double spread, double a});

/// The layers of each shadow, nearest first.
///
/// Mirrors `SHADOW_LAYERS` in `src/lib/ink/paper/shadows.ts`.
const Map<SheetShadowKind, List<ShadowLayer>> shadowLayers = {
  SheetShadowKind.hair: [(dy: 1, blur: 1.5, spread: 0, a: 0.16)],
  SheetShadowKind.loose: [
    (dy: 1, blur: 2, spread: 0, a: 0.12),
    (dy: 6, blur: 16, spread: -2, a: 0.12),
  ],
  SheetShadowKind.lift: [
    (dy: 1, blur: 1.5, spread: 0, a: 0.2),
    (dy: 7, blur: 16, spread: -4, a: 0.2),
  ],
  SheetShadowKind.slip: [
    (dy: 1, blur: 1, spread: 0, a: 0.2),
    (dy: 4, blur: 8, spread: -3, a: 0.2),
  ],
  SheetShadowKind.card: [
    (dy: 1, blur: 1.5, spread: 0, a: 0.2),
    (dy: 6, blur: 11, spread: -5, a: 0.24),
  ],
  SheetShadowKind.pad: [
    (dy: 1, blur: 1.5, spread: 0, a: 0.18),
    (dy: 10, blur: 20, spread: -8, a: 0.22),
  ],
  SheetShadowKind.check: [
    (dy: 1, blur: 1.5, spread: 0, a: 0.22),
    (dy: 6, blur: 12, spread: -5, a: 0.24),
  ],
  SheetShadowKind.paper: [
    (dy: 1, blur: 1.5, spread: 0, a: 0.2),
    (dy: 2, blur: 5, spread: -1, a: 0.1),
    (dy: 12, blur: 22, spread: -8, a: 0.2),
  ],
  SheetShadowKind.sticky: [
    (dy: 1, blur: 1, spread: 0, a: 0.2),
    (dy: 9, blur: 10, spread: -7, a: 0.34),
  ],
};

String _umber(double a) =>
    'rgb(var(--ll-shade) / calc(${JsMath.numberToString(a)} * var(--ll-shadow-k)))';

String _px(double v) {
  if (v == 0) return '0';
  return '${JsMath.numberToString(JsMath.round(v * 100) / 100)}px';
}

/// The CSS `box-shadow` of [kind] raised by [lift]; at lift 1 the theme
/// variable `var(--ll-shadow-<kind>)`.
///
/// Mirrors `sheetShadow` in `src/lib/ink/paper/shadows.ts`.
String sheetShadow([
  SheetShadowKind kind = SheetShadowKind.paper,
  double lift = 1,
]) {
  if (lift == 1) return 'var(--ll-shadow-${kind.name})';
  final layers = shadowLayers[kind] ?? const [];
  final out = <String>[];
  for (final (i, l) in layers.indexed) {
    final far = i > 0 || layers.length == 1;
    final k = switch (far) {
      true => lift,
      false => math.min(1.0, 0.4 + lift * 0.6),
    };
    final spreadK = switch (far) {
      true => lift,
      false => 1.0,
    };
    final alphaK = switch (far) {
      true => math.min(1.35, 0.5 + lift * 0.5),
      false => 1.0,
    };
    out.add(
      '0 ${_px(l.dy * k)} ${_px(l.blur * k)} ${_px(l.spread * spreadK)} '
      '${_umber(math.min(0.6, l.a * alphaK))}',
    );
  }
  return out.join(', ');
}

const double _contactBlur = 2;

/// The tight contact layer of [kind] (blur at most 2 px), or null.
///
/// Mirrors `contactShadow` in `src/lib/ink/paper/shadows.ts`.
({double dy, double a})? contactShadow(SheetShadowKind kind) {
  final layers = shadowLayers[kind] ?? const [];
  if (layers.isEmpty || layers.first.blur > _contactBlur) return null;
  return (dy: layers.first.dy, a: layers.first.a);
}

/// The soft layers of [kind] as a CSS `box-shadow` ([all] keeps the
/// contact layer too), or `none`.
///
/// Mirrors `farShadow` in `src/lib/ink/paper/shadows.ts`.
String farShadow(SheetShadowKind kind, [bool all = false]) {
  final far = [
    for (final l in shadowLayers[kind] ?? const <ShadowLayer>[])
      if (all || l.blur > _contactBlur) l,
  ];
  if (far.isEmpty) return 'none';
  return far
      .map(
        (l) => '0 ${_px(l.dy)} ${_px(l.blur)} ${_px(l.spread)} ${_umber(l.a)}',
      )
      .join(', ');
}

/// What a CSS `drop-shadow` filter is cast by.
///
/// Mirrors `DropKind` in `src/lib/ink/paper/shadows.ts`.
enum DropKind { sheet, sticker, tape, prop }

List<(double, double, double)> _drop(DropKind kind) => switch (kind) {
  DropKind.sheet => const [(1, 0.75, 0.22), (8, 8, 0.14)],
  DropKind.sticker => const [(1, 0.6, 0.26), (3, 3, 0.14)],
  DropKind.tape => const [(0.6, 0.8, 0.18)],
  DropKind.prop => const [(1, 0.8, 0.3), (3, 2.4, 0.16)],
};

/// A CSS `filter` of `drop-shadow`s for [kind] raised by [lift].
///
/// Mirrors `dropShadow` in `src/lib/ink/paper/shadows.ts`.
String dropShadow([DropKind kind = DropKind.sheet, double lift = 1]) {
  if (lift == 1 && (kind == DropKind.sheet || kind == DropKind.sticker)) {
    return 'var(--ll-drop-${kind.name})';
  }
  return _drop(kind)
      .map(
        (d) =>
            'drop-shadow(0 ${_px(d.$1 * lift)} ${_px(d.$2 * lift)} '
            '${_umber(math.min(0.5, d.$3))})',
      )
      .join(' ');
}

String _seedText(Object seed) => switch (seed) {
  final num v => JsMath.numberToString(v),
  _ => seed.toString(),
};

/// A seeded resting tilt in degrees, up to [max] either way.
///
/// Mirrors `tiltFor` in `src/lib/ink/paper/shadows.ts`.
double tiltFor(Object seed, [double max = 0.6]) {
  final r = Rng('tilt:${_seedText(seed)}');
  final sign = r.sign();
  return JsMath.round(sign * max * (0.25 + 0.75 * r()) * 100) / 100;
}

/// The largest tilt (degrees, to 0.05) that moves a [w]×[h] sheet's
/// corners at most [shift] px, capped at [cap].
///
/// Mirrors `tiltLimit` in `src/lib/ink/paper/shadows.ts`.
double tiltLimit(double w, double h, [double shift = 5, double cap = 2]) {
  final l = math.max(math.max(w, h), 1.0);
  final deg = (jsAsin(math.min(1.0, (2 * shift) / l)) * 180) / JsMath.pi;
  return math.min(cap, math.max(0.05, JsMath.round(deg * 20) / 20));
}

/// The `--ll-tilt` CSS variable for [deg].
///
/// Mirrors `tiltVars` in `src/lib/ink/paper/shadows.ts`.
Map<String, String> tiltVars(double deg) => {
  '--ll-tilt': '${JsMath.numberToString(deg)}deg',
};

/// Seeded tile offsets (px, at most one tile back) for tiles of [sizes].
List<(int, int)> tileOffsetList(Object seed, List<(double, double)> sizes) {
  final r = Rng('tex:${_seedText(seed)}');
  return [
    for (final (w, h) in sizes) (-(r() * w).floor(), -(r() * h).floor()),
  ];
}

/// [tileOffsetList] as a CSS `background-position` list.
///
/// Mirrors `tileOffsets` in `src/lib/ink/paper/shadows.ts`.
String tileOffsets(Object seed, List<(double, double)> sizes) =>
    tileOffsetList(seed, sizes).map((o) => '${o.$1}px ${o.$2}px').join(', ');
