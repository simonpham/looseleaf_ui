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

  testWidgets('seal-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1700, 1100);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: const Padding(
              padding: EdgeInsets.all(Spacing.d40),
              child: SizedBox(
                width: 760,
                child: Column(
                  spacing: Spacing.d32,
                  children: [
                    Wrap(
                      spacing: Spacing.d24,
                      runSpacing: Spacing.d24,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Seal(text: 'Best', sub: 'seller', tone: PaintKey.grass),
                        Seal(
                          variant: SealVariant.starburst,
                          text: 'New',
                          tone: PaintKey.lemon,
                        ),
                        Seal(
                          variant: SealVariant.rosette,
                          text: 'Pick',
                          tone: PaintKey.tangerine,
                          ribbon: PaintKey.sky,
                        ),
                        Seal(
                          variant: SealVariant.medal,
                          text: 'Top',
                          tone: PaintKey.lemon,
                        ),
                        Seal(
                          variant: SealVariant.shield,
                          text: 'Pro',
                          sub: 'plan',
                          tone: PaintKey.teal,
                        ),
                        Seal(
                          variant: SealVariant.plate,
                          text: 'Gold',
                          tone: PaintKey.lemon,
                        ),
                        Seal(
                          variant: SealVariant.ticket,
                          text: 'Admit',
                          tone: PaintKey.sky,
                        ),
                        Seal(
                          variant: SealVariant.tag,
                          text: 'Sale',
                          tone: PaintKey.tangerine,
                          deco: BadgeDeco.percent,
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: Spacing.d24,
                      runSpacing: Spacing.d24,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Seal(mark: SealMark.check, tone: PaintKey.sky),
                        Seal(
                          variant: SealVariant.rosette,
                          mark: SealMark.check,
                          tone: PaintKey.grass,
                          ribbon: PaintKey.lemon,
                        ),
                        Seal(
                          variant: SealVariant.starburst,
                          mark: SealMark.star,
                          tone: PaintKey.tangerine,
                        ),
                        Seal(
                          variant: SealVariant.ring,
                          text: 'Verified',
                          tone: PaintKey.sky,
                          ring: 'Official seal',
                          size: 128,
                        ),
                        Seal(
                          variant: SealVariant.wax,
                          text: 'L',
                          tone: PaintKey.red,
                          tilt: -6,
                        ),
                        Seal(
                          variant: SealVariant.wax,
                          mark: SealMark.check,
                          tone: PaintKey.grape,
                        ),
                        Seal(
                          mark: SealMark.check,
                          tone: PaintKey.sky,
                          size: 20,
                          shadow: false,
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
      matchesGoldenFile('../goldens/seal-variants.png'),
    );
  });
}
