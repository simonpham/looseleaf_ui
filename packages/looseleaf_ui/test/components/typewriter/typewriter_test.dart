import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

String _typed(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: find.byType(Typewriter), matching: find.byType(Text)),
    )
    .map((text) => text.data)
    .nonNulls
    .join(' ');

void main() {
  testWidgets('types the text out, then calls onDone', (tester) async {
    var done = 0;
    await tester.pumpWidget(
      componentHost(Typewriter('Dear diary', seed: 't', onDone: () => done++)),
    );
    expect(_typed(tester), isEmpty);
    await tester.pump(const Duration(milliseconds: 500));
    expect(_typed(tester), isNotEmpty);
    expect('Dear diary'.startsWith(_typed(tester).split(' ').first), isTrue);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(_typed(tester), 'Dear diary');
    expect(done, 1);
  });

  testWidgets('reads the whole text as a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(Typewriter('Hello there')));
    expect(
      tester.getSemantics(find.byType(Typewriter)),
      matchesSemantics(label: 'Hello there', isLiveRegion: true),
    );
    await tester.pumpWidget(
      componentHost(
        const Typewriter.phrases(['one', 'two'], mode: TypingMode.cycle),
      ),
    );
    expect(
      tester.getSemantics(find.byType(Typewriter)),
      matchesSemantics(label: 'one. two'),
    );
    await tester.pump(const Duration(seconds: 10));
    handle.dispose();
  });

  testWidgets('reduced motion shows the text typed', (tester) async {
    await tester.pumpWidget(
      componentHost(
        Typewriter('Already typed', cursor: null),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    expect(_typed(tester), 'Already typed');
    expect(find.byType(TypewriterCaret), findsNothing);
  });

  testWidgets('reserve keeps the final size from the start', (tester) async {
    await tester.pumpWidget(
      componentHost(Typewriter('Room for all of this', reserve: true)),
    );
    final before = tester.getSize(find.byType(Typewriter));
    await tester.pump(const Duration(seconds: 5));
    expect(tester.getSize(find.byType(Typewriter)), before);
  });

  testWidgets('the caret blinks only while idle', (tester) async {
    await tester.pumpWidget(componentHost(Typewriter('Hi', seed: 't')));
    TypewriterCaret caret() =>
        tester.widget<TypewriterCaret>(find.byType(TypewriterCaret));
    expect(caret().blinking, isTrue);
    await tester.pump(const Duration(milliseconds: 310));
    expect(caret().blinking, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(caret().blinking, isTrue);
    expect(caret().shape, CaretShape.bar);
  });
}
