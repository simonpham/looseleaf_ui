import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _board({
  CorkboardValue? value,
  ValueChanged<CorkboardValue>? onValueChange,
  bool disabled = false,
}) => componentHost(
  SizedBox(
    width: 600,
    child: Corkboard(
      value: value,
      onValueChange: onValueChange,
      disabled: disabled,
      height: 360,
      children: const [
        CorkboardNote(id: 'a', x: 20, y: 30, rotate: 0, child: Text('A')),
        CorkboardNote(
          id: 'b',
          x: 300,
          y: 40,
          label: 'Note B',
          child: Text('B'),
        ),
      ],
    ),
  ),
);

Offset _topLeft(WidgetTester tester, String id) {
  final board = tester.getTopLeft(find.byType(CustomMultiChildLayout));
  return tester.getTopLeft(
        find.ancestor(
          of: find.byWidgetPredicate((w) => w is CorkboardNote && w.id == id),
          matching: find.byType(LayoutId),
        ),
      ) -
      board;
}

void main() {
  testWidgets('places notes at their own positions inside the frame', (
    tester,
  ) async {
    await tester.pumpWidget(_board());
    expect(_topLeft(tester, 'a'), const Offset(20, 30));
    expect(_topLeft(tester, 'b'), const Offset(300, 40));
    expect(tester.getSize(find.byType(Paper).first).width, Spacing.d176);
  });

  testWidgets('arrows move, R turns and Enter raises the focused note', (
    tester,
  ) async {
    final changes = <CorkboardValue>[];
    await tester.pumpWidget(_board(onValueChange: changes.add));
    await tester.tap(find.text('A'));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(changes.last['a'], const NotePosition(x: 28, y: 30));
    await tester.pump();
    expect(_topLeft(tester, 'a'), const Offset(28, 30));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    expect(changes.last['a']?.y, 62);
    expect(changes.last['a']?.r, -4);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    expect(changes.last['a']?.r, 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(changes.last['a']?.z, 1);
  });

  testWidgets('keeps a note on the cork', (tester) async {
    final changes = <CorkboardValue>[];
    await tester.pumpWidget(_board(onValueChange: changes.add));
    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    expect(changes.last['a']?.x, 0);
  });

  testWidgets('dragging moves a note and brings it to the front', (
    tester,
  ) async {
    final changes = <CorkboardValue>[];
    await tester.pumpWidget(_board(onValueChange: changes.add));
    final gesture = await tester.startGesture(tester.getCenter(find.text('A')));
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(20, 10));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(changes.single['a'], const NotePosition(x: 80, y: 40, z: 1));
    expect(_topLeft(tester, 'a'), const Offset(80, 40));
  });

  testWidgets('a tap without a move changes nothing', (tester) async {
    final changes = <CorkboardValue>[];
    await tester.pumpWidget(_board(onValueChange: changes.add));
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(changes, isEmpty);
  });

  testWidgets('a controlled board shows its value', (tester) async {
    await tester.pumpWidget(
      _board(value: const {'b': NotePosition(x: 10, y: 12)}),
    );
    expect(_topLeft(tester, 'b'), const Offset(10, 12));
  });

  testWidgets('disabled notes stay put', (tester) async {
    final changes = <CorkboardValue>[];
    await tester.pumpWidget(_board(onValueChange: changes.add, disabled: true));
    final gesture = await tester.startGesture(tester.getCenter(find.text('A')));
    await gesture.moveBy(const Offset(60, 0));
    await gesture.up();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(changes, isEmpty);
  });

  testWidgets('names the board and its notes', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_board());
    expect(find.bySemanticsLabel('Corkboard'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^Note B'))),
      matchesSemantics(
        label: 'Note B\nB',
        hint: Corkboard.help,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    semantics.dispose();
  });
}
