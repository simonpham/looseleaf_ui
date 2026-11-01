import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Iterable<Transform> _words(WidgetTester tester) => tester.widgetList<Transform>(
  find.descendant(
    of: find.byType(Handwritten),
    matching: find.byType(Transform),
  ),
);

void main() {
  test('the jitter is seeded and stays within the hand', () {
    final a = HandwrittenJitter.of('hw|s', 0, 1);
    final b = HandwrittenJitter.of('hw|s', 0, 1);
    expect(a.dy, b.dy);
    expect(a.opacity, b.opacity);
    for (var i = 0; i < 50; i++) {
      final jitter = HandwrittenJitter.of('hw|s', i, 2);
      expect(jitter.dy.abs(), lessThanOrEqualTo(1.6));
      expect(jitter.opacity, inInclusiveRange(0.76, 1));
    }
    expect(HandwrittenJitter.of('hw|s', 3, 0).dy, 0);
  });

  testWidgets('writes each word on its own, reads as one text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(Handwritten('bring the big umbrella', seed: 's')),
    );
    expect(_words(tester), hasLength(4));
    expect(find.bySemanticsLabel('bring the big umbrella'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('strength 0, calm and reduced motion write plain text', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(Handwritten('plain words', strength: 0)),
    );
    expect(_words(tester), isEmpty);
    await tester.pumpWidget(
      componentHost(
        Handwritten('plain words'),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(_words(tester), isEmpty);
    await tester.pumpWidget(
      componentHost(
        Handwritten('plain words'),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    expect(_words(tester), isEmpty);
  });

  testWidgets('widget spans in rich text are left alone', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Handwritten.rich(
          TextSpan(
            text: 'press ',
            children: [WidgetSpan(child: Text('Ctrl'))],
          ),
        ),
      ),
    );
    expect(_words(tester), hasLength(1));
    expect(find.text('Ctrl'), findsOneWidget);
  });
}
