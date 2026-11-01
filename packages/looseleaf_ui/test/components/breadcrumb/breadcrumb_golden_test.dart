import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _trail(
  String name, {
  Widget? separator,
  Set<InkState> states = const {},
}) => Breadcrumb(
  child: BreadcrumbList(
    children: [
      BreadcrumbItem(
        children: [
          BreadcrumbLink(
            onPressed: () {},
            forcedStates: states,
            child: const Text('Home'),
          ),
        ],
      ),
      BreadcrumbSeparator(child: separator),
      const BreadcrumbItem(children: [BreadcrumbEllipsis()]),
      BreadcrumbSeparator(child: separator),
      BreadcrumbItem(
        children: [
          BreadcrumbLink(onPressed: () {}, child: const Text('Components')),
        ],
      ),
      BreadcrumbSeparator(child: separator),
      BreadcrumbItem(
        children: [
          BreadcrumbPage(seed: name, child: const Text('Breadcrumb')),
        ],
      ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('breadcrumb-trails in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 480);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d20,
                children: [
                  _trail('rest'),
                  _trail('hover', states: const {InkState.hovered}),
                  _trail(
                    'chevron',
                    separator: const InkIcon(
                      'chevron-right',
                      size: Spacing.d16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/breadcrumb-trails.png'),
    );
  });
}
