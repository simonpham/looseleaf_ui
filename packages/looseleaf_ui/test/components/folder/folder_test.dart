import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/semantics_matchers.dart';

Widget _folder({
  String? value,
  ValueChanged<String>? onValueChange,
  LooseleafThemeData theme = const LooseleafThemeData(),
  bool afterStop = false,
}) => componentHost(
  Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (afterStop)
        const Focus(autofocus: true, child: SizedBox.square(dimension: 8)),
      Folder(
        defaultValue: 'inbox',
        value: value,
        onValueChange: onValueChange,
        children: const [
          FolderTabs(
            semanticLabel: 'Mail',
            children: [
              FolderTab(value: 'inbox', child: Text('Inbox')),
              FolderTab(value: 'drafts', child: Text('Drafts')),
              FolderTab(
                value: 'archive',
                disabled: true,
                child: Text('Archive'),
              ),
              FolderTab(value: 'sent', child: Text('Sent')),
            ],
          ),
          FolderContent(value: 'inbox', child: Text('Three letters')),
          FolderContent(value: 'drafts', child: Text('Two drafts')),
          FolderContent(value: 'sent', child: Text('Nothing yet')),
        ],
      ),
    ],
  ),
  theme: theme,
);

Set<InkState> _states(WidgetTester tester, String label) => tester
    .widget<InkSurface>(
      find.ancestor(of: find.text(label), matching: find.byType(InkSurface)),
    )
    .states;

void main() {
  testWidgets('opens the default tab and only its panel', (tester) async {
    await tester.pumpWidget(_folder());
    expect(find.text('Three letters'), findsOneWidget);
    expect(find.text('Two drafts'), findsNothing);
    expect(_states(tester, 'Inbox'), contains(InkState.checked));
    expect(_states(tester, 'Drafts'), isNot(contains(InkState.checked)));
  });

  testWidgets('a tap opens a tab; a disabled one does nothing', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(_folder(onValueChange: opened.add));
    await tester.tap(find.text('Drafts'));
    await tester.pump();
    expect(find.text('Two drafts'), findsOneWidget);
    await tester.tap(find.text('Archive'), warnIfMissed: false);
    await tester.pump();
    expect(opened, ['drafts']);
  });

  testWidgets('controlled: value wins until the parent changes it', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(_folder(value: 'sent', onValueChange: opened.add));
    expect(find.text('Nothing yet'), findsOneWidget);
    await tester.tap(find.text('Inbox'));
    await tester.pump();
    expect(opened, ['inbox']);
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  testWidgets('arrows move and open, skipping disabled; Home and End jump', (
    tester,
  ) async {
    await tester.pumpWidget(_folder(afterStop: true));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_states(tester, 'Inbox'), contains(InkState.focused));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('Two drafts'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('Nothing yet'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(find.text('Three letters'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(find.text('Nothing yet'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  testWidgets('the open tab hides its hover sheen', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Folder(
          defaultValue: 'a',
          children: [
            FolderTabs(
              children: [
                FolderTab(
                  value: 'a',
                  forcedStates: {InkState.hovered},
                  child: Text('A'),
                ),
                FolderTab(
                  value: 'b',
                  forcedStates: {InkState.hovered},
                  child: Text('B'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(_states(tester, 'A'), {InkState.checked});
    expect(_states(tester, 'B'), {InkState.hovered});
  });

  testWidgets('tabs are 36 / 32 / 28 high per density', (tester) async {
    for (final (density, height) in [
      (LooseleafDensity.comfortable, 36.0),
      (LooseleafDensity.compact, 32.0),
      (LooseleafDensity.calm, 28.0),
    ]) {
      await tester.pumpWidget(
        _folder(theme: LooseleafThemeData(density: density)),
      );
      final tab = find.ancestor(
        of: find.text('Drafts'),
        matching: find.byType(InkSurface),
      );
      expect(tester.getSize(tab).height, height);
    }
  });

  testWidgets('the body sits under the tabs, its panel padded', (
    tester,
  ) async {
    await tester.pumpWidget(_folder());
    final paper = tester.getRect(find.byType(Paper));
    final tab = tester.getRect(
      find.ancestor(of: find.text('Inbox'), matching: find.byType(InkSurface)),
    );
    expect(tab.bottom, paper.top);
    expect(tab.left - paper.left, 16);
    expect(paper.height, 160);
    expect(
      tester.getTopLeft(find.text('Three letters')) - paper.topLeft,
      const Offset(24, 32),
    );
    expect(tester.widget<Paper>(find.byType(Paper)).stock, StockName.kraft);
  });

  testWidgets('tablist, tabs and panel semantics', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_folder());
    expect(
      tester.getSemantics(
        find.descendant(
          of: find.byType(FolderTabs),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.role == SemanticsRole.tabBar,
          ),
        ),
      ),
      allOf(
        includesSemantics(role: SemanticsRole.tabBar),
        matchesSemantics(label: 'Mail'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(FolderTab).first),
      allOf(
        includesSemantics(role: SemanticsRole.tab),
        matchesSemantics(
          label: 'Inbox',
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      ),
    );
    expect(
      tester.getSemantics(
        find.ancestor(
          of: find.text('Three letters'),
          matching: find.byType(FolderContent),
        ),
      ),
      allOf(
        includesSemantics(role: SemanticsRole.tabPanel),
        matchesSemantics(
          label: 'Three letters',
          isFocusable: true,
          hasFocusAction: true,
        ),
      ),
    );
    handle.dispose();
  });

  testWidgets('tabs wider than the folder scroll, and a focused tab shows', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(autofocus: true, child: SizedBox.square(dimension: 8)),
            SizedBox(
              width: 220,
              child: Folder(
                defaultValue: 'a',
                children: [
                  FolderTabs(
                    children: [
                      FolderTab(value: 'a', child: Text('Sketches')),
                      FolderTab(value: 'b', child: Text('Notes')),
                      FolderTab(value: 'c', child: Text('Photographs')),
                    ],
                  ),
                  FolderContent(value: 'a', child: Text('first')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    final folder = tester.getRect(find.byType(Folder));
    expect(
      tester.getRect(find.text('Photographs')).right,
      greaterThan(folder.right),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('Photographs')).right,
      lessThanOrEqualTo(folder.right),
    );
  });

  testWidgets('tabs and panels take their own padding', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Folder(
            defaultValue: 'a',
            children: [
              FolderTabs(
                children: [
                  Expanded(
                    child: FolderTab(
                      value: 'a',
                      inlinePadding: 6,
                      child: Text('Sketches'),
                    ),
                  ),
                ],
              ),
              FolderContent(
                value: 'a',
                padding: EdgeInsets.fromLTRB(16, 32, 16, 24),
                child: Text('first'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final tab = tester.getRect(find.byType(FolderTab));
    expect(tab.width, 300 - 2 * Spacing.d16);
    final body = tester.getRect(find.byType(Paper));
    expect(
      tester.getTopLeft(find.text('first')) - body.topLeft,
      const Offset(16, 32),
    );
  });
}
