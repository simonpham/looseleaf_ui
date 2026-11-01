import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _variants() => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d24,
  children: [
    Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d24,
      children: [
        Spinner(seed: 's16'),
        Spinner(size: Spacing.d24, seed: 's24'),
        Spinner(size: Spacing.d32, seed: 's32'),
        Spinner(size: Spacing.d48, seed: 's48'),
        Spinner(variant: SpinnerVariant.loops, seed: 'l16'),
        Spinner(variant: SpinnerVariant.loops, size: Spacing.d24, seed: 'l24'),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d24,
      children: [
        Spinner(variant: SpinnerVariant.write, seed: 'w64'),
        Spinner(variant: SpinnerVariant.write, size: 96, seed: 'w96'),
      ],
    ),
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('spinner-still in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(_variants()),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/spinner-still.png'),
    );
  });

  testWidgets('spinner-scribbling a third of the way round', (tester) async {
    tester.view.physicalSize = const Size(1000, 500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(componentHost(goldenPanel(_variants())));
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/spinner-scribbling.png'),
    );
    await tester.pumpWidget(const SizedBox());
  });
}
