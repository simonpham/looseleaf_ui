import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';
import '../../support/semantics_matchers.dart';

InkMenuRow _row(WidgetTester tester, String label) => tester.widget(
  find.ancestor(of: find.text(label), matching: find.byType(InkMenuRow)),
);

bool _lit(WidgetTester tester, String label) => _row(tester, label).highlighted;

class _Log {
  final List<String> chosen = [];
  final List<bool> opens = [];
}

Widget _menu(
  _Log log, {
  bool checked = false,
  ValueChanged<bool>? onChecked,
  String radio = 'top',
  ValueChanged<String>? onRadio,
  TextDirection direction = TextDirection.ltr,
  FocusNode? trigger,
}) => Directionality(
  textDirection: direction,
  child: DropdownMenu(
    onOpenChange: log.opens.add,
    content: DropdownMenuContent(
      seed: 'menu',
      children: [
        const DropdownMenuLabel(child: Text('Account')),
        DropdownMenuItem(
          onSelect: () => log.chosen.add('Profile'),
          trailing: const DropdownMenuShortcut('⇧⌘P'),
          child: const Text('Profile'),
        ),
        DropdownMenuItem(
          disabled: true,
          onSelect: () => log.chosen.add('Billing'),
          child: const Text('Billing'),
        ),
        DropdownMenuItem(
          onSelect: () => log.chosen.add('Settings'),
          child: const Text('Settings'),
        ),
        const DropdownMenuSeparator(),
        DropdownMenuCheckboxItem(
          value: checked,
          onChanged: onChecked,
          closeOnSelect: false,
          child: const Text('Status bar'),
        ),
        DropdownMenuRadioGroup(
          value: radio,
          onChanged: onRadio,
          children: const [
            DropdownMenuRadioItem(value: 'top', child: Text('Top')),
            DropdownMenuRadioItem(value: 'bottom', child: Text('Bottom')),
          ],
        ),
        DropdownMenuSub(
          trigger: const DropdownMenuSubTrigger(child: Text('Team')),
          content: DropdownMenuSubContent(
            children: [
              DropdownMenuItem(
                onSelect: () => log.chosen.add('Email'),
                child: const Text('Email'),
              ),
              const DropdownMenuItem(child: Text('Message')),
            ],
          ),
        ),
      ],
    ),
    child: DropdownMenuTrigger(focusNode: trigger, child: const Text('Open')),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a tap opens the slip with no row highlighted', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    expect(find.text('Profile'), findsNothing);
    await _open(tester);
    expect(find.text('Profile'), findsOneWidget);
    expect(log.opens, [true]);
    expect(_lit(tester, 'Profile'), isFalse);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_lit(tester, 'Profile'), isTrue);
    expect(_row(tester, 'Profile').focusVisible, isTrue);
  });

  testWidgets('Down on the trigger opens with the first row lit', (
    tester,
  ) async {
    final log = _Log();
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    await tester.pumpWidget(overlayHost(_menu(log, trigger: trigger)));
    trigger.requestFocus();
    await tester.pump();
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_lit(tester, 'Profile'), isTrue);
  });

  testWidgets('arrows skip disabled rows; Enter chooses and closes', (
    tester,
  ) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_lit(tester, 'Settings'), isTrue);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(_lit(tester, 'Profile'), isTrue);
    await _key(tester, LogicalKeyboardKey.arrowUp);
    expect(_lit(tester, 'Profile'), isTrue, reason: 'no loop by default');
    await _key(tester, LogicalKeyboardKey.end);
    expect(_lit(tester, 'Team'), isTrue);
    await _key(tester, LogicalKeyboardKey.home);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(log.chosen, ['Profile']);
    expect(find.text('Profile'), findsNothing);
    expect(log.opens, [true, false]);
  });

  testWidgets('taps choose; disabled rows ignore them', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    await tester.tap(find.text('Billing'));
    await tester.pumpAndSettle();
    expect(log.chosen, isEmpty);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(log.chosen, ['Settings']);
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('typing finds a row', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS, character: 's');
    await tester.pumpAndSettle();
    expect(_lit(tester, 'Settings'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS, character: 's');
    await tester.pumpAndSettle();
    expect(_lit(tester, 'Status bar'), isTrue);
  });

  testWidgets('Escape closes and focus goes back to the trigger', (
    tester,
  ) async {
    final log = _Log();
    final trigger = FocusNode();
    addTearDown(trigger.dispose);
    await tester.pumpWidget(overlayHost(_menu(log, trigger: trigger)));
    trigger.requestFocus();
    await tester.pump();
    await _key(tester, LogicalKeyboardKey.enter);
    expect(_lit(tester, 'Profile'), isTrue);
    expect(trigger.hasFocus, isFalse);
    await _key(tester, LogicalKeyboardKey.escape);
    expect(find.text('Profile'), findsNothing);
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('a tick row toggles and keeps the menu open', (tester) async {
    final log = _Log();
    var checked = false;
    await tester.pumpWidget(
      overlayHost(
        StatefulBuilder(
          builder: (context, setState) => _menu(
            log,
            checked: checked,
            onChecked: (value) => setState(() => checked = value),
          ),
        ),
      ),
    );
    await _open(tester);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Status bar'),
          matching: find.byType(InkMenuRow),
        ),
        matching: find.byType(InkMarkWipe),
      ),
      findsNothing,
    );
    await tester.tap(find.text('Status bar'));
    await tester.pumpAndSettle();
    expect(checked, isTrue);
    expect(find.text('Status bar'), findsOneWidget);
    final indicator = tester.widget<InkMenuIndicator>(
      find.byType(InkMenuIndicator).first,
    );
    expect(indicator.on, isTrue);
  });

  testWidgets('a radio row hands its value to the group', (tester) async {
    final log = _Log();
    String? chosen;
    await tester.pumpWidget(
      overlayHost(_menu(log, onRadio: (value) => chosen = value)),
    );
    await _open(tester);
    await tester.tap(find.text('Bottom'));
    await tester.pumpAndSettle();
    expect(chosen, 'bottom');
    expect(find.text('Bottom'), findsNothing);
  });

  testWidgets('Right opens a sub-menu, Left closes it', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    await _key(tester, LogicalKeyboardKey.end);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_lit(tester, 'Email'), isTrue);
    expect(_lit(tester, 'Team'), isTrue, reason: 'it keeps the highlighter');
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_lit(tester, 'Message'), isTrue);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Email'), findsNothing);
    expect(_lit(tester, 'Team'), isTrue);
    await _key(tester, LogicalKeyboardKey.enter);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(log.chosen, ['Email']);
    expect(find.text('Team'), findsNothing);
  });

  testWidgets('Escape in a sub-menu closes the whole menu', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    await _key(tester, LogicalKeyboardKey.end);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    await _key(tester, LogicalKeyboardKey.escape);
    expect(find.text('Email'), findsNothing);
    expect(find.text('Team'), findsNothing);
  });

  testWidgets('hovering highlights rows and opens a sub-menu', (
    tester,
  ) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('Settings')));
    await tester.pumpAndSettle();
    expect(_lit(tester, 'Settings'), isTrue);
    expect(_row(tester, 'Settings').focusVisible, isFalse);
    await mouse.moveTo(tester.getCenter(find.text('Team')));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpAndSettle();
    expect(find.text('Email'), findsOneWidget);
    await mouse.moveTo(tester.getCenter(find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.text('Email'), findsNothing);
  });

  testWidgets('a sub-menu opens on the left in right-to-left', (
    tester,
  ) async {
    final log = _Log();
    await tester.pumpWidget(
      overlayHost(_menu(log, direction: TextDirection.rtl)),
    );
    await _open(tester);
    await _key(tester, LogicalKeyboardKey.end);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Email'), findsNothing);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Email'), findsOneWidget);
    expect(
      tester.getCenter(find.text('Email')).dx,
      lessThan(tester.getTopLeft(find.text('Team')).dx),
    );
  });

  testWidgets('rows are announced as menu items', (tester) async {
    final handle = tester.ensureSemantics();
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    expect(
      tester.getSemantics(find.text('Settings')),
      includesSemantics(role: SemanticsRole.menuItem, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.text('Billing')),
      includesSemantics(role: SemanticsRole.menuItem, isEnabled: false),
    );
    expect(
      tester.getSemantics(find.text('Status bar')),
      includesSemantics(
        role: SemanticsRole.menuItemCheckbox,
        isChecked: false,
        hasCheckedState: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Top')),
      includesSemantics(
        role: SemanticsRole.menuItemRadio,
        isChecked: true,
        hasCheckedState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('rows are 32 px, 28 compact', (tester) async {
    final log = _Log();
    await tester.pumpWidget(overlayHost(_menu(log)));
    await _open(tester);
    expect(
      tester.getSize(find.byType(InkMenuRow).at(1)).height,
      Spacing.d32,
    );
    await _key(tester, LogicalKeyboardKey.escape);
    await tester.pumpWidget(
      overlayHost(
        _menu(log),
        theme: const LooseleafThemeData(density: LooseleafDensity.compact),
      ),
    );
    await _open(tester);
    expect(
      tester.getSize(find.byType(InkMenuRow).at(1)).height,
      Spacing.d28,
    );
  });

  test('shortcuts parse like upstream', () {
    List<String> texts(String s) => [
      for (final key in InkMenuShortcut.parse(s)) key.text,
    ];
    expect(texts('⇧⌘P'), ['Shift', 'Command', 'P']);
    expect(texts('Ctrl+K'), ['Ctrl', 'K']);
    expect(texts('F2'), ['F2']);
    expect(texts('g g'), ['g', 'g']);
    expect(InkMenuShortcut.parse('⌘S').first.icon, 'command');
    expect(texts('  '), isEmpty);
  });
}
