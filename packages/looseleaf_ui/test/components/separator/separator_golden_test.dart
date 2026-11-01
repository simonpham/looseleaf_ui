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

  testWidgets('separator-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 1700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d24,
              children: [
                for (final variant in SeparatorVariant.values)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d12,
                    children: [
                      Text(variant.name),
                      Separator(variant: variant, seed: variant.name),
                    ],
                  ),
                const Separator(
                  variant: SeparatorVariant.dashed,
                  seed: 'or',
                  child: Text('or continue with'),
                ),
                SizedBox(
                  height: Spacing.d24,
                  child: Row(
                    spacing: Spacing.d16,
                    children: [
                      const Text('Sketches'),
                      const Separator(
                        orientation: SeparatorOrientation.vertical,
                        seed: 'v1',
                      ),
                      const Text('Recipes'),
                      const Separator(
                        orientation: SeparatorOrientation.vertical,
                        variant: SeparatorVariant.dotted,
                        seed: 'v2',
                      ),
                      const Text('Maps'),
                      for (final variant in const [
                        SeparatorVariant.wavy,
                        SeparatorVariant.stitched,
                      ])
                        Separator(
                          orientation: SeparatorOrientation.vertical,
                          variant: variant,
                          seed: 'v-${variant.name}',
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 120,
                  child: Separator(
                    orientation: SeparatorOrientation.vertical,
                    variant: SeparatorVariant.tape,
                    seed: 'vl',
                    child: Text('or'),
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
      matchesGoldenFile('../goldens/separator-variants.png'),
    );
  });
}
