import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _trail({VoidCallback? onHome, FocusNode? focusNode}) => Breadcrumb(
  child: BreadcrumbList(
    children: [
      BreadcrumbItem(
        children: [
          BreadcrumbLink(
            onPressed: onHome,
            focusNode: focusNode,
            child: const Text('Home'),
          ),
        ],
      ),
      const BreadcrumbSeparator(),
      const BreadcrumbItem(children: [BreadcrumbEllipsis()]),
      const BreadcrumbSeparator(),
      const BreadcrumbItem(children: [BreadcrumbPage(child: Text('Here'))]),
    ],
  ),
);

Color? _color(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

void main() {
  const colors = LooseleafColors();

  testWidgets('links answer taps and Enter', (tester) async {
    var presses = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      componentHost(_trail(onHome: () => presses++, focusNode: focusNode)),
    );
    await tester.tap(find.text('Home'));
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 2);
  });

  testWidgets('text is muted; the page is bold ink', (tester) async {
    await tester.pumpWidget(componentHost(_trail()));
    expect(_color(tester, 'Home'), colors.inkMuted);
    expect(_color(tester, 'Here'), colors.ink);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Here'))
          .text
          .style
          ?.fontWeight,
      FontWeight.w700,
    );
  });

  testWidgets('hover swipes the highlighter under a link', (tester) async {
    await tester.pumpWidget(componentHost(_trail(onHome: () {})));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Home')));
    await tester.pumpAndSettle();
    final swipe = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(BreadcrumbLink),
        matching: find.byType(AnimatedContainer),
      ),
    );
    expect((swipe.decoration as BoxDecoration?)?.color, colors.hiSelect);
    expect(_color(tester, 'Home'), colors.ink);
    await mouse.removePointer();
  });

  testWidgets('semantics: a navigation landmark, links, current page', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_trail(onHome: () {})));
    final nav = tester.getSemantics(find.byType(Breadcrumb)).getSemanticsData();
    expect(nav.role, SemanticsRole.navigation);
    expect(nav.label.trim(), 'breadcrumb');
    expect(
      tester.getSemantics(find.byType(BreadcrumbLink)),
      matchesSemantics(
        label: 'Home',
        isLink: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(BreadcrumbPage)),
      matchesSemantics(
        label: 'Here',
        isLink: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isSelected: true,
      ),
    );
    expect(find.bySemanticsLabel('More'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the gap is 6, and 8 from the sm breakpoint', (tester) async {
    for (final (width, gap) in [(600.0, 6.0), (900.0, 8.0)]) {
      tester.view.physicalSize = Size(width, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(componentHost(_trail()));
      final separator = tester.getRect(find.byType(BreadcrumbSeparator).first);
      final home = tester.getRect(find.byType(BreadcrumbItem).first);
      expect(separator.left - home.right, gap);
    }
  });
}
