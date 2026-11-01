import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _card({
  Duration openDelay = HoverCard.defaultOpenDelay,
  Duration closeDelay = HoverCard.defaultCloseDelay,
  FocusNode? focusNode,
  ValueChanged<bool>? onOpenChange,
  bool? open,
}) => HoverCard(
  openDelay: openDelay,
  closeDelay: closeDelay,
  onOpenChange: onOpenChange,
  open: open,
  content: const HoverCardContent(
    seed: 'c',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HoverCardMedia(seed: 'm'),
        HoverCardCaption(Text('@looseleaf')),
      ],
    ),
  ),
  child: Button(
    variant: ButtonVariant.link,
    focusNode: focusNode,
    onPressed: () {},
    seed: 'b',
    child: const Text('Made by'),
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
  testWidgets('opens after the open delay, below the trigger', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(overlayHost(_card(onOpenChange: changes.add)));
    await _hover(tester, find.text('Made by'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.text('@looseleaf'), findsNothing);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsOneWidget);
    final trigger = tester.getRect(find.byType(Button));
    final card = tester.getRect(find.byType(PaperPopup));
    expect(card.top - trigger.bottom, closeTo(Spacing.d8, 0.01));
    expect(card.width, HoverCardContent.defaultWidth);
    expect(changes, [true]);
  });

  testWidgets('stays while the pointer is on the card', (tester) async {
    await tester.pumpWidget(overlayHost(_card(openDelay: Duration.zero)));
    final mouse = await _hover(tester, find.text('Made by'));
    await tester.pumpAndSettle();
    await mouse.moveTo(tester.getCenter(find.text('@looseleaf')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsOneWidget);
    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('@looseleaf'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsNothing);
  });

  testWidgets('opens on keyboard focus and closes on Escape', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      overlayHost(_card(focusNode: node, openDelay: Duration.zero)),
    );
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsOneWidget);
    expect(node.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsNothing);
    expect(node.hasFocus, isTrue);
  });

  testWidgets('touch never opens it', (tester) async {
    await tester.pumpWidget(overlayHost(_card(openDelay: Duration.zero)));
    await tester.tap(find.text('Made by'));
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsNothing);
  });

  testWidgets('a controlled card follows open', (tester) async {
    final open = ValueNotifier(true);
    addTearDown(open.dispose);
    await tester.pumpWidget(
      overlayHost(
        ValueListenableBuilder(
          valueListenable: open,
          builder: (context, value, _) => _card(open: value),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsOneWidget);
    open.value = false;
    await tester.pumpAndSettle();
    expect(find.text('@looseleaf'), findsNothing);
  });

  testWidgets('padding follows the density', (tester) async {
    Future<EdgeInsets> padding(LooseleafDensity density) async {
      await tester.pumpWidget(
        overlayHost(
          _card(open: true),
          theme: LooseleafThemeData(density: density),
        ),
      );
      await tester.pumpAndSettle();
      final paper = tester.widget<Paper>(
        find.descendant(
          of: find.byType(PaperPopup),
          matching: find.byType(Paper),
        ),
      );
      return paper.padding as EdgeInsets;
    }

    expect(
      await padding(LooseleafDensity.comfortable),
      const EdgeInsets.fromLTRB(10, 10, 10, 16),
    );
    expect(
      await padding(LooseleafDensity.calm),
      const EdgeInsets.all(Spacing.d8),
    );
  });

  testWidgets('the media window is 112 px tall', (tester) async {
    await tester.pumpWidget(overlayHost(_card(open: true)));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(HoverCardMedia)).height,
      HoverCardMedia.defaultHeight,
    );
  });
}
