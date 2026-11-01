import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const Key _first = Key('first');

Widget _page({PageHoles holes = PageHoles.none, PageWidth? width}) => PaperPage(
  holes: holes,
  width: width ?? PageWidth.md,
  seed: 'p',
  children: const [SizedBox(key: _first, height: 20)],
);

Future<void> _wide(WidgetTester tester, bool wide) async {
  tester.view.physicalSize = switch (wide) {
    true => const Size(1200, 800),
    false => const Size(500, 800),
  };
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('pads 24 × 32 on narrow screens and 40 on wide ones', (
    tester,
  ) async {
    await _wide(tester, false);
    await tester.pumpWidget(componentHost(_page()));
    var page = tester.getRect(find.byType(Paper));
    var first = tester.getRect(find.byKey(_first));
    expect(first.left - page.left, Spacing.d24);
    expect(first.top - page.top, Spacing.d32);
    await _wide(tester, true);
    await tester.pumpWidget(componentHost(_page()));
    page = tester.getRect(find.byType(Paper));
    first = tester.getRect(find.byKey(_first));
    expect(first.left - page.left, Spacing.d40);
    expect(first.top - page.top, Spacing.d40);
  });

  testWidgets('punched holes make room at the start or the top', (
    tester,
  ) async {
    await _wide(tester, true);
    await tester.pumpWidget(componentHost(_page(holes: PageHoles.start)));
    var page = tester.getRect(find.byType(Paper));
    var first = tester.getRect(find.byKey(_first));
    expect(first.left - page.left, Spacing.d68);
    await tester.pumpWidget(componentHost(_page(holes: PageHoles.top)));
    page = tester.getRect(find.byType(Paper));
    first = tester.getRect(find.byKey(_first));
    expect(first.top - page.top, Spacing.d64);
    expect(find.byType(InkSurface), findsOneWidget);
  });

  testWidgets('grows to its width and no further', (tester) async {
    await _wide(tester, true);
    await tester.pumpWidget(
      componentHost(
        SizedBox(width: 1000, child: _page(width: PageWidth.sm)),
      ),
    );
    expect(tester.getSize(find.byType(Paper)).width, PageWidth.sm.maxWidth);
  });

  testWidgets('torn edges tear the paper', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const PaperPage(
          torn: PageTorn.bottom,
          seed: 't',
          children: [Text('x')],
        ),
      ),
    );
    expect(
      tester.widget<Paper>(find.byType(Paper)).edge?.bottom,
      EdgeKind.torn,
    );
  });

  testWidgets('the title is a header with a hand-drawn underline', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const PageTitle(Text('Field notes'), seed: 't')),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Field notes')),
      matchesSemantics(label: 'Field notes', isHeader: true),
    );
    expect(find.byType(InkSurface), findsOneWidget);
    await tester.pumpWidget(
      componentHost(const PageTitle(Text('Plain'), underline: null)),
    );
    expect(find.byType(InkSurface), findsNothing);
    handle.dispose();
  });
}
