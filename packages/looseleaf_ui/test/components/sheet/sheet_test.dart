import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _sheet({
  OverlaySide side = OverlaySide.right,
  SheetBinding binding = SheetBinding.spiral,
  bool modal = true,
  ValueChanged<bool>? onOpenChange,
}) => Sheet(
  modal: modal,
  onOpenChange: onOpenChange,
  content: SheetContent(
    side: side,
    binding: binding,
    seed: 's',
    children: [
      const SheetHeader(
        children: [
          SheetTitle(Text('Edit profile')),
          SheetDescription(Text('Make changes here.')),
        ],
      ),
      SheetFooter(
        children: [
          SheetClose(
            builder: (context, close) => Button(
              variant: ButtonVariant.outline,
              onPressed: close,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    ],
  ),
  child: SheetTrigger.builder(
    builder: (context, sheet) =>
        Button(onPressed: sheet.show, child: const Text('Open')),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('slides in from the right, full height, 384 px wide', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(overlayHost(_sheet(onOpenChange: changes.add)));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final moving = tester.getRect(find.byType(SheetContent));
    await tester.pumpAndSettle();
    final sheet = tester.getRect(find.byType(SheetContent));
    expect(moving.left, greaterThan(sheet.left));
    expect(sheet.right, 800);
    expect(sheet.top, 0);
    expect(sheet.height, 600);
    expect(sheet.width, SheetContent.maxSideWidth);
    final footer = tester.getRect(find.byType(SheetFooter));
    expect(footer.bottom, 600);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(SheetContent), findsNothing);
    expect(changes, [true, false]);
  });

  testWidgets('each side hangs from its own edge', (tester) async {
    for (final side in OverlaySide.values) {
      await tester.pumpWidget(
        KeyedSubtree(
          key: ValueKey(side),
          child: overlayHost(_sheet(side: side)),
        ),
      );
      await _open(tester);
      final sheet = tester.getRect(find.byType(SheetContent));
      switch (side) {
        case OverlaySide.top:
          expect(sheet.top, 0);
          expect(sheet.width, 800);
        case OverlaySide.bottom:
          expect(sheet.bottom, 600);
          expect(sheet.width, 800);
        case OverlaySide.left:
          expect(sheet.left, 0);
          expect(sheet.height, 600);
        case OverlaySide.right:
          expect(sheet.right, 800);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(SheetContent), findsNothing, reason: side.name);
    }
  });

  testWidgets('the binding pads its edge and moves the close mark', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_sheet(side: OverlaySide.left)));
    await _open(tester);
    final sheet = tester.getRect(find.byType(SheetContent));
    final mark = tester.getRect(find.byType(DialogCloseMark));
    expect(sheet.right - mark.right, SheetContent.boundCloseInset);
    final header = tester.getRect(find.byType(SheetHeader));
    expect(sheet.right - header.right, SheetContent.boundPadding);
    await tester.tapAt(const Offset(780, 300));
    await tester.pumpAndSettle();
    expect(find.byType(SheetContent), findsNothing);

    await tester.pumpWidget(
      KeyedSubtree(
        key: const ValueKey('plain'),
        child: overlayHost(
          _sheet(side: OverlaySide.left, binding: SheetBinding.none),
        ),
      ),
    );
    await _open(tester);
    final plain = tester.getRect(find.byType(SheetContent));
    final plainMark = tester.getRect(find.byType(DialogCloseMark));
    expect(plain.right - plainMark.right, DialogMetrics.closeInset);
  });

  testWidgets('phones get three quarters of the window', (tester) async {
    tester.view.physicalSize = const Size(400, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(overlayHost(_sheet()));
    await _open(tester);
    expect(tester.getSize(find.byType(SheetContent)).width, 300);
  });

  testWidgets('Tab stays inside and focus returns to the trigger', (
    tester,
  ) async {
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    await tester.pumpWidget(
      overlayHost(
        Sheet(
          content: const SheetContent(
            children: [
              SheetHeader(children: [SheetTitle(Text('Title'))]),
            ],
          ),
          child: SheetTrigger(focusNode: trigger, child: const Text('Open')),
        ),
      ),
    );
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    await tester.pump();
    expect(trigger.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('a non-modal sheet closes on an outside tap without a dim', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_sheet(modal: false)));
    await _open(tester);
    expect(find.byType(OverlayScrim), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byType(SheetContent), findsNothing);
  });

  testWidgets('the title names the sheet', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_sheet()));
    await _open(tester);
    expect(
      tester.getSemantics(find.text('Edit profile')),
      matchesSemantics(
        label: 'Edit profile',
        isHeader: true,
        namesRoute: true,
      ),
    );
    handle.dispose();
  });
}
