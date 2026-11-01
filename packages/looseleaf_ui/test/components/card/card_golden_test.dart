import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(String label, bool on) => Row(
  children: [
    Expanded(child: Text(label)),
    Switch(value: on, onChanged: (_) {}, seed: label),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('card-settings in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1800, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: Paper(
            stock: StockName.dotGrid,
            tilt: false,
            shadow: PaperShadow.none,
            seed: 'page',
            padding: const EdgeInsets.all(Spacing.d48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d48,
              children: [
                SizedBox(
                  width: 420,
                  child: Card(
                    seed: 'settings',
                    children: [
                      CardHeader(
                        children: [
                          const CardTitle(Text('Notifications')),
                          const CardDescription(
                            Text('Choose what lands in your inbox.'),
                          ),
                          CardAction(
                            child: Button(
                              variant: ButtonVariant.link,
                              onPressed: () {},
                              seed: 'reset',
                              child: const Text('Reset'),
                            ),
                          ),
                        ],
                      ),
                      CardContent(
                        child: Column(
                          spacing: Spacing.d16,
                          children: [
                            _row('Comments on your notes', true),
                            _row('Replies to your questions', true),
                            _row('The weekly summary, Fridays', false),
                          ],
                        ),
                      ),
                      CardFooter(
                        divider: true,
                        seed: 'footer',
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: Spacing.d8,
                        children: [
                          Button(
                            variant: ButtonVariant.outline,
                            onPressed: () {},
                            seed: 'cancel',
                            child: const Text('Cancel'),
                          ),
                          Button(
                            onPressed: () {},
                            seed: 'save',
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Column(
                    spacing: Spacing.d48,
                    children: [
                      for (final rule in CardRuleStyle.values)
                        Card(
                          stock: StockName.indexCard,
                          rules: RuleName.indexCard,
                          fastener: FastenerKind.pin,
                          seed: rule.name,
                          children: [
                            CardHeader(
                              divider: true,
                              rule: rule,
                              seed: '${rule.name}-rule',
                              children: [CardTitle(Text(rule.name))],
                            ),
                            const CardContent(child: Text('A ruled header.')),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/card-settings.png'),
    );
  });
}
