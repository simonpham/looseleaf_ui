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

  testWidgets('tape-kinds in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1500, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 640,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d32,
                  children: [
                    Wrap(
                      spacing: Spacing.d32,
                      runSpacing: Spacing.d24,
                      children: [
                        for (final kind in TapeKind.values)
                          SizedBox(
                            width: 128,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Spacing.d12,
                              children: [
                                Tape(kind: kind, length: 116, seed: kind.id),
                                Text(kind.id),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Wrap(
                      spacing: Spacing.d32,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final ends in TapeEnds.values)
                          Tape(ends: ends, angle: 0, seed: ends.name),
                        const Tape(
                          kind: TapeKind.washiStripes,
                          color: Accent.sky,
                          length: 40,
                          height: 14,
                          seed: 'tiny',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/tape-kinds.png'),
    );
  });
}
