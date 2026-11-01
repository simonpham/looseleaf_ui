import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Finder _slot(String label) => find.bySemanticsLabel(label);

void main() {
  testWidgets('a tap peels a sticker and another sticks it back', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final peels = <StickerSheetPeel>[];
    final sticks = <StickerSheetPeel>[];
    final changes = <List<String>>[];
    await tester.pumpWidget(
      componentHost(
        StickerSheet(
          title: 'Sheet',
          stickers: const ['rocket', 'done'],
          onPeel: peels.add,
          onStick: sticks.add,
          onPeeledChange: changes.add,
        ),
      ),
    );
    expect(find.text('2 left'), findsOneWidget);
    await tester.tap(_slot('Peel Rocket sticker'));
    await tester.pumpAndSettle();
    expect(peels.single.id, 'rocket');
    expect(peels.single.dragged, isFalse);
    expect(changes.last, ['rocket']);
    expect(find.text('1 left'), findsOneWidget);
    expect(_slot('Put Rocket sticker back'), findsOneWidget);

    await tester.tap(_slot('Put Rocket sticker back'));
    await tester.pumpAndSettle();
    expect(sticks.single.label, 'Rocket');
    expect(changes.last, isEmpty);
    semantics.dispose();
  });

  testWidgets('a spent sticker stays peeled', (tester) async {
    final semantics = tester.ensureSemantics();
    final changes = <List<String>>[];
    await tester.pumpWidget(
      componentHost(
        StickerSheet(
          stickers: const ['rocket'],
          restorable: false,
          defaultPeeled: const ['rocket'],
          onPeeledChange: changes.add,
        ),
      ),
    );
    expect(
      tester.getSemantics(_slot('Rocket sticker, peeled')),
      matchesSemantics(
        label: 'Rocket sticker, peeled',
        isButton: true,
        hasEnabledState: true,
        isFocusable: true,
        hasFocusAction: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(_slot('Rocket sticker, peeled'));
    await tester.pump();
    expect(changes, isEmpty);
    semantics.dispose();
  });

  testWidgets('Enter peels the focused sticker', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final peels = <StickerSheetPeel>[];
    await tester.pumpWidget(
      componentHost(
        StickerSheet(
          onPeel: peels.add,
          children: [StickerSheetItem(name: 'rocket', focusNode: focus)],
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(peels.single.name, 'rocket');
  });

  testWidgets('a mouse pull peels it off where it lets go', (tester) async {
    final semantics = tester.ensureSemantics();
    final peels = <StickerSheetPeel>[];
    await tester.pumpWidget(
      componentHost(
        StickerSheet(stickers: const ['rocket', 'done'], onPeel: peels.add),
      ),
    );
    final start = tester.getCenter(_slot('Peel Rocket sticker'));
    final short = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await short.moveBy(const Offset(10, 0));
    await short.up();
    await tester.pump();
    expect(peels, isEmpty);

    final pull = await tester.startGesture(
      start,
      kind: PointerDeviceKind.mouse,
    );
    await pull.moveBy(const Offset(20, 0));
    await pull.moveBy(const Offset(40, 20));
    await pull.up();
    await tester.pumpAndSettle();
    expect(peels.single.dragged, isTrue);
    expect(peels.single.position, start + const Offset(60, 20));
    semantics.dispose();
  });

  testWidgets('a disabled sheet peels nothing', (tester) async {
    final semantics = tester.ensureSemantics();
    final peels = <StickerSheetPeel>[];
    await tester.pumpWidget(
      componentHost(
        StickerSheet(
          stickers: const ['rocket'],
          disabled: true,
          onPeel: peels.add,
        ),
      ),
    );
    await tester.tap(_slot('Peel Rocket sticker'), warnIfMissed: false);
    await tester.pump();
    expect(peels, isEmpty);
    semantics.dispose();
  });

  testWidgets('cells are the size plus 22', (tester) async {
    await tester.pumpWidget(
      componentHost(const StickerSheet(stickers: ['rocket'], size: 64)),
    );
    expect(
      tester.getSize(
        find
            .descendant(
              of: find.byType(StickerSheetItem),
              matching: find.byType(SizedBox),
            )
            .first,
      ),
      const Size.square(86),
    );
  });
}
