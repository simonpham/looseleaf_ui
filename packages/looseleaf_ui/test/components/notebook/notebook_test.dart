import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

List<InkSurface> _decor(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .where((surface) => surface.seed.endsWith('|decor'))
    .toList();

Widget _week({String? value, ValueChanged<String>? onValueChange}) => SizedBox(
  width: 400,
  child: Notebook(
    curl: true,
    value: value,
    defaultValue: 'mon',
    onValueChange: onValueChange,
    seed: 'week',
    children: const [
      NotebookPage(value: 'mon', children: [Text('Monday')]),
      NotebookPage(value: 'tue', children: [Text('Tuesday')]),
      NotebookTurn(to: 'tue', semanticLabel: 'Next: Tuesday'),
    ],
  ),
);

void main() {
  testWidgets('text starts past the margin on a 28 px rhythm', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 400,
          child: Notebook(
            seed: 'n',
            children: [
              NotebookPage(children: [Text('one'), Text('two')]),
            ],
          ),
        ),
      ),
    );
    final book = tester.getRect(find.byType(Notebook));
    expect(book.width, 400);
    final one = tester.getRect(find.text('one'));
    expect(one.topLeft - book.topLeft, const Offset(56, 16));
    expect(one.height, closeTo(28, 0.01));
    expect(tester.getTopLeft(find.text('two')).dy - one.top, closeTo(28, 0.01));
  });

  testWidgets('bound on top: pad rules on a 30 px rhythm, no margin', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 400,
          child: Notebook(
            side: NotebookSide.top,
            seed: 'n',
            children: [
              NotebookPage(children: [Text('one')]),
            ],
          ),
        ),
      ),
    );
    final book = tester.getRect(find.byType(Notebook));
    final one = tester.getRect(find.text('one'));
    expect(one.topLeft - book.topLeft, const Offset(24, 40));
    expect(one.height, closeTo(30, 0.01));
    expect(tester.widget<Paper>(find.byType(Paper)).rules, RuleName.pad);
  });

  testWidgets('draws the binding unless bare, and turns at most 0.3 deg', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const SizedBox(width: 300, child: Notebook(seed: 'n'))),
    );
    expect(_decor(tester).single.seed, 'n|decor');
    expect(
      tester.widget<Paper>(find.byType(Paper)).tiltDegrees?.abs(),
      lessThanOrEqualTo(0.3),
    );
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Notebook(binding: NotebookBinding.none, pages: 0, seed: 'n'),
        ),
      ),
    );
    expect(_decor(tester), isEmpty);
  });

  testWidgets('the rules mirror right-to-left', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(width: 300, child: Notebook(seed: 'n')),
        ),
      ),
    );
    expect(tester.widget<Paper>(find.byType(Paper)).mirrorRules, isTrue);
  });

  testWidgets('shows only the open page; the turn button turns it', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_week()));
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Tuesday'), findsNothing);
    final turn = tester.getRect(find.byType(NotebookTurn));
    final book = tester.getRect(find.byType(Notebook));
    expect(turn.size, const Size(34, 34));
    expect(turn.bottomRight, book.bottomRight);
    await tester.tap(find.byType(NotebookTurn));
    await tester.pump();
    expect(find.text('Monday'), findsNothing);
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.byType(ClipPath), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('controlled: reports the page and waits for the value', (
    tester,
  ) async {
    final turned = <String>[];
    await tester.pumpWidget(
      componentHost(_week(value: 'mon', onValueChange: turned.add)),
    );
    await tester.tap(find.byType(NotebookTurn));
    await tester.pump();
    expect(turned, ['tue']);
    expect(find.text('Monday'), findsOneWidget);
  });

  testWidgets('the turn button works from the keyboard and is named', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 400,
          child: Notebook(
            defaultValue: 'mon',
            children: [
              const NotebookPage(value: 'mon', children: [Text('Monday')]),
              const NotebookPage(value: 'tue', children: [Text('Tuesday')]),
              NotebookTurn(to: 'tue', focusNode: focus),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(NotebookTurn)),
      matchesSemantics(
        label: 'Turn the page',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Tuesday'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the title is a header lifted onto its rule', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 400,
          child: Notebook(
            children: [
              NotebookPage(children: [NotebookTitle(Text('Monday'))]),
            ],
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(NotebookTitle)),
      matchesSemantics(label: 'Monday', isHeader: true),
    );
    final top = tester.getTopLeft(find.text('Monday')).dy;
    expect(
      top - tester.getTopLeft(find.byType(Notebook)).dy,
      closeTo(16 - 5.2, 1e-9),
    );
    handle.dispose();
  });

  testWidgets('a cover is 176 x 240 with its label clear of the spine', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const NotebookCover(
          seed: 'c',
          child: NotebookCoverLabel(Text('Recipes'), seed: 'c'),
        ),
      ),
    );
    final cover = tester.getRect(find.byType(NotebookCover));
    expect(cover.size, const Size(176, 240));
    final label = tester.getRect(find.byType(NotebookCoverLabel));
    expect(label.top - cover.top, 52);
    expect(label.left - cover.left, 20);
    expect(cover.right - label.right, closeTo(32.4, 1e-9));
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.indexCard);
  });
}
