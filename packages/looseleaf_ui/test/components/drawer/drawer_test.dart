import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _drawer({
  OverlaySide direction = OverlaySide.bottom,
  ValueChanged<bool>? onOpenChange,
}) => KeyedSubtree(
  key: ValueKey(direction),
  child: overlayHost(
    Drawer(
      direction: direction,
      onOpenChange: onOpenChange,
      content: DrawerContent(
        seed: 'd',
        children: [
          const DrawerHeader(
            children: [
              DrawerTitle(Text('Move goal')),
              DrawerDescription(Text('Set your daily goal.')),
            ],
          ),
          DrawerFooter(
            children: [
              DrawerClose(
                builder: (context, close) => Button(
                  variant: ButtonVariant.outline,
                  onPressed: close,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
      child: DrawerTrigger.builder(
        builder: (context, drawer) =>
            Button(onPressed: drawer.show, child: const Text('Open')),
      ),
    ),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a bottom drawer is full width, torn and taped', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(_drawer(onOpenChange: changes.add));
    await _open(tester);
    final slip = tester.getRect(find.byType(DrawerContent));
    expect(slip.bottom, 600);
    expect(slip.width, 800);
    final tape = tester.getRect(find.byType(Tape));
    expect(tape.center.dx, closeTo(400, 0.5));
    expect(tape.top, lessThan(slip.top));
    expect(tester.getRect(find.text('Move goal')).left, Spacing.d16);
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    final title = tester.getRect(find.text('Move goal'));
    expect(title.center.dx, closeTo(300, 0.5));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DrawerContent), findsNothing);
    expect(changes, [true, false]);
  });

  testWidgets('a long drag down closes it, a short one springs back', (
    tester,
  ) async {
    await tester.pumpWidget(_drawer());
    await _open(tester);
    final slip = tester.getRect(find.byType(DrawerContent));
    await tester.timedDrag(
      find.text('Move goal'),
      const Offset(0, 10),
      const Duration(milliseconds: 400),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(DrawerContent)), slip);
    await tester.timedDrag(
      find.text('Move goal'),
      Offset(0, slip.height * 0.6),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DrawerContent), findsNothing);
  });

  testWidgets('a flick closes it', (tester) async {
    await tester.pumpWidget(_drawer());
    await _open(tester);
    await tester.fling(find.text('Move goal'), const Offset(0, 60), 1500);
    await tester.pumpAndSettle();
    expect(find.byType(DrawerContent), findsNothing);
  });

  testWidgets('side drawers are full height with the footer at the foot', (
    tester,
  ) async {
    for (final direction in [OverlaySide.left, OverlaySide.right]) {
      await tester.pumpWidget(_drawer(direction: direction));
      await _open(tester);
      final slip = tester.getRect(find.byType(DrawerContent));
      expect(slip.height, 600);
      expect(slip.width, SheetContent.maxSideWidth);
      expect(tester.getRect(find.byType(DrawerFooter)).bottom, 600);
      expect(find.byType(Tape), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(DrawerContent), findsNothing);
    }
  });

  testWidgets('a top drawer hangs from the top', (tester) async {
    await tester.pumpWidget(_drawer(direction: OverlaySide.top));
    await _open(tester);
    expect(tester.getRect(find.byType(DrawerContent)).top, 0);
    await tester.tapAt(const Offset(400, 590));
    await tester.pumpAndSettle();
    expect(find.byType(DrawerContent), findsNothing);
  });
}
