import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const _start = [
  StickerBoardItem(
    id: 'rocket',
    name: 'rocket',
    x: 100,
    y: 100,
    rot: 0,
    scale: 1,
    z: 0,
  ),
  StickerBoardItem(
    id: 'sun',
    name: 'sun-shades',
    x: 300,
    y: 150,
    rot: 0,
    scale: 1,
    z: 1,
  ),
];

class _Probe {
  final changes = <List<StickerBoardItem>>[];
  final selections = <String?>[];
  StickerBoardExport? exported;

  StickerBoardItem item(String id) =>
      changes.last.firstWhere((s) => s.id == id);
}

Widget _board(
  _Probe probe, {
  bool readOnly = false,
  GlobalKey<StickerBoardState>? key,
}) => componentHost(
  SizedBox(
    width: 480,
    child: StickerBoard(
      key: key,
      defaultValue: _start,
      readOnly: readOnly,
      onValueChange: probe.changes.add,
      onSelectedIdChange: probe.selections.add,
      onExport: (data) => probe.exported = data,
    ),
  ),
);

Finder _sticker(String id) => find.byKey(ValueKey(id));

Future<void> _focus(WidgetTester tester, String id) async {
  await tester.tap(_sticker(id));
  await tester.pump();
}

Future<void> _key(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  String? char,
  bool shift = false,
}) async {
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key, character: char);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.pump();
}

void main() {
  group('StickerBoardOps', () {
    test('turnTo wraps into (-180, 180]', () {
      expect(StickerBoardOps.turnTo(190), -170);
      expect(StickerBoardOps.turnTo(-180), 180);
      expect(StickerBoardOps.turnTo(12.345), 12.3);
    });

    test('reorder renumbers depths and keeps unchanged lists', () {
      final front = StickerBoardOps.reorder(
        _start,
        'rocket',
        StickerReorder.front,
      );
      expect([for (final s in front) s.z], [1, 0]);
      expect(
        identical(
          StickerBoardOps.reorder(_start, 'sun', StickerReorder.forward),
          _start,
        ),
        isTrue,
      );
    });

    test('add names, centres and stacks the new sticker', () {
      final next = StickerBoardOps.add(
        _start,
        'rocket',
        canvas: const Size(400, 300),
      );
      expect(next.last.id, 'rocket-1');
      expect(next.last.z, 2);
      expect(next.last.x, 200 + ((2 % 5) - 2) * 18);
    });

    test('keepIn keeps the centre or the whole art on the board', () {
      const canvas = Size(200, 100);
      expect(
        StickerBoardOps.keepIn(
          -20,
          150,
          art: const Size(40, 40),
          rot: 0,
          scale: 1,
          canvas: canvas,
          mode: StickerBoardBounds.center,
        ),
        const Offset(0, 100),
      );
      expect(
        StickerBoardOps.keepIn(
          -20,
          150,
          art: const Size(40, 40),
          rot: 0,
          scale: 1,
          canvas: canvas,
          mode: StickerBoardBounds.inside,
        ),
        const Offset(20, 80),
      );
    });
  });

  testWidgets('a press selects a sticker and bare paper lets go', (
    tester,
  ) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    await _focus(tester, 'rocket');
    expect(probe.selections.last, 'rocket');
    await tester.tapAt(
      tester.getTopLeft(find.byType(StickerBoardCanvas)) +
          const Offset(400, 280),
    );
    await tester.pump();
    expect(probe.selections.last, isNull);
  });

  testWidgets('dragging moves a sticker', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    final gesture = await tester.startGesture(
      tester.getCenter(_sticker('rocket')),
    );
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(10, 20));
    await gesture.up();
    await tester.pump();
    expect(probe.item('rocket').x, 140);
    expect(probe.item('rocket').y, 120);
  });

  testWidgets('the handles turn and size the selected sticker', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    await _focus(tester, 'rocket');
    final center = tester.getCenter(_sticker('rocket'));
    final box = tester.getSize(_sticker('rocket'));
    final h = box.height - 2 * StickerBoardSticker.reach;
    final w = box.width - 2 * StickerBoardSticker.reach;
    final ring =
        center -
        Offset(0, h / 2 + StickerBoardSticker.out + StickerHandle.rotateUp);
    final turn = await tester.startGesture(ring);
    await turn.moveTo(center + Offset(h / 2 + 35, 0));
    await turn.up();
    await tester.pump();
    expect(probe.item('rocket').rot, closeTo(90, 0.5));

    final corner = center + Offset(-(h / 2 + 4.5), w / 2 + 4.5);
    final grow = await tester.startGesture(corner);
    await grow.moveTo(center + (corner - center) * 2);
    await grow.up();
    await tester.pump();
    expect(probe.item('rocket').scale, closeTo(2, 0.02));
  });

  testWidgets('keys move, turn, size, restack, duplicate and delete', (
    tester,
  ) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    await _focus(tester, 'rocket');

    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(probe.item('rocket').x, 108);
    await _key(tester, LogicalKeyboardKey.arrowDown, shift: true);
    expect(probe.item('rocket').y, 132);

    await _key(tester, LogicalKeyboardKey.bracketRight, char: ']');
    expect(probe.item('rocket').rot, 5);
    await _key(tester, LogicalKeyboardKey.keyR, char: 'R', shift: true);
    expect(probe.item('rocket').rot, -10);

    await _key(tester, LogicalKeyboardKey.equal, char: '=');
    expect(probe.item('rocket').scale, 1.1);
    await _key(tester, LogicalKeyboardKey.digit0, char: '0');
    expect(probe.item('rocket').scale, 1);
    expect(probe.item('rocket').rot, 0);

    await _key(tester, LogicalKeyboardKey.pageUp);
    expect(probe.item('rocket').z, 1);
    expect(probe.item('sun').z, 0);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(probe.changes.last.last.id, 'rocket-1');
    expect(probe.selections.last, 'rocket-1');

    await _focus(tester, 'sun');
    await _key(tester, LogicalKeyboardKey.delete);
    expect(probe.changes.last.any((s) => s.id == 'sun'), isFalse);
    expect(probe.selections.last, isNull);
  });

  testWidgets('Escape lets go of the sticker', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    await _focus(tester, 'sun');
    await _key(tester, LogicalKeyboardKey.escape);
    expect(probe.selections.last, isNull);
  });

  testWidgets('the toolbar acts on the selection and exports', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe));
    expect(
      tester.widget<Button>(find.byKey(const ValueKey('Turn right'))).disabled,
      isTrue,
    );
    await _focus(tester, 'rocket');
    await tester.tap(find.byKey(const ValueKey('Turn right')));
    await tester.pump();
    expect(probe.item('rocket').rot, 5);
    await tester.tap(find.byKey(const ValueKey('Bring to front')));
    await tester.pump();
    expect(probe.item('rocket').z, 1);

    await tester.tap(find.byKey(const ValueKey('Export')));
    await tester.pump();
    final data = probe.exported;
    expect(data, isNotNull);
    expect(data?.width, 480);
    expect(data?.svg, startsWith('<svg'));
    expect(data?.svg, isNot(contains('var(--ll-ink)')));
    expect(data?.json, contains('"id": "rocket"'));
  });

  testWidgets('a read-only board changes nothing', (tester) async {
    final probe = _Probe();
    await tester.pumpWidget(_board(probe, readOnly: true));
    final gesture = await tester.startGesture(
      tester.getCenter(_sticker('rocket')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await gesture.up();
    await tester.pump();
    expect(probe.changes, isEmpty);
    expect(probe.selections, isEmpty);
  });

  testWidgets('boardPoint maps a global point onto the canvas', (tester) async {
    final key = GlobalKey<StickerBoardState>();
    await tester.pumpWidget(_board(_Probe(), key: key));
    final origin = tester.getTopLeft(
      find.byKey(key.currentState?.canvasKey ?? GlobalKey()),
    );
    final hit = key.currentState?.boardPoint(origin + const Offset(12.4, 30.6));
    expect(hit?.point, const Offset(12, 31));
    expect(hit?.inside, isTrue);
    expect(
      key.currentState?.boardPoint(origin - const Offset(5, 5))?.inside,
      isFalse,
    );
  });

  testWidgets('names the stickers and the board', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_board(_Probe()));
    expect(find.bySemanticsLabel(RegExp('^Sticker board')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Rocket')), findsOneWidget);
    expect(find.bySemanticsLabel('Sticker tools'), findsOneWidget);
    semantics.dispose();
  });
}
