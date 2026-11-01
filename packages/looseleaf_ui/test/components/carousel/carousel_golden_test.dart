import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

const _tones = [
  Color(0xFFFBF6E9),
  Color(0xFFF7E38A),
  Color(0xFFDCC8A3),
  Color(0xFFBCD8F0),
  Color(0xFFFFFDF6),
];

Widget _card(int index) => Builder(
  builder: (context) => DecoratedBox(
    decoration: BoxDecoration(color: _tones[index % _tones.length]),
    child: Center(
      child: Text(
        '${index + 1}',
        style: LooseleafTheme.of(context).typography.title(cssSize: 60),
      ),
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('carousel-default in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          SizedBox(
            width: 416,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d32,
              children: [
                Carousel(
                  seed: 'default',
                  children: [
                    CarouselContent(
                      children: [
                        for (var i = 0; i < 5; i++)
                          CarouselItem(child: _card(i)),
                      ],
                    ),
                    const CarouselPrevious(seed: 'prev'),
                    const CarouselNext(seed: 'next'),
                    const CarouselDots(),
                  ],
                ),
                Carousel(
                  seed: 'thirds',
                  itemFraction: 1 / 3,
                  children: [
                    CarouselContent(
                      children: [
                        for (var i = 0; i < 12; i++)
                          CarouselItem(child: _card(i)),
                      ],
                    ),
                    const CarouselDots(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CarouselTick).at(6));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/carousel-default.png'),
    );
  });
}
