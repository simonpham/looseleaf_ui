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

  testWidgets('stamp-button-inks in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  for (final ink in StampButtonInk.values)
                    StampButton(text: ink.id, ink: ink, seed: ink.id),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  for (final (name, states) in [
                    ('Hover', {InkState.hovered}),
                    ('Pressed', {InkState.pressed}),
                    ('Focus', {InkState.focused}),
                  ])
                    StampButton(
                      stamp: 'stamp-approved',
                      seed: name,
                      forcedStates: states,
                      child: Text(name),
                    ),
                  const StampButton(
                    stamp: 'stamp-void',
                    seed: 'disabled',
                    disabled: true,
                  ),
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
      matchesGoldenFile('../goldens/stamp-button-inks.png'),
    );
  });

  testWidgets('stamp-button-page after two strikes', (tester) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    const theme = LooseleafThemeData();
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          StampSurface(
            child: ColoredBox(
              color: theme.colors.slip,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.d24),
                child: SizedBox(
                  width: 360,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d12,
                    children: [
                      const Text('Invoice 2026-031'),
                      const Text('Twelve notebooks, felt tips'),
                      const SizedBox(height: Spacing.d96),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: Spacing.d16,
                        children: const [
                          StampButton(
                            stamp: 'stamp-approved',
                            seed: 'approve',
                            place: Offset(0.66, 0.5),
                            child: Text('Approve'),
                          ),
                          StampButton(
                            stamp: 'stamp-void',
                            seed: 'void',
                            place: Offset(0.4, 0.3),
                            child: Text('Void'),
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
      ),
    );
    await tester.tap(find.text('Approve'));
    await tester.tap(find.text('Void'));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/stamp-button-page.png'),
    );
  });
}
