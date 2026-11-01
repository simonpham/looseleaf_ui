import 'dart:math' as math;

import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// The pen a receipt total is circled with.
enum ReceiptPen {
  redfelt(PenName.redfelt),
  blue(PenName.blue),
  ink(PenName.ink);

  const ReceiptPen(this.pen);

  /// The pen it draws with.
  final PenName pen;
}

/// Receipt circle recipe params.
///
/// Mirrors `ReceiptCircleParams` in `src/lib/ink/recipes/receipt-ink.ts`.
final class ReceiptCircleParams {
  /// Params.
  const ReceiptCircleParams({required this.pen});

  final ReceiptPen pen;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {'pen': pen.name};
}

/// A loose loop circling a receipt total.
///
/// Mirrors `receiptCircleRecipe` in `src/lib/ink/recipes/receipt-ink.ts`.
final Recipe<ReceiptCircleParams> receiptCircleRecipe =
    defineRecipe<ReceiptCircleParams>(
      id: 'receipt-circle',
      kind: 'circle',
      layers: const [LayerName.rest],
      pad: 14,
      draw: _draw,
    );

void _draw(Ink ink, Box size, ReceiptCircleParams params, RecipeContext ctx) {
  final Box(:w, :h) = size;
  ink.layer(LayerName.rest, () {
    final rx = w / 2 + 9;
    final ry = math.max(h / 2 + 4, 12).toDouble();
    loop(
      ink,
      w / 2,
      h / 2,
      rx,
      ry,
      pen: switch (ctx.calm) {
        true => PenName.redfeltFine,
        false => params.pen.pen,
      },
      turns: 1.1,
    );
  });
}

/// A drawn barcode: its path data and its bars as `(x, width)`.
///
/// Mirrors `Barcode` in `src/lib/ink/recipes/receipt-ink.ts`.
typedef Barcode = ({String d, List<(double, double)> bars});

final RegExp _nonDigit = RegExp(r'\D');

/// A barcode for [value], [width] × [height], seeded by the value.
///
/// Mirrors `barcode` in `src/lib/ink/recipes/receipt-ink.ts`.
Barcode barcode(String value, double width, double height) {
  final rng = Rng('barcode:${hashSeed(value)}');
  final modules = <int>[1, 1, 1, 1];
  final digitsOnly = value.replaceAll(_nonDigit, '');
  final digits = switch (digitsOnly) {
    '' => value,
    _ => digitsOnly,
  };
  for (final ch in digits.runes) {
    final k = String.fromCharCode(ch).codeUnitAt(0);
    modules.addAll([
      1 + (k % 3),
      1 + ((k >> 2) % 2),
      1 + ((k >> 1) % 3),
      1 + ((k >> 3) % 2),
    ]);
    if (rng.chance(0.3)) modules.addAll([1 + rng.integer(0, 1), 1]);
  }
  modules.addAll([1, 1, 1, 1]);
  final total = modules.fold(0, (a, b) => a + b);
  final unit = width / total;
  final bars = <(double, double)>[];
  var x = 0.0;
  for (final (i, m) in modules.indexed) {
    final w = m * unit;
    if (i % 2 == 0) {
      bars.add((
        x + rng.gauss(0, unit * 0.04),
        w * (1 + rng.gauss(0, 0.03)),
      ));
    }
    x += w;
  }
  final d = StringBuffer();
  final drop = height * 0.012;
  for (final (bx, bw) in bars) {
    d.write(
      'M${n(bx)} ${n(rng.range(0, drop))}h${n(bw)}'
      'V${n(height - rng.range(0, drop))}h${n(-bw)}z',
    );
  }
  return (d: d.toString(), bars: bars);
}
