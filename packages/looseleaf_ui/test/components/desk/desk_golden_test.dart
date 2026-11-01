import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(RepaintBoundary(child: child)));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('desk-default in the light theme', (tester) async {
    await _pump(
      tester,
      const Desk(
        padding: EdgeInsets.all(Spacing.d40),
        child: SizedBox(
          width: 800,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 320,
                child: Card(
                  seed: 'desk-card',
                  children: [
                    CardHeader(
                      children: [
                        CardTitle(Text('On the desk')),
                        CardDescription(
                          Text('A card, casting a card-sized shadow.'),
                        ),
                      ],
                    ),
                    CardContent(
                      child: Text(
                        'The blotter is a shade darker than the paper so '
                        'cream glows against it.',
                      ),
                    ),
                  ],
                ),
              ),
              Paper(
                stock: StockName.stickyYellow,
                seed: 'mum',
                padding: EdgeInsets.all(Spacing.d16),
                child: SizedBox.square(
                  dimension: 128,
                  child: Text('call mum\nbefore six'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/desk-default.png'),
    );
  });

  testWidgets('desk-objects in the light theme', (tester) async {
    await _pump(
      tester,
      const Desk(
        objects: DeskObject.values,
        seed: 'desk',
        padding: EdgeInsets.symmetric(horizontal: 240, vertical: 120),
        child: Paper(
          seed: 'sheet',
          padding: EdgeInsets.all(Spacing.d24),
          child: SizedBox(width: 320, height: 180, child: Text('Morning')),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/desk-objects.png'),
    );
  });
}
