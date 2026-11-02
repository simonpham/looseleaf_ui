import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';
import '../../support/semantics_matchers.dart';

bool _lit(WidgetTester tester, String label) => tester
    .widget<InkMenuRow>(
      find.ancestor(of: find.text(label), matching: find.byType(InkMenuRow)),
    )
    .highlighted;

MenubarMenu _menu(String title, List<String> rows, {List<String>? chosen}) =>
    MenubarMenu(
      value: title,
      trigger: MenubarTrigger(child: Text(title)),
      content: MenubarContent(
        children: [
          for (final row in rows)
            MenubarItem(
              onSelect: () => chosen?.add(row),
              child: Text(row),
            ),
        ],
      ),
    );

Widget _bar({
  List<String>? chosen,
  List<String?>? values,
  TextDirection direction = TextDirection.ltr,
}) => Directionality(
  textDirection: direction,
  child: Menubar(
    onValueChange: values?.add,
    children: [
      _menu('File', ['New Tab', 'Print'], chosen: chosen),
      _menu('Edit', ['Undo', 'Redo'], chosen: chosen),
      _menu('View', ['Reload'], chosen: chosen),
    ],
  ),
);

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

FocusNode _focusOf(WidgetTester tester, String title) => tester
    .widget<FocusableActionDetector>(
      find.ancestor(
        of: find.text(title),
        matching: find.byType(FocusableActionDetector),
      ),
    )
    .focusNode!;

void main() {
  testWidgets('semanticLabel names the bar', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      overlayHost(
        Menubar(
          semanticLabel: 'Application',
          children: [
            _menu('File', ['New Tab']),
          ],
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Application'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Application')),
      includesSemantics(role: SemanticsRole.menuBar, label: 'Application'),
    );
    handle.dispose();
  });

  testWidgets('a tap opens a menu and another closes it', (tester) async {
    final values = <String?>[];
    await tester.pumpWidget(overlayHost(_bar(values: values)));
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New Tab'), findsOneWidget);
    expect(_lit(tester, 'New Tab'), isFalse);
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New Tab'), findsNothing);
    expect(values, ['File', null]);
  });

  testWidgets('hovering another title switches menus', (tester) async {
    await tester.pumpWidget(overlayHost(_bar()));
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.text('File')));
    await mouse.moveTo(tester.getCenter(find.text('Edit')));
    await tester.pumpAndSettle();
    expect(find.text('New Tab'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('arrows move between titles; Down opens one', (tester) async {
    await tester.pumpWidget(overlayHost(_bar()));
    _focusOf(tester, 'File').requestFocus();
    await tester.pump();
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_focusOf(tester, 'Edit').hasFocus, isTrue);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_lit(tester, 'Undo'), isTrue);
  });

  testWidgets('Left and Right from a row switch menus', (tester) async {
    await tester.pumpWidget(overlayHost(_bar()));
    _focusOf(tester, 'File').requestFocus();
    await tester.pump();
    await _key(tester, LogicalKeyboardKey.enter);
    expect(_lit(tester, 'New Tab'), isTrue);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('New Tab'), findsNothing);
    expect(_lit(tester, 'Undo'), isTrue);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(_lit(tester, 'Reload'), isTrue, reason: 'it wraps');
    await _key(tester, LogicalKeyboardKey.escape);
    expect(find.text('Reload'), findsNothing);
    expect(_focusOf(tester, 'View').hasFocus, isTrue);
  });

  testWidgets('right-to-left mirrors the arrows', (tester) async {
    await tester.pumpWidget(
      overlayHost(_bar(direction: TextDirection.rtl)),
    );
    _focusOf(tester, 'File').requestFocus();
    await tester.pump();
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focusOf(tester, 'Edit').hasFocus, isTrue);
    await _key(tester, LogicalKeyboardKey.space);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(_lit(tester, 'Reload'), isTrue);
  });

  testWidgets('choosing a row closes the menu', (tester) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_bar(chosen: chosen)));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Redo'));
    await tester.pumpAndSettle();
    expect(chosen, ['Redo']);
    expect(find.text('Redo'), findsNothing);
  });

  testWidgets('a tap outside closes it', (tester) async {
    await tester.pumpWidget(overlayHost(_bar()));
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('New Tab'), findsNothing);
  });

  testWidgets('the strip is a menu bar of menu items', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_bar()));
    expect(
      tester.getSemantics(find.text('File')),
      includesSemantics(role: SemanticsRole.menuItem, isEnabled: true),
    );
    handle.dispose();
  });

  testWidgets('the strip is 40 px tall, 32 calm', (tester) async {
    await tester.pumpWidget(overlayHost(_bar()));
    expect(tester.getSize(find.byType(Menubar)).height, Spacing.d40);
    await tester.pumpWidget(
      overlayHost(
        _bar(),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(tester.getSize(find.byType(Menubar)).height, Spacing.d32);
  });

  testWidgets('titles scroll sideways in a narrow bar', (tester) async {
    await tester.pumpWidget(
      overlayHost(Center(child: SizedBox(width: 120, child: _bar()))),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Menubar)).width, 120);
    final scrollable = find.descendant(
      of: find.byType(Menubar),
      matching: find.byType(Scrollable),
    );
    expect(
      tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
      greaterThan(0),
    );
  });
}
