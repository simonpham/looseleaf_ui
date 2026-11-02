import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _keys(String name, {bool pressed = false}) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d16,
  children: [
    for (final label in ['Esc', 'Tab', 'K', 'Space', '↵'])
      Kbd(seed: '$name-$label', pressed: pressed, child: Text(label)),
    KbdGroup(
      children: [
        Kbd(seed: '$name-ctrl', pressed: pressed, child: const Text('Ctrl')),
        const Text('+'),
        Kbd(seed: '$name-p', pressed: pressed, child: const Text('P')),
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

  for (final density in LooseleafDensity.values) {
    testWidgets('kbd-${density.name} in the light theme', (tester) async {
      tester.view.physicalSize = const Size(1000, 400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        componentHost(
          theme: LooseleafThemeData(density: density),
          goldenPanel(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                _keys('rest'),
                _keys('pressed', pressed: true),
                KbdGroup(
                  children: [
                    for (final symbol in ['⌘', '⇧', '⌥', '⌃'])
                      Kbd(seed: 'mod-$symbol', child: Text(symbol)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/kbd-${density.name}.png'),
      );
    });
  }
}
