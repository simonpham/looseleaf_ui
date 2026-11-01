import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('scroll-area-tags in the light theme', (tester) async {
    tester.view.physicalSize = const Size(600, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          SizedBox(
            width: 224,
            height: 288,
            child: ScrollArea(
              controller: controller,
              seed: 'tags',
              child: Padding(
                padding: const EdgeInsets.all(Spacing.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 50; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Spacing.d8,
                        ),
                        child: Text(
                          'v1.${2 - i ~/ 10}.${9 - i % 10}-beta.${50 - i}',
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
    controller.jumpTo(300);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(ScrollArea)));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/scroll-area-tags.png'),
    );
    await mouse.removePointer();
  });
}
