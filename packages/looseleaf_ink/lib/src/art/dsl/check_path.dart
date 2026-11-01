import 'dart:math' as math;

import 'package:looseleaf_ink/src/art/dsl/path_parser.dart';
import 'package:looseleaf_ink/src/core/core.dart';

/// What [checkPath] found in one art path.
///
/// Mirrors `PathCheck` in `src/lib/ink/art/dsl.ts`.
final class PathCheck {
  /// A check result.
  const PathCheck({
    required this.errors,
    required this.warnings,
    required this.bbox,
    required this.strokes,
  });

  /// Grammar errors.
  final List<String> errors;

  /// Style warnings.
  final List<String> warnings;

  /// The extent of the outline, or null when the path has errors.
  final BBox? bbox;

  /// How many strokes the path draws.
  final int strokes;
}

final RegExp _threeDecimals = RegExp(r'\.\d{3,}');
final RegExp _wholeNumber = RegExp(r'^-?\d+$');

/// Checks the grammar of an art path (`M L l Q C O E Z` and numbers) and
/// warns about computer-looking coordinates; returns the outline extent.
///
/// Mirrors `checkPath` in `src/lib/ink/art/dsl.ts`.
PathCheck checkPath(String d) {
  final errors = <String>[];
  final warnings = <String>[];
  if (d.trim().isEmpty) {
    return const PathCheck(
      errors: ['empty path'],
      warnings: [],
      bbox: null,
      strokes: 0,
    );
  }
  final (:tok, :bad) = tokenize(d);
  if (bad.isNotEmpty) {
    final shown = bad.substring(0, math.min(12, bad.length));
    errors.add(
      'illegal characters "$shown" (grammar: M L l Q C O E Z, numbers)',
    );
  }
  var i = 0;
  var open = false;
  var count = 0;
  int numsAfter() {
    var k = 0;
    while (i + k < tok.length && !isArtCommand(tok[i + k])) {
      k++;
    }
    return k;
  }

  if (tok.isNotEmpty && !{'M', 'O', 'E'}.contains(tok[0])) {
    errors.add('path must start with M, O or E, not "${tok[0]}"');
  }
  double nf(String s) => double.tryParse(s) ?? double.nan;
  var curLen = 0;
  while (i < tok.length) {
    final c = tok[i++];
    if (!isArtCommand(c)) {
      errors.add('number "$c" without a command');
      continue;
    }
    final k = numsAfter();
    switch (c) {
      case 'M':
        if (k < 2 || k.isOdd) errors.add('M needs pairs of numbers (got $k)');
        open = true;
        count++;
        curLen = k ~/ 2;
        i += k;
      case 'L' || 'l':
        if (!open) errors.add('$c before M');
        if (k < 2 || k.isOdd) errors.add('$c needs pairs of numbers (got $k)');
        curLen += k ~/ 2;
        i += k;
      case 'Q':
        if (!open) errors.add('Q before M');
        if (k < 4 || k % 4 != 0) {
          errors.add('Q needs groups of 4 numbers (got $k)');
        }
        curLen += k ~/ 4;
        i += k;
      case 'C':
        if (!open) errors.add('C before M');
        if (k < 6 || k % 6 != 0) {
          errors.add('C needs groups of 6 numbers (got $k)');
        }
        curLen += k ~/ 6;
        i += k;
      case 'O':
        final counted = k == 3 || k == 4;
        if (!counted) errors.add('O needs cx cy rx [ry] (got $k numbers)');
        final radiiBad =
            counted && (nf(tok[i + 2]) <= 0 || (k == 4 && nf(tok[i + 3]) <= 0));
        if (radiiBad) errors.add('O radii must be positive');
        open = false;
        count++;
        i += k;
      case 'E':
        if (k != 6) errors.add('E needs cx cy rx ry a0 a1 (got $k numbers)');
        if (k == 6 && (nf(tok[i + 2]) <= 0 || nf(tok[i + 3]) <= 0)) {
          errors.add('E radii must be positive');
        }
        if (!open) count++;
        open = true;
        i += k;
      case 'Z':
        if (!open || curLen < 3) {
          errors.add('Z closes a stroke of at least 3 points');
        }
        if (k != 0) errors.add('Z takes no numbers');
        open = false;
    }
  }
  if (errors.isNotEmpty) {
    return PathCheck(
      errors: errors,
      warnings: warnings,
      bbox: null,
      strokes: count,
    );
  }
  for (final s in parsePath(d)) {
    if (s.closed || s.pts.length < 4) continue;
    final a = s.pts[0], b = s.pts[s.pts.length - 1];
    if (JsMath.hypot(a.x - b.x, a.y - b.y) < 0.35) {
      warnings.add(
        'the stroke ends exactly where it began: close it with Z (the pen '
        'overshoots) or stop short',
      );
    }
  }
  final nums = [
    for (final t in tok)
      if (!isArtCommand(t)) t,
  ];
  final dec = nums.where(_threeDecimals.hasMatch).length;
  if (dec > 0) {
    warnings.add(
      '$dec coordinates have 3+ decimals (write one decimal: the engine adds '
      'the wobble)',
    );
  }
  final whole = nums.where(_wholeNumber.hasMatch).length;
  if (nums.length >= 8 && whole / nums.length > 0.7) {
    warnings.add(
      'most coordinates are whole numbers: a tidy grid reads as '
      'computer-drawn (use 12.2, 11.8...)',
    );
  }
  BBox? bbox;
  for (final s in parsePath(d, step: 0.4)) {
    for (var k = 0; k < s.shape; k++) {
      final (x, y) = s.pts[k];
      final box = bbox ?? BBox(x, y, x, y);
      bbox = BBox(
        math.min(box.x0, x),
        math.min(box.y0, y),
        math.max(box.x1, x),
        math.max(box.y1, y),
      );
    }
  }
  return PathCheck(
    errors: errors,
    warnings: warnings,
    bbox: bbox,
    strokes: count,
  );
}
