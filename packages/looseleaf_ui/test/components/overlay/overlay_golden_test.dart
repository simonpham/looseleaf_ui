import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('overlay-scrim in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          key: _shot,
          child: Desk(
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => InkPopup(
                    open: true,
                    centered: true,
                    scrim: true,
                    motion: PopupMotionStyle.sheetDrop,
                    popupBuilder: (context, position) => const PaperPopup(
                      seed: 'dialog',
                      stock: StockName.paper,
                      shadow: PaperShadow.stock,
                      width: 400,
                      padding: EdgeInsets.all(Spacing.d24),
                      child: Text('A sheet dropped on the desk.'),
                    ),
                    child: const SizedBox.expand(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.d32),
                        child: Text('The app underneath'),
                      ),
                    ),
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
      find.byKey(_shot),
      matchesGoldenFile('../goldens/overlay-scrim.png'),
    );
  });
}
