import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const Key _field = Key('field');

Widget _popover({
  PopoverContent content = const PopoverContent(
    seed: 'p',
    child: Text('Inside'),
  ),
  bool modal = false,
  ValueChanged<bool>? onOpenChange,
}) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Popover(
      modal: modal,
      onOpenChange: onOpenChange,
      content: content,
      child: PopoverTrigger.builder(
        builder: (context, popover) => Button(
          onPressed: popover.toggle,
          seed: 'trigger',
          child: const Text('Open'),
        ),
      ),
    ),
    const SizedBox(height: 200),
    const Text('Elsewhere'),
  ],
);

void main() {
  testWidgets('opens below the trigger and closes on a second press', (
    tester,
  ) async {
    final changes = <bool>[];
    await tester.pumpWidget(overlayHost(_popover(onOpenChange: changes.add)));
    expect(find.text('Inside'), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsOneWidget);
    final trigger = tester.getRect(find.byType(Button));
    final paper = tester.getRect(find.byType(PaperPopup));
    expect(paper.top - trigger.bottom, closeTo(Spacing.d8, 0.01));
    expect(paper.center.dx, closeTo(trigger.center.dx, 0.01));
    expect(paper.width, PopoverContent.defaultWidth);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
    expect(changes, [true, false]);
  });

  testWidgets('Escape and an outside tap close it', (tester) async {
    await tester.pumpWidget(overlayHost(_popover()));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elsewhere'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
  });

  testWidgets('focus moves in on open and back to the trigger on Escape', (
    tester,
  ) async {
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    await tester.pumpWidget(
      overlayHost(
        Popover(
          content: const PopoverContent(
            seed: 'f',
            child: Input(key: _field, placeholder: 'Width'),
          ),
          child: PopoverTrigger.builder(
            builder: (context, popover) => Button(
              focusNode: trigger,
              onPressed: popover.toggle,
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    final field = find.descendant(
      of: find.byKey(_field),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(field).focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Width'), findsNothing);
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('flips above when there is no room below', (tester) async {
    tester.view.physicalSize = const Size(600, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      overlayHost(
        Align(
          alignment: Alignment.bottomCenter,
          child: Popover(
            defaultOpen: true,
            content: const PopoverContent(
              seed: 'flip',
              arrow: true,
              child: SizedBox(height: 80),
            ),
            child: PopoverTrigger.builder(
              builder: (context, popover) => Button(
                onPressed: popover.toggle,
                child: const Text('Low'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final trigger = tester.getRect(find.byType(Button));
    final paper = tester.getRect(
      find.descendant(
        of: find.byType(PaperPopup),
        matching: find.byType(Paper),
      ),
    );
    expect(paper.bottom, lessThan(trigger.top));
    final pointer = tester.widget<PopupPointer>(find.byType(PopupPointer));
    expect(pointer.side, OverlaySide.top);
    expect(
      trigger.top - paper.bottom,
      closeTo(Spacing.d8 + PopupPointer.popoverSize.height, 0.01),
    );
  });

  testWidgets('a modal popover blocks the app behind it', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      overlayHost(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _popover(modal: true),
            GestureDetector(
              onTap: () => tapped++,
              child: const Text('Behind'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(OverlayScrim), findsOneWidget);
    await tester.tap(find.text('Behind'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(tapped, 0);
    expect(find.text('Inside'), findsNothing);
  });

  testWidgets('a plain trigger toggles on tap and Enter and reports expanded', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      overlayHost(
        const Popover(
          content: PopoverContent(seed: 'k', child: Text('Inside')),
          child: PopoverTrigger(child: Text('Plain')),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('Plain')),
      matchesSemantics(
        label: 'Plain',
        isButton: true,
        hasExpandedState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await tester.tap(find.text('Plain'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsOneWidget);
    await tester.tap(find.text('Plain'));
    await tester.pumpAndSettle();
    expect(find.text('Inside'), findsNothing);
    handle.dispose();
  });

  testWidgets('padding follows density', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        const Popover(
          defaultOpen: true,
          content: PopoverContent(
            seed: 'd',
            width: null,
            child: SizedBox(width: 50, height: 20),
          ),
          child: SizedBox(width: 40, height: 20),
        ),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(PaperPopup)),
      const Size(50 + 2 * Spacing.d12, 20 + 2 * Spacing.d12),
    );
  });
}
