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

  testWidgets('bookmark-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.desk,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d32,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d32,
                    children: [
                      Bookmark(value: false, onChanged: (_) {}, seed: 'off'),
                      Bookmark(value: true, onChanged: (_) {}, seed: 'on'),
                      const Bookmark(value: false, disabled: true, seed: 'dis'),
                      Bookmark(
                        value: false,
                        onChanged: (_) {},
                        seed: 'hover',
                        forcedStates: const {InkState.hovered},
                      ),
                      Bookmark(
                        value: true,
                        onChanged: (_) {},
                        seed: 'focus',
                        forcedStates: const {InkState.focused},
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: Spacing.d24,
                    children: [
                      for (final tone in Accent.values)
                        Bookmark(
                          value: true,
                          tone: tone,
                          onChanged: (_) {},
                          seed: tone.name,
                        ),
                    ],
                  ),
                  const SizedBox(
                    width: 320,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Paper(
                          seed: 'marked',
                          padding: EdgeInsets.all(Spacing.d24),
                          child: SizedBox(
                            width: double.infinity,
                            height: Spacing.d96,
                            child: Text('Chapter three'),
                          ),
                        ),
                        Positioned(
                          top: -Spacing.d4,
                          right: Spacing.d24,
                          child: BookmarkRibbon(seed: 'r1'),
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
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/bookmark-states.png'),
    );
  });
}
