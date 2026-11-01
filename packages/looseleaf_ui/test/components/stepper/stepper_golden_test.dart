import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

Widget _row(String name, Widget stepper) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d16,
  children: [
    SizedBox(width: Spacing.d96, child: Text(name)),
    stepper,
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('stepper-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      overlayHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  _row('Quantity', const Stepper(value: 2, min: 0, seed: 'q')),
                  _row('At min', const Stepper(value: 0, min: 0, seed: 'min')),
                  _row(
                    'Hover',
                    const Stepper(
                      value: 12,
                      seed: 'hover',
                      forcedStates: {InkState.hovered},
                    ),
                  ),
                  _row(
                    'Focus',
                    const Stepper(
                      value: 7,
                      seed: 'focus',
                      forcedStates: {InkState.focused},
                    ),
                  ),
                  _row(
                    'Price',
                    Stepper(
                      value: 4.5,
                      min: 0,
                      step: 0.5,
                      precision: 2,
                      width: 176,
                      seed: 'price',
                      format: (n) => '\$${n.toStringAsFixed(2)}',
                    ),
                  ),
                  _row(
                    'Invalid',
                    const Stepper(value: 99, invalid: true, seed: 'bad'),
                  ),
                  _row(
                    'Disabled',
                    const Stepper(value: 3, disabled: true, seed: 'off'),
                  ),
                  _row(
                    'Empty',
                    const Stepper(value: null, seed: 'empty'),
                  ),
                  _row(
                    'Tally',
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Spacing.d12,
                      children: [
                        Stepper(value: 7, min: 0, max: 20, seed: 'tally'),
                        StepperTally(value: 7, seed: 'marks'),
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
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/stepper-states.png'),
    );
  });
}
