import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  const bounds = Rect.fromLTWH(10, 0, 100, 20);

  test('a swipe part wipes in from the reading start', () {
    const half = InkStateEffects(swipe: 0.5);
    expect(half.clipFor('fill', bounds, TextDirection.ltr), isNull);
    expect(
      half.clipFor('swipe', bounds, TextDirection.ltr),
      const Rect.fromLTRB(6, -2, 62, 22),
    );
    expect(
      half.clipFor('swipe', bounds, TextDirection.rtl),
      const Rect.fromLTRB(58, -2, 114, 22),
    );
    expect(
      InkStateEffects.none.clipFor('swipe', bounds, TextDirection.ltr),
      isNull,
    );
  });

  test('a reveal part is drawn on along its length', () {
    final document = InkDocument.parseLayers({
      'checked':
          '<path data-part="reveal" d="M0 0L100 0" pathLength="1" '
          'stroke="black"/>',
    });
    final layer = document.layers['checked'];
    final node = switch (layer) {
      InkGroupNode(:final children) => children.single,
      _ => layer,
    };
    if (node is! InkShapeNode) fail('expected a shape, got $node');
    double length(Path path) => path.computeMetrics().fold(
      0.0,
      (sum, metric) => sum + metric.length,
    );
    expect(length(InkDash.revealed(node, 0)), 0);
    expect(length(InkDash.revealed(node, 0.25)), closeTo(25, 0.01));
    expect(length(InkDash.revealed(node, 1)), closeTo(100, 0.01));
  });
}
