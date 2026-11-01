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

  testWidgets('corkboard-default in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        paperPanel(
          const SizedBox(
            width: 600,
            child: Corkboard(
              seed: 'board',
              height: 360,
              children: [
                CorkboardNote(
                  id: 'mum',
                  x: 20,
                  y: 26,
                  child: Text('Call mum about Sunday'),
                ),
                CorkboardNote(
                  id: 'ink',
                  x: 250,
                  y: 40,
                  stock: StockName.stickyPink,
                  rotate: 2.5,
                  forcedStates: {InkState.focused},
                  child: Text('Buy more ink!! (the blue felt)'),
                ),
                CorkboardNote(
                  id: 'tape',
                  x: 130,
                  y: 190,
                  stock: StockName.stickyGreen,
                  pinned: false,
                  rotate: -2,
                  child: Text('Tape it up before Friday'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/corkboard-default.png'),
    );
  });
}
