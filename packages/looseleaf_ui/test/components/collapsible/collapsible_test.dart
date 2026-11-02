import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _collapsible({
  bool? open,
  bool defaultOpen = false,
  ValueChanged<bool>? onOpenChange,
  bool disabled = false,
  BracketKind? bracket,
  FocusNode? focusNode,
}) => Collapsible(
  open: open,
  defaultOpen: defaultOpen,
  onOpenChange: onOpenChange,
  disabled: disabled,
  child: SizedBox(
    width: 300,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CollapsibleTrigger(
          focusNode: focusNode,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Toggle'), CollapsibleIndicator()],
          ),
        ),
        CollapsibleContent(bracket: bracket, child: const Text('Hidden')),
      ],
    ),
  ),
);

void main() {
  testWidgets('the trigger opens and shuts the content', (tester) async {
    await tester.pumpWidget(componentHost(_collapsible()));
    expect(find.text('Hidden'), findsNothing);
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final half = tester.getSize(find.byType(CollapsibleFold)).height;
    await tester.pumpAndSettle();
    final full = tester.getSize(find.byType(CollapsibleFold)).height;
    expect(half, inExclusiveRange(0, full));
    expect(find.text('Hidden'), findsOneWidget);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('Enter and Space toggle; disabled ignores input', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    final changes = <bool>[];
    await tester.pumpWidget(
      componentHost(
        _collapsible(focusNode: focusNode, onOpenChange: changes.add),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(changes, [true, false]);
    await tester.pumpWidget(
      componentHost(_collapsible(disabled: true, onOpenChange: changes.add)),
    );
    await tester.tap(find.text('Toggle'), warnIfMissed: false);
    expect(changes, [true, false]);
  });

  testWidgets('controlled open wins over taps', (tester) async {
    final changes = <bool>[];
    await tester.pumpWidget(
      componentHost(_collapsible(open: true, onOpenChange: changes.add)),
    );
    expect(find.text('Hidden'), findsOneWidget);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(changes, [false]);
    expect(find.text('Hidden'), findsOneWidget);
  });

  testWidgets('the trigger reports expanded to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_collapsible(defaultOpen: true)));
    expect(
      tester.getSemantics(find.byType(CollapsibleTrigger)),
      matchesSemantics(
        label: 'Toggle',
        isButton: true,
        hasExpandedState: true,
        isExpanded: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a Button built by the trigger reports expanded on its node', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        Collapsible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CollapsibleTrigger.builder(
                builder: (context, collapsible) => Button(
                  onPressed: collapsible.toggle,
                  child: const Text('Toggle'),
                ),
              ),
              const CollapsibleContent(child: Text('Hidden')),
            ],
          ),
        ),
      ),
    );
    Matcher button({required bool expanded}) => matchesSemantics(
      label: 'Toggle',
      isButton: true,
      hasExpandedState: true,
      isExpanded: expanded,
      hasEnabledState: true,
      isEnabled: true,
      isFocusable: true,
      hasTapAction: true,
      hasFocusAction: true,
    );
    expect(
      tester.getSemantics(find.byType(Button)),
      button(expanded: false),
    );
    await tester.tap(find.byType(Button));
    await tester.pumpAndSettle();
    expect(find.text('Hidden'), findsOneWidget);
    expect(tester.getSemantics(find.byType(Button)), button(expanded: true));
    handle.dispose();
  });

  testWidgets('a bracket draws on once the user opens it', (tester) async {
    await tester.pumpWidget(
      componentHost(
        _collapsible(defaultOpen: true, bracket: BracketKind.curly),
      ),
    );
    expect(
      tester.widget<InkMarkSurface>(find.byType(InkMarkSurface)).animate,
      isFalse,
    );
    expect(
      tester.getTopLeft(find.text('Hidden')).dx -
          tester.getTopLeft(find.byType(CollapsibleBracket)).dx,
      20,
    );
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    expect(
      tester.widget<InkMarkSurface>(find.byType(InkMarkSurface)).animate,
      isTrue,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('the indicator turns over when open', (tester) async {
    await tester.pumpWidget(componentHost(_collapsible(defaultOpen: true)));
    await tester.pumpAndSettle();
    final turn = tester.widget<Transform>(
      find.descendant(
        of: find.byType(CollapsibleIndicator),
        matching: find.byType(Transform),
      ),
    );
    expect(turn.transform.getRotation().entry(0, 0), closeTo(-1, 1e-6));
  });
}
