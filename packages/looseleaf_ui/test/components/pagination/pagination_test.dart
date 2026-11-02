import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/semantics_matchers.dart';

Widget _pages({required ValueChanged<int> go, int page = 2}) => Pagination(
  child: PaginationContent(
    children: [
      PaginationPrevious(onPressed: () => go(page - 1), disabled: page == 1),
      for (final number in [1, 2, 3])
        PaginationLink(
          isActive: number == page,
          onPressed: () => go(number),
          child: Text('$number'),
        ),
      const PaginationEllipsis(),
      PaginationNext(onPressed: () => go(page + 1)),
    ],
  ),
);

void main() {
  testWidgets('links and steps call back', (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(componentHost(_pages(go: pages.add)));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('Previous'));
    await tester.tap(find.text('Next'));
    expect(pages, [3, 1, 3]);
  });

  testWidgets('the active page is the secondary highlighter', (tester) async {
    await tester.pumpWidget(componentHost(_pages(go: (_) {})));
    final buttons = tester.widgetList<Button>(find.byType(Button)).toList();
    expect(buttons[2].variant, ButtonVariant.secondary);
    expect(buttons[1].variant, ButtonVariant.ghost);
    expect(buttons[1].size, ButtonSize.icon);
  });

  testWidgets('the step words hide below 640 wide', (tester) async {
    tester.view.physicalSize = const Size(500, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(_pages(go: (_) {})));
    expect(find.text('Previous'), findsNothing);
    expect(find.byType(InkIcon), findsNWidgets(3));
  });

  testWidgets('steps take a size, and its icon size when narrow', (
    tester,
  ) async {
    Widget steps() => componentHost(
      Pagination(
        child: PaginationContent(
          children: [
            PaginationPrevious(size: ButtonSize.sm, onPressed: () {}),
            PaginationNext(size: ButtonSize.sm, onPressed: () {}),
          ],
        ),
      ),
    );
    await tester.pumpWidget(steps());
    expect(
      tester.widgetList<Button>(find.byType(Button)).map((b) => b.size),
      [ButtonSize.sm, ButtonSize.sm],
    );
    tester.view.physicalSize = const Size(500, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(steps());
    expect(
      tester.widgetList<Button>(find.byType(Button)).map((b) => b.size),
      [ButtonSize.iconSm, ButtonSize.iconSm],
    );
  });

  testWidgets('semantics name the steps and mark the current page', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_pages(go: (_) {}, page: 1)));
    expect(find.bySemanticsLabel('Go to previous page'), findsOneWidget);
    expect(find.bySemanticsLabel('Go to next page'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(PaginationLink).at(1)),
      includesSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.byType(PaginationLink).at(2)),
      includesSemantics(isSelected: false),
    );
    handle.dispose();
  });
}
