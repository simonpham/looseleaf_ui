import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import 'sidebar_demo.dart';

Future<void> _desktop(WidgetTester tester, Widget stage) async {
  tester.view.physicalSize = const Size(1024, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(componentHost(stage));
  await tester.pumpAndSettle();
}

Future<void> _phone(WidgetTester tester, Widget stage) async {
  tester.view.physicalSize = const Size(390, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(componentHost(stage));
  await tester.pumpAndSettle();
}

double _gap(WidgetTester tester) =>
    tester.getSize(find.byType(SidebarDock)).width;

SidebarData _data(WidgetTester tester) =>
    SidebarProvider.of(tester.element(find.byType(SidebarInset)));

Widget _stage(Widget child) => deskStage(child, size: const Size(1000, 600));

void main() {
  testWidgets('the trigger collapses and reopens an offcanvas pad', (
    tester,
  ) async {
    await _desktop(tester, _stage(appSidebar()));
    expect(_gap(tester), SidebarMetrics.width);
    expect(_data(tester).state, SidebarState.expanded);
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    expect(_gap(tester), 0);
    expect(_data(tester).state, SidebarState.collapsed);
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    expect(_gap(tester), SidebarMetrics.width);
  });

  testWidgets('collapsing to icons keeps a 3rem column, wider when floating', (
    tester,
  ) async {
    await _desktop(
      tester,
      _stage(
        appSidebar(defaultOpen: false, collapsible: SidebarCollapsible.icon),
      ),
    );
    expect(_gap(tester), SidebarMetrics.widthIcon);
    expect(find.text('Platform'), findsOneWidget);
    expect(find.byType(SidebarMenuSubButton), findsNothing);
    expect(
      tester.getSize(find.byType(SidebarMenuButton).at(1)),
      const Size.square(Spacing.d32),
    );
    await _desktop(
      tester,
      _stage(
        appSidebar(
          defaultOpen: false,
          collapsible: SidebarCollapsible.icon,
          variant: SidebarVariant.floating,
        ),
      ),
    );
    expect(_gap(tester), SidebarMetrics.widthIcon + Spacing.d16);
  });

  testWidgets('Ctrl and Cmd + B toggle it, focused inside or not at all', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await _desktop(
      tester,
      SidebarProvider(
        children: [
          const Sidebar(seed: 's', children: []),
          SidebarInset(child: SidebarTrigger(focusNode: focus)),
        ],
      ),
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(_data(tester).open, isFalse);
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();
    expect(_data(tester).open, isTrue);
  });

  testWidgets('a controlled provider asks through onOpenChange', (
    tester,
  ) async {
    final asked = <bool>[];
    await _desktop(
      tester,
      SidebarProvider(
        open: true,
        onOpenChange: asked.add,
        children: const [
          Sidebar(seed: 's', children: []),
          SidebarInset(child: SidebarTrigger()),
        ],
      ),
    );
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    expect(asked, [false]);
    expect(_gap(tester), SidebarMetrics.width);
  });

  testWidgets('the rail toggles the pad and stays reachable offcanvas', (
    tester,
  ) async {
    await _desktop(tester, _stage(appSidebar()));
    final rail = find.byType(SidebarRail);
    expect(
      tester.getCenter(rail).dx,
      closeTo(tester.getTopRight(find.byType(SidebarDock)).dx, 0.5),
    );
    await tester.tap(rail);
    await tester.pumpAndSettle();
    expect(_data(tester).open, isFalse);
    await tester.tapAt(tester.getCenter(rail) + const Offset(Spacing.d4, 0));
    await tester.pumpAndSettle();
    expect(_data(tester).open, isTrue);
  });

  testWidgets('a menu button presses, marks the current page and swipes', (
    tester,
  ) async {
    var presses = 0;
    final handle = tester.ensureSemantics();
    await _desktop(
      tester,
      SidebarProvider(
        children: [
          Sidebar(
            seed: 's',
            children: [
              SidebarContent(
                children: [
                  SidebarMenu(
                    children: [
                      SidebarMenuItem(
                        child: SidebarMenuButton(
                          isActive: true,
                          onPressed: () => presses++,
                          child: const Text('Inbox'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SidebarInset(child: SizedBox()),
        ],
      ),
    );
    await tester.tap(find.text('Inbox'));
    expect(presses, 1);
    expect(
      tester.getSemantics(find.byType(SidebarMenuButton)),
      matchesSemantics(
        label: 'Inbox',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    final style = tester.renderObject<RenderParagraph>(find.text('Inbox'));
    expect(style.text.style?.fontWeight, FontWeight.w700);
    expect(
      tester
          .widget<InkSurface>(
            find.descendant(
              of: find.byType(SidebarMenuButton),
              matching: find.byType(InkSurface),
            ),
          )
          .source,
      isA<SidebarMarkSource>(),
    );
    expect(
      tester.getSize(find.byType(SidebarMenuButton)).height,
      Spacing.d32,
    );
    handle.dispose();
  });

  testWidgets('hovering a row shows its action, only while hovered', (
    tester,
  ) async {
    await _desktop(tester, _stage(appSidebar()));
    final action = find.byWidgetPredicate(
      (widget) =>
          widget is SidebarMenuAction &&
          widget.semanticLabel == 'Actions for Travel',
    );
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find.descendant(of: action, matching: find.byType(AnimatedOpacity)),
        )
        .opacity;
    expect(action, findsOneWidget);
    expect(opacity(), 0);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('Travel')));
    await tester.pumpAndSettle();
    expect(opacity(), 1);
    await mouse.removePointer();
  });

  testWidgets('collapsed to icons, a row names itself in a tooltip', (
    tester,
  ) async {
    await _desktop(
      tester,
      _stage(
        appSidebar(defaultOpen: false, collapsible: SidebarCollapsible.icon),
      ),
    );
    final tooltip = find.ancestor(
      of: find.text('Models'),
      matching: find.byType(Tooltip),
    );
    expect(tester.widget<Tooltip>(tooltip).disabled, isFalse);
    await _desktop(tester, _stage(appSidebar()));
    expect(tester.widget<Tooltip>(tooltip).disabled, isTrue);
  });

  testWidgets('on a phone the trigger opens a modal sheet that Escape closes', (
    tester,
  ) async {
    await _phone(tester, deskStage(appSidebar(), size: const Size(390, 700)));
    expect(find.byType(SidebarDock), findsNothing);
    expect(find.text('Playground'), findsNothing);
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    expect(_data(tester).openMobile, isTrue);
    expect(find.text('Playground'), findsOneWidget);
    expect(find.bySemanticsLabel('Sidebar'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_data(tester).openMobile, isFalse);
    expect(find.text('Playground'), findsNothing);
  });

  testWidgets('a tap on the scrim closes the phone sheet', (tester) async {
    await _phone(tester, deskStage(appSidebar(), size: const Size(390, 700)));
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(370, 400));
    await tester.pumpAndSettle();
    expect(_data(tester).openMobile, isFalse);
  });

  testWidgets('growing past the breakpoint closes the phone sheet', (
    tester,
  ) async {
    await _phone(tester, deskStage(appSidebar(), size: const Size(1024, 700)));
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1024, 700);
    await tester.pumpAndSettle();
    expect(_data(tester).isMobile, isFalse);
    expect(_data(tester).openMobile, isFalse);
  });

  testWidgets('a static pad never collapses and needs no provider', (
    tester,
  ) async {
    await _desktop(
      tester,
      const SizedBox(
        height: 400,
        child: Sidebar(
          collapsible: SidebarCollapsible.none,
          seed: 's',
          children: [
            SidebarHeader(children: [Text('Pad')]),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Sidebar)).width, SidebarMetrics.width);
    expect(find.byType(PaperFastener), findsNothing);
  });

  testWidgets('SidebarProvider.of throws outside a provider', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (inner) {
          context = inner;
          return const SizedBox();
        },
      ),
    );
    expect(() => SidebarProvider.of(context), throwsA(isA<FlutterError>()));
  });

  test('a skeleton row keeps its seeded width', () {
    for (final seed in ['a', 'b', 'menu-3']) {
      final factor = SidebarMenuSkeleton.widthFactor(seed);
      expect(factor, inInclusiveRange(0.5, 0.9));
      expect(SidebarMenuSkeleton.widthFactor(seed), factor);
    }
  });

  test('the mark drops its margin bracket on request', () {
    const markup =
        '<g data-layer="rest"><path d="M0"/>'
        '<g data-part="bracket"><g><path d="M1"/></g><path d="M2"/></g>'
        '<path d="M3"/></g>';
    expect(
      SidebarMarkSource.withoutBracket(markup),
      '<g data-layer="rest"><path d="M0"/><path d="M3"/></g>',
    );
  });
}
