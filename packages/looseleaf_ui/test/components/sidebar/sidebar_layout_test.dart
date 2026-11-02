import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1024, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(child));
  await tester.pumpAndSettle();
}

Widget _row(String label) => SidebarMenuItem(
  child: SidebarMenuButton(onPressed: () {}, child: Text(label)),
);

void main() {
  testWidgets('a menu sets its rows the gap apart, 4 px by default', (
    tester,
  ) async {
    for (final (gap, expected) in [(null, Spacing.d4), (Spacing.d8, 8.0)]) {
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: switch (gap) {
            final gap? => SidebarMenu(
              gap: gap,
              children: [_row('A'), _row('B')],
            ),
            null => SidebarMenu(children: [_row('A'), _row('B')]),
          },
        ),
      );
      final first = tester.getRect(find.byType(SidebarMenuButton).first);
      final second = tester.getRect(find.byType(SidebarMenuButton).last);
      expect(second.top - first.bottom, expected);
    }
  });

  testWidgets('a group takes its padding, 8 px all round by default', (
    tester,
  ) async {
    for (final (padding, inset) in [
      (null, const EdgeInsets.all(Spacing.d8)),
      (
        const EdgeInsets.symmetric(vertical: Spacing.d8),
        const EdgeInsets.symmetric(vertical: Spacing.d8),
      ),
    ]) {
      const label = SizedBox(key: Key('label'), height: 20);
      await _pump(
        tester,
        SizedBox(
          width: 240,
          child: switch (padding) {
            final padding? => SidebarGroup(
              padding: padding,
              children: const [label],
            ),
            null => const SidebarGroup(children: [label]),
          },
        ),
      );
      final group = tester.getRect(find.byType(SidebarGroup));
      final child = tester.getRect(find.byKey(const Key('label')));
      expect(child.left - group.left, inset.left);
      expect(child.top - group.top, inset.top);
    }
  });
}
