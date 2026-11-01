import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _menu({
  String? value,
  ValueChanged<String?>? onValueChange,
  VoidCallback? onLink,
  bool viewport = true,
  List<FocusNode> nodes = const [],
}) => NavigationMenu(
  value: value,
  onValueChange: onValueChange,
  viewport: viewport,
  semanticLabel: 'Main',
  child: NavigationMenuList(
    children: [
      NavigationMenuItem(
        value: 'a',
        content: NavigationMenuContent(
          width: 200,
          child: NavigationMenuLink(
            onPressed: onLink,
            child: const Text('Intro'),
          ),
        ),
        child: NavigationMenuTrigger(
          focusNode: nodes.elementAtOrNull(0),
          seed: 'a',
          child: const Text('Alpha'),
        ),
      ),
      NavigationMenuItem(
        value: 'b',
        content: const NavigationMenuContent(
          width: 200,
          child: Text('Beta panel'),
        ),
        child: NavigationMenuTrigger(
          focusNode: nodes.elementAtOrNull(1),
          seed: 'b',
          child: const Text('Beta'),
        ),
      ),
      NavigationMenuItem(
        child: NavigationMenuLink(
          focusNode: nodes.elementAtOrNull(2),
          active: true,
          seed: 'docs',
          onPressed: () {},
          child: const Text('Docs'),
        ),
      ),
      const NavigationMenuIndicator(seed: 'u'),
    ],
  ),
);

Future<TestGesture> _mouse(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  return mouse;
}

List<FocusNode> _nodes() {
  final nodes = [FocusNode(), FocusNode(), FocusNode()];
  addTearDown(() {
    for (final node in nodes) {
      node.dispose();
    }
  });
  return nodes;
}

void _keyboard() {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
}

void main() {
  testWidgets('hover opens after the delay and leaving closes', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_menu()));
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Alpha')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Intro'), findsNothing);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsOneWidget);
    final strip = tester.getRect(find.byType(NavigationMenuList));
    final slip = tester.getRect(find.byType(PaperPopup));
    expect(slip.top - strip.bottom, closeTo(Spacing.d8, 0.01));
    expect(slip.left, closeTo(strip.left, 0.01));

    await mouse.moveTo(tester.getCenter(find.text('Beta')));
    await tester.pumpAndSettle();
    expect(find.text('Beta panel'), findsOneWidget);

    await mouse.moveTo(const Offset(1, 1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Beta panel'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpAndSettle();
    expect(find.text('Beta panel'), findsNothing);
  });

  testWidgets('a tap toggles and reports the value', (tester) async {
    final values = <String?>[];
    await tester.pumpWidget(overlayHost(_menu(onValueChange: values.add)));
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(values, ['a']);
    expect(find.text('Intro'), findsNothing);
  });

  testWidgets('follows a controlled value', (tester) async {
    final value = ValueNotifier<String?>(null);
    addTearDown(value.dispose);
    await tester.pumpWidget(
      overlayHost(
        ValueListenableBuilder(
          valueListenable: value,
          builder: (context, open, _) =>
              _menu(value: open, onValueChange: (next) => value.value = next),
        ),
      ),
    );
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsOneWidget);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsNothing);
  });

  testWidgets('Enter opens, Escape closes, focus stays on the trigger', (
    tester,
  ) async {
    final nodes = _nodes();
    await tester.pumpWidget(overlayHost(_menu(nodes: nodes)));
    _keyboard();
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsNothing);
    expect(nodes[0].hasFocus, isTrue);
  });

  testWidgets('arrows walk the tabs and follow the reading direction', (
    tester,
  ) async {
    final nodes = _nodes();
    await tester.pumpWidget(overlayHost(_menu(nodes: nodes)));
    _keyboard();
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(nodes[2].hasFocus, isTrue);
  });

  testWidgets('right to left, Left walks forward', (tester) async {
    final nodes = _nodes();
    await tester.pumpWidget(
      overlayHost(
        Directionality(
          textDirection: TextDirection.rtl,
          child: _menu(nodes: nodes),
        ),
      ),
    );
    _keyboard();
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(nodes[1].hasFocus, isTrue);
    expect(
      tester.getCenter(find.text('Beta')).dx,
      lessThan(tester.getCenter(find.text('Alpha')).dx),
    );
  });

  testWidgets('Down steps into the open panel; a link closes it', (
    tester,
  ) async {
    final nodes = _nodes();
    var followed = 0;
    await tester.pumpWidget(
      overlayHost(_menu(nodes: nodes, onLink: () => followed++)),
    );
    _keyboard();
    nodes[0].requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Intro'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(nodes[0].hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(followed, 1);
    expect(find.text('Intro'), findsNothing);
  });

  testWidgets('a panel of its own without the viewport', (tester) async {
    await tester.pumpWidget(overlayHost(_menu(viewport: false)));
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(find.text('Beta panel'), findsOneWidget);
    final tab = tester.getRect(
      find.ancestor(
        of: find.text('Beta'),
        matching: find.byType(NavigationMenuTab),
      ),
    );
    final slip = tester.getRect(find.byType(PaperPopup));
    expect(slip.left, closeTo(tab.left, 0.01));
    expect(slip.top - tab.bottom, closeTo(Spacing.d8, 2.5));
  });

  testWidgets('the indicator slides under the open tab', (tester) async {
    await tester.pumpWidget(overlayHost(_menu()));
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    final tab = tester.getRect(
      find.ancestor(
        of: find.text('Beta'),
        matching: find.byType(NavigationMenuTab),
      ),
    );
    final mark = tester.getRect(
      find.descendant(
        of: find.byType(NavigationMenuIndicator),
        matching: find.byType(InkArt),
      ),
    );
    expect(mark.left, closeTo(tab.left, 0.01));
    expect(mark.width, closeTo(tab.width, 0.01));
  });

  testWidgets('semantics: expanded triggers and the current link', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_menu()));
    expect(
      tester.getSemantics(find.byType(NavigationMenuTrigger).first),
      matchesSemantics(
        label: 'Alpha',
        isButton: true,
        hasExpandedState: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(NavigationMenuLink)),
      matchesSemantics(
        label: 'Docs',
        isLink: true,
        hasSelectedState: true,
        isSelected: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('tabs are 36, 32 and 28 high by density', (tester) async {
    for (final (density, height) in [
      (LooseleafDensity.comfortable, Spacing.d36),
      (LooseleafDensity.compact, Spacing.d32),
      (LooseleafDensity.calm, Spacing.d28),
    ]) {
      await tester.pumpWidget(
        overlayHost(_menu(), theme: LooseleafThemeData(density: density)),
      );
      await tester.pump();
      expect(
        tester.getSize(find.byType(NavigationMenuTab).first).height,
        height,
      );
    }
  });
}
