import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

List<InkSurface> _decor(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .where((surface) => surface.seed.endsWith('|decor'))
    .toList();

void main() {
  testWidgets('is 176 wide, at least 160 tall, padded under the band', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const StickyNote(
          seed: 'n',
          children: [
            StickyNoteTitle(Text('todo')),
            StickyNoteContent(Text('ink')),
            StickyNoteFooter(Text('from Ada')),
          ],
        ),
      ),
    );
    final note = tester.getRect(find.byType(StickyNote));
    expect(note.size, const Size(176, 160));
    expect(
      tester.getTopLeft(find.text('todo')) - note.topLeft,
      const Offset(16, 24),
    );
    expect(tester.getBottomLeft(find.text('from Ada')).dy, note.bottom - 16);
  });

  testWidgets('a fixed height and width win', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const StickyNote(
          width: 128,
          height: 112,
          children: [StickyNoteContent(Text('small'))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(StickyNote)), const Size(128, 112));
  });

  testWidgets('uses the pad stock and turns at most 1.6 degrees', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const StickyNote(color: StickyColor.pink, seed: 'n')),
    );
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.stickyPink);
    expect(paper.tiltDegrees?.abs(), lessThanOrEqualTo(1.6));
  });

  testWidgets('a plain note has no tick box', (tester) async {
    await tester.pumpWidget(componentHost(const StickyNote(seed: 'n')));
    expect(_decor(tester), isEmpty);
    expect(find.byType(StickyNoteCheck), findsNothing);
  });

  testWidgets('done ticks the box and strikes the content through', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const StickyNote(
          done: true,
          seed: 'n',
          children: [StickyNoteContent(Text('ink'))],
        ),
      ),
    );
    expect(_decor(tester).single.states, {InkState.checked});
    expect(_decor(tester).single.drawOn, isFalse);
    final style = DefaultTextStyle.of(tester.element(find.text('ink'))).style;
    expect(style.decoration, TextDecoration.lineThrough);
    expect(
      tester.getTopLeft(find.text('ink')).dy -
          tester.getTopLeft(find.byType(StickyNote)).dy,
      32,
    );
  });

  testWidgets('the tick box toggles on tap and Space, and draws on', (
    tester,
  ) async {
    var done = false;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        StatefulBuilder(
          builder: (context, setState) => StickyNote(
            done: done,
            focusNode: focus,
            onDoneChange: (value) => setState(() => done = value),
            seed: 'n',
          ),
        ),
      ),
    );
    final check = tester.getRect(find.byType(StickyNoteCheck));
    final note = tester.getRect(find.byType(StickyNote));
    expect(check.size, const Size(32, 32));
    expect(note.right - check.right, 3.5);
    expect(check.top - note.top, 2.5);
    await tester.tap(find.byType(StickyNoteCheck));
    await tester.pump();
    expect(done, isTrue);
    expect(_decor(tester).single.drawOn, isTrue);
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(done, isFalse);
  });

  testWidgets('the tick box mirrors in right-to-left', (tester) async {
    await tester.pumpWidget(
      componentHost(
        Directionality(
          textDirection: TextDirection.rtl,
          child: StickyNote(done: false, onDoneChange: (_) {}),
        ),
      ),
    );
    final check = tester.getRect(find.byType(StickyNoteCheck));
    final note = tester.getRect(find.byType(StickyNote));
    expect(check.left - note.left, 3.5);
  });

  testWidgets('semantics: a named checkbox, or a done note says so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        StickyNote(done: true, doneLabel: 'Design: done', onDoneChange: (_) {}),
      ),
    );
    expect(
      tester.getSemantics(find.byType(StickyNoteCheck)),
      matchesSemantics(
        label: 'Design: done',
        hasCheckedState: true,
        isChecked: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        hasEnabledState: false,
      ),
    );
    await tester.pumpWidget(
      componentHost(
        const StickyNote(
          done: true,
          children: [StickyNoteContent(Text('ink'))],
        ),
      ),
    );
    expect(find.bySemanticsLabel(RegExp(r'^Done\.')), findsOneWidget);
    handle.dispose();
  });
}
