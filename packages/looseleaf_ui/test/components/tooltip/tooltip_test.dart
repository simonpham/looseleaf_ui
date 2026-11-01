import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _tooltip({
  Duration? delay,
  bool disabled = false,
  FocusNode? focusNode,
  ValueChanged<bool>? onOpenChange,
}) => Tooltip(
  delay: delay,
  disabled: disabled,
  onOpenChange: onOpenChange,
  content: const TooltipContent(seed: 't', child: Text('Add to library')),
  child: Button(
    focusNode: focusNode,
    onPressed: () {},
    seed: 'b',
    child: const Text('Add'),
  ),
);

Future<TestGesture> _hover(WidgetTester tester, Finder finder) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(finder));
  return mouse;
}

void main() {
  testWidgets('opens above the trigger on hover and closes on leave', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(overlayHost(_tooltip(onOpenChange: changes.add)));
    final mouse = await _hover(tester, find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsOneWidget);
    final trigger = tester.getRect(find.byType(Button));
    final note = tester.getRect(
      find.descendant(
        of: find.byType(PaperPopup),
        matching: find.byType(Paper),
      ),
    );
    expect(
      trigger.top - note.bottom,
      closeTo(Spacing.d1 + PopupPointer.tooltipSize.height, 0.01),
    );
    await mouse.moveTo(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsNothing);
    expect(changes, [true, false]);
  });

  testWidgets('waits for the delay', (tester) async {
    await tester.pumpWidget(
      overlayHost(_tooltip(delay: const Duration(milliseconds: 300))),
    );
    await _hover(tester, find.text('Add'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('Add to library'), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsOneWidget);
  });

  testWidgets('opens on keyboard focus and closes on Escape', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(overlayHost(_tooltip(focusNode: node)));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsNothing);
    expect(node.hasFocus, isTrue);
  });

  testWidgets('pressing the trigger closes it', (tester) async {
    await tester.pumpWidget(overlayHost(_tooltip()));
    final mouse = await _hover(tester, find.text('Add'));
    await tester.pumpAndSettle();
    await mouse.down(tester.getCenter(find.text('Add')));
    await mouse.up();
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsNothing);
  });

  testWidgets('a disabled tooltip never opens', (tester) async {
    await tester.pumpWidget(overlayHost(_tooltip(disabled: true)));
    await _hover(tester, find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Add to library'), findsNothing);
  });

  testWidgets('the trigger carries the note as its tooltip', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_tooltip()));
    final described = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.tooltip == 'Add to library',
    );
    expect(described, findsOneWidget);
    expect(
      tester.getSemantics(described).getSemanticsData().tooltip,
      'Add to library',
    );
    handle.dispose();
  });

  testWidgets('the provider skips the delay right after a close', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        TooltipProvider(
          delay: const Duration(milliseconds: 500),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d48,
            children: [
              for (final label in ['One', 'Two'])
                Tooltip(
                  content: TooltipContent(seed: label, child: Text('$label!')),
                  child: Text(label),
                ),
            ],
          ),
        ),
      ),
    );
    final mouse = await _hover(tester, find.text('One'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('One!'), findsOneWidget);
    await mouse.moveTo(tester.getCenter(find.text('Two')));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Two!'), findsOneWidget);
  });
}
