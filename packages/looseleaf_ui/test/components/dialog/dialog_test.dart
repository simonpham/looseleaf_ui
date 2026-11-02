import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _dialog({
  bool modal = true,
  bool showCloseButton = true,
  ValueChanged<bool>? onOpenChange,
  List<Widget> children = const [
    DialogHeader(
      children: [
        DialogTitle(Text('Edit profile')),
        DialogDescription(Text('Make changes here.')),
      ],
    ),
  ],
}) => Dialog(
  modal: modal,
  onOpenChange: onOpenChange,
  content: DialogContent(
    seed: 'd',
    showCloseButton: showCloseButton,
    children: [
      ...children,
      DialogFooter(
        showCloseButton: true,
        children: [
          DialogClose(
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
  child: DialogTrigger.builder(
    builder: (context, dialog) =>
        Button(onPressed: dialog.show, child: const Text('Open')),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens centred and closes from Cancel, Close and the x', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(overlayHost(_dialog(onOpenChange: changes.add)));
    expect(find.text('Edit profile'), findsNothing);
    await _open(tester);
    expect(find.text('Edit profile'), findsOneWidget);
    final window = tester.getRect(find.byType(Overlay).first);
    final sheet = tester.getRect(find.byType(DialogContent));
    expect(sheet.center.dx, closeTo(window.center.dx, 0.5));
    expect(sheet.width, DialogMetrics.maxWidth);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    await _open(tester);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    await _open(tester);
    await tester.tap(find.byType(DialogCloseMark));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    expect(changes, [true, false, true, false, true, false]);
  });

  testWidgets('Escape and a tap on the dim close it', (tester) async {
    await tester.pumpWidget(overlayHost(_dialog()));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
    await _open(tester);
    expect(find.byType(OverlayScrim), findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile'), findsNothing);
  });

  testWidgets('a non-modal dialog has no dim', (tester) async {
    await tester.pumpWidget(overlayHost(_dialog(modal: false)));
    await _open(tester);
    expect(find.byType(OverlayScrim), findsNothing);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('Tab stays inside and focus returns to the trigger', (
    tester,
  ) async {
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    await tester.pumpWidget(
      overlayHost(
        Dialog(
          content: const DialogContent(
            showCloseButton: false,
            children: [
              DialogTitle(Text('Title')),
              DialogFooter(showCloseButton: true),
            ],
          ),
          child: DialogTrigger(focusNode: trigger, child: const Text('Open')),
        ),
      ),
    );
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Title'), findsOneWidget);
    expect(trigger.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(trigger.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('the header keeps clear of the x and centres on phones', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_dialog()));
    await _open(tester);
    Rect header() => tester.getRect(
      find.descendant(
        of: find.byType(DialogHeader),
        matching: find.byType(Column),
      ),
    );
    final sheet = tester.getRect(find.byType(DialogContent));
    expect(sheet.right - header().right, Spacing.d24 + Spacing.d32);
    final mark = tester.getRect(find.byType(DialogCloseMark));
    expect(sheet.right - mark.right, DialogMetrics.closeInset);
    expect(mark.top - sheet.top, DialogMetrics.closeInset);

    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    final phoneSheet = tester.getRect(find.byType(DialogContent));
    expect(phoneSheet.width, 400);
    expect(phoneSheet.bottom, 800);
    expect(phoneSheet.right - header().right, Spacing.d24);
    final cancel = tester.getRect(find.text('Cancel'));
    final close = tester.getRect(find.text('Close'));
    expect(cancel.top, greaterThan(close.top));
  });

  testWidgets('on phones it rises from the bottom past the safe area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewPadding = const FakeViewPadding(bottom: 40);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(overlayHost(_dialog()));
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump();
    final motion = tester.widget<PopupMotion>(find.byType(PopupMotion));
    expect(motion.style, PopupMotionStyle.rise);
    await tester.pump(const Duration(milliseconds: 50));
    final rising = tester.getRect(find.byType(DialogContent));
    await tester.pumpAndSettle();
    final sheet = tester.getRect(find.byType(DialogContent));
    expect(rising.top, greaterThan(sheet.top));
    expect(sheet.bottom, 800);
    final cancel = tester.getRect(find.text('Cancel'));
    expect(sheet.bottom - cancel.bottom, greaterThanOrEqualTo(40));
  });

  testWidgets('the padding follows the density', (tester) async {
    for (final (density, padding) in [
      (LooseleafDensity.comfortable, Spacing.d24),
      (LooseleafDensity.compact, Spacing.d20),
      (LooseleafDensity.calm, Spacing.d16),
    ]) {
      await tester.pumpWidget(
        overlayHost(
          const Dialog(
            defaultOpen: true,
            content: DialogContent(
              showCloseButton: false,
              children: [Text('Body', key: Key('body'))],
            ),
            child: SizedBox(),
          ),
          theme: LooseleafThemeData(density: density),
        ),
      );
      await tester.pumpAndSettle();
      final sheet = tester.getRect(find.byType(DialogContent));
      final body = tester.getRect(find.byKey(const Key('body')));
      expect(body.top - sheet.top, padding, reason: density.name);
    }
  });

  testWidgets('the close mark is a Close button and the title names it', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_dialog()));
    await _open(tester);
    expect(
      tester.getSemantics(find.byType(DialogCloseMark)),
      matchesSemantics(
        label: 'Close',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
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

  testWidgets('the body scrolls with the arrow keys', (tester) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      overlayHost(
        Dialog(
          defaultOpen: true,
          content: DialogContent(
            children: [
              DialogBody(
                controller: scroll,
                child: Column(
                  children: [
                    for (var i = 0; i < 80; i++) Text('Line $i'),
                  ],
                ),
              ),
            ],
          ),
          child: const SizedBox(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final body = tester.getRect(find.byType(DialogBody));
    expect(body.height, lessThanOrEqualTo(600 * DialogMetrics.bodyMaxFraction));
    expect(scroll.offset, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(scroll.offset, greaterThan(0));
  });
}
