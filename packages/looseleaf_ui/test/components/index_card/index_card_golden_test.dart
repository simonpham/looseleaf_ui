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

  testWidgets('index-card-kinds in the light theme', (tester) async {
    tester.view.physicalSize = const Size(2160, 1400);
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
                width: 940,
                child: Wrap(
                  spacing: Spacing.d40,
                  runSpacing: Spacing.d48,
                  children: [
                    SizedBox(
                      width: 448,
                      child: IndexCard(
                        seed: 'recipes',
                        children: [
                          IndexCardHeader(
                            children: [IndexCardTitle(Text('Recipes'))],
                          ),
                          IndexCardContent(
                            children: [
                              Text('oat porridge, the slow way'),
                              Text('soup that forgives'),
                              Text('toast, honestly'),
                            ],
                          ),
                          IndexCardFooter(
                            children: [Text('no. 0042'), Text('p. 3')],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 448,
                      child: IndexCard(
                        hole: true,
                        flag: Accent.tomato,
                        stack: 3,
                        seed: 'sources',
                        children: [
                          IndexCardHeader(
                            children: [IndexCardTitle(Text('Sources'))],
                          ),
                          IndexCardContent(
                            children: [
                              Text('sketchbook, dip pen, ink'),
                              Text('sage green, ochre, madder'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 448,
                      child: IndexCard(
                        tape: PaperTape.both,
                        tapeKind: TapeKind.washiDots,
                        stack: 1,
                        minHeight: 194,
                        seed: 'washi',
                        children: [
                          IndexCardHeader(
                            children: [IndexCardTitle(Text('Taped up'))],
                          ),
                          IndexCardContent(
                            children: [Text('two strips of washi')],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 448,
                      child: IndexCard(
                        hole: true,
                        flag: Accent.sky,
                        fastener: FastenerKind.clip,
                        minHeight: 194,
                        seed: 'words',
                        children: [
                          IndexCardHeader(
                            children: [IndexCardTitle(Text('Words'))],
                          ),
                          IndexCardContent(
                            children: [
                              Text('petrichor'),
                              Text('the smell of rain on dry earth'),
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
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/index-card-kinds.png'),
    );
  });
}
