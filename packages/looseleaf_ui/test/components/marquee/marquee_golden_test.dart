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

  testWidgets('marquee-tapes in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1440, 640);
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
                width: 640,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d20,
                  children: [
                    Marquee(
                      paused: true,
                      label: 'Shop news',
                      seed: 'news',
                      children: [
                        MarqueeItem(Text('Fresh bread at seven')),
                        MarqueeItem(Text('Open late on Fridays')),
                        MarqueeItem(Text('Ask about the cake')),
                      ],
                    ),
                    Marquee(
                      paused: true,
                      tape: TapeKind.masking,
                      controls: false,
                      seed: 'masking',
                      children: [
                        MarqueeItem(Text('Handle with care')),
                        MarqueeItem(Text('This side up')),
                      ],
                    ),
                    Marquee(
                      defaultPaused: true,
                      tape: TapeKind.washiStripes,
                      color: Accent.sky,
                      seed: 'sky',
                      children: [
                        MarqueeItem(Text('New arrivals')),
                        MarqueeItem(Text('Restocked today')),
                      ],
                    ),
                    Marquee(
                      paused: true,
                      tape: TapeKind.washiGingham,
                      color: Accent.tomato,
                      seed: 'gingham',
                      children: [
                        MarqueeItem(Text('Picnic season')),
                        MarqueeItem(Text('Bring a blanket')),
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
    await tester.pump();
    await tester.pump();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/marquee-tapes.png'),
    );
  });
}
