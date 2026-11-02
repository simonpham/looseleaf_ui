import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

Widget _palette({
  ValueChanged<String>? onSelect,
  bool loop = false,
  bool shouldFilter = true,
}) => SizedBox(
  width: 352,
  child: Command(
    loop: loop,
    shouldFilter: shouldFilter,
    seed: 'palette',
    children: [
      const CommandInput(placeholder: 'Type a command or search...'),
      CommandList(
        children: [
          const CommandEmpty(child: Text('No results found.')),
          CommandGroup(
            heading: const Text('Suggestions'),
            children: [
              CommandItem(onSelect: onSelect, child: const Text('Calendar')),
              CommandItem(
                onSelect: onSelect,
                keywords: const ['smiley'],
                child: const Text('Search Emoji'),
              ),
              CommandItem(
                onSelect: onSelect,
                disabled: true,
                child: const Text('Calculator'),
              ),
            ],
          ),
          const CommandSeparator(),
          CommandGroup(
            heading: const Text('Settings'),
            children: [
              CommandItem(
                onSelect: onSelect,
                trailing: const CommandShortcut('Ctrl P'),
                child: const Text('Profile'),
              ),
              CommandItem(onSelect: onSelect, child: const Text('Billing')),
            ],
          ),
        ],
      ),
    ],
  ),
);

CommandController _controller(WidgetTester tester) =>
    CommandScope.of(tester.element(find.byType(CommandInput)));

void main() {
  testWidgets('highlights the first row and focuses the search', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_palette()));
    await tester.pumpAndSettle();
    expect(_controller(tester).highlighted, 'Calendar');
    expect(_controller(tester).inputFocus.hasFocus, isTrue);
  });

  testWidgets('typing filters rows, hides empty groups and separators', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_palette()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'cal');
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
    expect(find.text('Settings'), findsNothing);
    expect(find.byType(Separator), findsNothing);
    expect(_controller(tester).count, 2);
    await tester.enterText(find.byType(EditableText), 'smiley');
    await tester.pumpAndSettle();
    expect(find.text('Search Emoji'), findsOneWidget);
    expect(_controller(tester).highlighted, 'Search Emoji');
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('No results found.'), findsOneWidget);
    expect(find.byType(Mascot), findsOneWidget);
  });

  testWidgets('arrows skip disabled rows, Home, End and Enter choose', (
    tester,
  ) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_palette(onSelect: chosen.add)));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Search Emoji');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Profile');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Billing');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Billing');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Calendar');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Search Emoji');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(chosen, ['Search Emoji']);
  });

  testWidgets('loop wraps at the ends', (tester) async {
    await tester.pumpWidget(overlayHost(_palette(loop: true)));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_controller(tester).highlighted, 'Billing');
  });

  testWidgets('taps choose, hovers highlight, disabled rows do neither', (
    tester,
  ) async {
    final chosen = <String>[];
    await tester.pumpWidget(overlayHost(_palette(onSelect: chosen.add)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.tap(find.text('Calculator'));
    await tester.pump();
    expect(chosen, ['Profile']);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Billing')));
    await tester.pump();
    expect(_controller(tester).highlighted, 'Billing');
  });

  testWidgets('shouldFilter false keeps every row', (tester) async {
    await tester.pumpWidget(overlayHost(_palette(shouldFilter: false)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Billing'), findsOneWidget);
    expect(find.text('No results found.'), findsNothing);
  });

  testWidgets('a controlled search follows its value', (tester) async {
    final typed = <String>[];
    Widget build(String query) => Command(
      children: [
        CommandInput(value: query, onValueChange: typed.add),
        const CommandList(
          children: [
            CommandItem(child: Text('Apple')),
            CommandItem(child: Text('Banana')),
          ],
        ),
      ],
    );
    await tester.pumpWidget(overlayHost(build('ban')));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsNothing);
    await tester.enterText(find.byType(EditableText), 'a');
    expect(typed, ['a']);
  });

  testWidgets('the status counts results for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(_palette()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'cal');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('2 results'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Calendar')),
      matchesSemantics(
        label: 'Calendar',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('rows and the search follow the density', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        _palette(),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(CommandInput)).height,
      CommandMetrics.inputHeight.calm,
    );
  });

  testWidgets('CommandDialog opens on its state and gives focus back', (
    tester,
  ) async {
    final opener = FocusNode();
    addTearDown(opener.dispose);
    var open = false;
    late StateSetter set;
    await tester.pumpWidget(
      overlayHost(
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return CommandDialog(
              open: open,
              onOpenChange: (value) => setState(() => open = value),
              children: const [
                CommandInput(placeholder: 'Search'),
                CommandList(
                  children: [CommandItem(child: Text('Calendar'))],
                ),
              ],
              child: Focus(focusNode: opener, child: const Text('Anchor')),
            );
          },
        ),
      ),
    );
    opener.requestFocus();
    await tester.pump();
    set(() => open = true);
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
    expect(
      CommandScope.of(tester.element(find.byType(CommandInput)))
          .inputFocus
          .hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsNothing);
    expect(open, isFalse);
    expect(opener.hasFocus, isTrue);
  });

  testWidgets('CommandDialog sits 12 % down, 8 px on phones', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget palette() => overlayHost(
      const CommandDialog(
        defaultOpen: true,
        children: [
          CommandInput(placeholder: 'Search'),
          CommandList(children: [CommandItem(child: Text('Calendar'))]),
        ],
      ),
    );
    await tester.pumpWidget(palette());
    await tester.pumpAndSettle();
    final sheet = tester.getRect(find.byType(DialogContent));
    expect(sheet.top, Spacing.d16 + 600 * 0.12);
    expect(sheet.center.dx, 400);

    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    final phone = tester.getRect(find.byType(DialogContent));
    expect(phone.top, Spacing.d8);
    expect(phone.width, 400);
  });

  testWidgets('a new search highlights its best row at once', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_palette()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'bi');
    await tester.pump();
    expect(_controller(tester).highlighted, 'Billing');
    await tester.enterText(find.byType(EditableText), 'emoji');
    await tester.pump();
    expect(_controller(tester).highlighted, 'Search Emoji');
  });

  testWidgets('a better match moves above an earlier row', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        const SizedBox(
          width: 352,
          child: Command(
            children: [
              CommandInput(),
              CommandList(
                children: [
                  CommandItem(child: Text('Escape')),
                  CommandItem(child: Text('Calendar')),
                  CommandGroup(
                    heading: Text('Later'),
                    children: [
                      CommandItem(child: Text('Scan')),
                      CommandItem(child: Text('Cards')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'ca');
    await tester.pumpAndSettle();
    double top(String text) => tester.getRect(find.text(text)).top;
    expect(top('Calendar'), lessThan(top('Escape')));
    expect(top('Escape'), lessThan(top('Later')));
    expect(top('Cards'), lessThan(top('Scan')));
    expect(_controller(tester).highlighted, 'Calendar');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(_controller(tester).highlighted, 'Escape');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    expect(_controller(tester).highlighted, 'Cards');
  });
}
