import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import 'sidebar_demo.dart';

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget stage, {
  Size view = const Size(1400, 1100),
}) async {
  tester.view.physicalSize = view * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(stage));
  await tester.pumpAndSettle();
  await expectLater(
    find.byKey(const Key('shot')),
    matchesGoldenFile('../goldens/$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sidebar-app in the light theme', (tester) async {
    await _shoot(
      tester,
      'sidebar-app',
      deskStage(appSidebar(hoverRow: const {InkState.hovered})),
    );
  });

  testWidgets('sidebar-icons in the light theme', (tester) async {
    await _shoot(
      tester,
      'sidebar-icons',
      deskStage(
        appSidebar(defaultOpen: false, collapsible: SidebarCollapsible.icon),
        size: const Size(480, 500),
      ),
    );
  });

  testWidgets('sidebar-variants in the light theme', (tester) async {
    await _shoot(
      tester,
      'sidebar-variants',
      deskStage(
        Row(
          spacing: Spacing.d16,
          children: [
            Expanded(
              child: appSidebar(variant: SidebarVariant.floating),
            ),
            Expanded(
              child: appSidebar(
                variant: SidebarVariant.inset,
                side: SidebarSide.right,
              ),
            ),
          ],
        ),
        size: const Size(1296, 500),
      ),
    );
  });

  testWidgets('sidebar-mobile in the light theme', (tester) async {
    tester.view.physicalSize = const Size(390, 640) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(deskStage(appSidebar(), size: const Size(390, 640))),
    );
    await tester.tap(find.byType(SidebarTrigger));
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const Key('shot')),
      matchesGoldenFile('../goldens/sidebar-mobile.png'),
    );
  });
}
