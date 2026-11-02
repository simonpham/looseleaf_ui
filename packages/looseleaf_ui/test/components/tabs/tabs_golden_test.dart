import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

Widget _list(TabsVariant variant, TabsOrientation orientation) => Tabs(
  defaultValue: 'account',
  orientation: orientation,
  children: [
    TabsList(
      variant: variant,
      children: [
        TabsTrigger(
          value: 'account',
          seed: '${variant.id}-${orientation.name}-account',
          child: const Text('Account'),
        ),
        TabsTrigger(
          value: 'password',
          seed: '${variant.id}-${orientation.name}-password',
          forcedStates: const {InkState.hovered},
          child: const Text('Password'),
        ),
        TabsTrigger(
          value: 'billing',
          seed: '${variant.id}-${orientation.name}-billing',
          forcedStates: const {InkState.focused},
          child: const Text('Billing'),
        ),
        TabsTrigger(
          value: 'team',
          disabled: true,
          seed: '${variant.id}-${orientation.name}-team',
          child: const Text('Team'),
        ),
      ],
    ),
    const TabsContent(value: 'account', child: Text('Make changes here.')),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('tabs-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1700, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              _list(TabsVariant.folder, TabsOrientation.horizontal),
              _list(TabsVariant.line, TabsOrientation.horizontal),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d48,
                children: [
                  _list(TabsVariant.folder, TabsOrientation.vertical),
                  _list(TabsVariant.line, TabsOrientation.vertical),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/tabs-variants.png'),
    );
  });
}
