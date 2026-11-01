import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

Rect bounds(String d) {
  Rect? out;
  for (final metric in PathDataParser.parse(d).computeMetrics()) {
    for (var i = 0; i <= 400; i++) {
      final tangent = metric.getTangentForOffset(metric.length * i / 400);
      if (tangent == null) continue;
      final point = Rect.fromCenter(
        center: tangent.position,
        width: 0,
        height: 0,
      );
      out = out?.expandToInclude(point) ?? point;
    }
  }
  return out ?? Rect.zero;
}

void main() {
  group('NumberScanner', () {
    List<double> numbers(String source) {
      final scan = NumberScanner(source);
      final out = <double>[];
      while (!scan.done) {
        out.add(scan.number());
      }
      return out;
    }

    test('reads the compact forms the engine writes', () {
      expect(numbers('.4-1.2'), [0.4, -1.2]);
      expect(numbers('1.5.5'), [1.5, 0.5]);
      expect(numbers('-.3-.7'), [-0.3, -0.7]);
      expect(numbers('3e2 1E-1,2'), [300, 0.1, 2]);
      expect(numbers('  7 , 8 '), [7, 8]);
    });
  });

  group('PathDataParser', () {
    test('absolute lines', () {
      expect(
        bounds('M1 2L11 2L11 12Z'),
        rectMoreOrLessEquals(const Rect.fromLTRB(1, 2, 11, 12), epsilon: 0.05),
      );
    });

    test('relative commands with compact numbers', () {
      expect(
        bounds('M10 10l.5-5l-.5 5z'),
        rectMoreOrLessEquals(
          const Rect.fromLTRB(10, 5, 10.5, 10),
          epsilon: 0.05,
        ),
      );
    });

    test('implicit repeats after M become lines', () {
      expect(
        bounds('M0 0 10 0 10 10'),
        rectMoreOrLessEquals(const Rect.fromLTRB(0, 0, 10, 10), epsilon: 0.05),
      );
      expect(
        bounds('m5 5 10 0 0 10'),
        rectMoreOrLessEquals(const Rect.fromLTRB(5, 5, 15, 15), epsilon: 0.05),
      );
    });

    test('H and V, absolute and relative', () {
      expect(
        bounds('M1 1H9V5h-4v6'),
        rectMoreOrLessEquals(const Rect.fromLTRB(1, 1, 9, 11), epsilon: 0.05),
      );
    });

    test('quadratic chains like the engine smoothing (q then implicit q)', () {
      final rect = bounds('M4.6 2.7q.4-.2 4.1-.2 3.6 0 9.6-.4');
      expect(rect.left, closeTo(4.6, 0.01));
      expect(rect.right, closeTo(18.3, 0.01));
    });

    test('cubic and smooth cubic', () {
      final rect = bounds('M0 0C0 10 10 10 10 0S20-10 20 0');
      expect(rect.left, 0);
      expect(rect.right, 20);
      expect(rect.top, closeTo(-7.5, 0.01));
      expect(rect.bottom, closeTo(7.5, 0.01));
    });

    test('smooth quadratic', () {
      final rect = bounds('M0 0Q5 10 10 0T20 0');
      expect(rect.top, closeTo(-5, 0.01));
      expect(rect.bottom, closeTo(5, 0.01));
    });

    test('arcs with compact flags, as circleD writes them', () {
      final rect = bounds('M0 10a10 10 0 1 0 20 0a10 10 0 1 0-20 0z');
      expect(rect.left, closeTo(0, 0.01));
      expect(rect.right, closeTo(20, 0.01));
      expect(rect.top, closeTo(0, 0.01));
      expect(rect.bottom, closeTo(20, 0.01));
      final compact = bounds('M0 10a10 10 0 1020 0');
      expect(compact.right, closeTo(20, 0.01));
    });

    test('Z returns to the subpath start for relative moves', () {
      expect(
        bounds('M5 5h5z m1 1h1'),
        rectMoreOrLessEquals(const Rect.fromLTRB(5, 5, 10, 6), epsilon: 0.05),
      );
    });

    test('rejects data that does not start with a command', () {
      expect(
        () => PathDataParser.parse('10 10'),
        throwsA(isA<InkMarkupError>()),
      );
      expect(
        () => PathDataParser.parse('M0 0X1'),
        throwsA(isA<InkMarkupError>()),
      );
    });
  });

  group('TransformParser', () {
    test('composes left to right', () {
      final affine = TransformParser.parse('translate(10 0) scale(2)');
      expect(affine.apply(const Offset(1, 1)), const Offset(12, 2));
    });

    test('rotate about a center', () {
      final affine = TransformParser.parse('rotate(90 5 5)');
      final point = affine.apply(const Offset(10, 5));
      expect(point.dx, closeTo(5, 1e-9));
      expect(point.dy, closeTo(10, 1e-9));
    });

    test('matrix and compact arguments', () {
      final affine = TransformParser.parse('matrix(0 -1 -1 0 169.6 169.6)');
      expect(affine.apply(Offset.zero), const Offset(169.6, 169.6));
      expect(TransformParser.parse('translate(-.4-.5)').e, -0.4);
    });
  });

  group('InkPaint', () {
    test('parses tokens, urls and colors', () {
      expect(InkPaint.parse('var(--ll-ink)'), isA<InkTokenPaint>());
      expect((InkPaint.parse('url(#ll-a)') as InkUrlPaint).id, 'll-a');
      expect(InkPaint.parse('none'), isA<InkNoPaint>());
      expect(InkPaint.parse('currentColor'), isA<InkCurrentColor>());
      expect(
        (InkPaint.parse('#abc') as InkColorPaint).color,
        const Color(0xFFAABBCC),
      );
      expect(
        (InkPaint.parse('rgb(246 244 236 / 0.5)') as InkColorPaint).color.a,
        closeTo(0.5, 1e-6),
      );
    });
  });
}
