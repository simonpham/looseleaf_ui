import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('marker-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          const SizedBox(
            width: 460,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                Marker(
                  variant: MarkerVariant.separator,
                  seed: 'wed',
                  children: [MarkerContent(child: Text('Wednesday'))],
                ),
                Marker(
                  variant: MarkerVariant.separator,
                  tone: MarkerTone.fresh,
                  seed: 'new',
                  children: [
                    MarkerIcon(child: Text('*')),
                    MarkerContent(child: Text('New messages')),
                  ],
                ),
                Marker(
                  variant: MarkerVariant.border,
                  seed: 'b1',
                  children: [MarkerContent(child: Text('Thursday, 12 March'))],
                ),
                Marker(
                  children: [
                    MarkerIcon(child: Text('+')),
                    MarkerContent(child: Text('Lin joined the conversation')),
                  ],
                ),
                Marker(
                  variant: MarkerVariant.border,
                  tone: MarkerTone.fresh,
                  rule: MarkerStyle.wavy,
                  seed: 'b2',
                  children: [MarkerContent(child: Text('3 unread'))],
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
      matchesGoldenFile('../goldens/marker-variants.png'),
    );
  });
}
