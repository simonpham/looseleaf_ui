import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

InkSource _source(LineParams line) => InkSource.callback(
  id: 'line',
  paramsKey: '${line.toJson()}',
  draw: (request) => const InkMarkup(parts: {'rest': ''}, pad: 0),
);

List<InkMarkSurface> _surfaces(WidgetTester tester) =>
    tester.widgetList<InkMarkSurface>(find.byType(InkMarkSurface)).toList();

void main() {
  test('mergeLineRects joins boxes on one line and drops slivers', () {
    final merged = mergeLineRects(const [
      Rect.fromLTWH(0, 0, 40, 20),
      Rect.fromLTWH(40, 1, 30, 19),
      Rect.fromLTWH(0, 24, 50, 20),
      Rect.fromLTWH(60, 24, 0.2, 20),
    ]);
    expect(merged, const [
      Rect.fromLTWH(0, 0, 70, 20),
      Rect.fromLTWH(0, 24, 50, 20),
    ]);
  });

  testWidgets('draws one mark per wrapped line, seeded per line', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 120,
          child: InkMark(
            source: _source,
            seed: 's',
            child: Text('one two three four five six seven eight'),
          ),
        ),
      ),
    );
    await tester.pump();
    final surfaces = _surfaces(tester);
    expect(surfaces.length, greaterThan(1));
    expect(surfaces.map((s) => s.seed), [
      for (var i = 0; i < surfaces.length; i++) 's:$i',
    ]);
    final first = tester.getRect(find.byType(InkMarkSurface).first);
    final second = tester.getRect(find.byType(InkMarkSurface).at(1));
    expect(second.top, greaterThan(first.bottom - 1));
  });

  testWidgets('box draws one mark around every line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 120,
          child: InkMark(
            source: _source,
            seed: 's',
            box: true,
            child: Text('one two three four five six seven eight'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(_surfaces(tester), hasLength(1));
  });

  testWidgets('show false draws nothing and keeps the text', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const InkMark(
          source: _source,
          seed: 's',
          show: false,
          child: Text('hidden mark'),
        ),
      ),
    );
    await tester.pump();
    expect(_surfaces(tester), isEmpty);
    expect(find.text('hidden mark'), findsOneWidget);
  });

  testWidgets('animate holds each line back by its stagger', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 120,
          child: InkMark(
            source: _source,
            seed: 's',
            animate: true,
            delay: Duration(milliseconds: 100),
            child: Text('one two three four five six seven eight'),
          ),
        ),
      ),
    );
    await tester.pump();
    final delays = _surfaces(tester).map((s) => s.delay).toList();
    expect(delays.first, const Duration(milliseconds: 100));
    expect(delays[1], const Duration(milliseconds: 480));
    Visibility visibilityOf(int index) => tester.widget<Visibility>(
      find
          .descendant(
            of: find.byType(InkMarkSurface).at(index),
            matching: find.byType(Visibility),
          )
          .first,
    );
    expect(visibilityOf(0).visible, isFalse);
    await tester.pump(const Duration(milliseconds: 150));
    expect(visibilityOf(0).visible, isTrue);
    expect(visibilityOf(1).visible, isFalse);
    await tester.pumpAndSettle();
    expect(visibilityOf(1).visible, isTrue);
  });

  testWidgets('reduced motion shows the mark at once', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const InkMark(
          source: _source,
          seed: 's',
          animate: true,
          delay: Duration(seconds: 1),
          child: Text('reduced'),
        ),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    await tester.pump();
    final visibility = tester.widget<Visibility>(
      find
          .descendant(
            of: find.byType(InkMarkSurface),
            matching: find.byType(Visibility),
          )
          .first,
    );
    expect(visibility.visible, isTrue);
  });

  testWidgets('the mark is left out of semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const InkMark(source: _source, seed: 's', child: Text('words')),
      ),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('words'), findsOneWidget);
    handle.dispose();
  });
}
