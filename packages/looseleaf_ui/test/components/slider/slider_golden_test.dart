import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _slider(
  String name,
  List<double> values, {
  double max = 100,
  double step = 1,
  bool ticks = false,
  int? tickCount,
  SliderTone? tone,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 260,
  height: Spacing.d24,
  child: Slider(
    values: values,
    max: max,
    step: step,
    ticks: ticks,
    tickCount: tickCount,
    tone: tone,
    disabled: disabled,
    invalid: invalid,
    seed: name,
    forcedStates: states,
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('slider-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d32,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d20,
                children: [
                  _slider('default', [50]),
                  _slider(
                    'range',
                    [200, 700],
                    max: 1000,
                    step: 50,
                    ticks: true,
                  ),
                  _slider('hi', [3], max: 5, ticks: true, tone: SliderTone.hi),
                  _slider('blue', [40], tickCount: 4, tone: SliderTone.blue),
                  _slider('hover', [25], states: const {InkState.hovered}),
                  _slider('focus', [75], states: const {InkState.focused}),
                  _slider('invalid', [60], invalid: true),
                  _slider('disabled', [30], disabled: true),
                ],
              ),
              const SizedBox(
                width: Spacing.d24,
                height: Spacing.d176,
                child: Slider(
                  values: [60],
                  direction: Axis.vertical,
                  seed: 'v',
                ),
              ),
              const SizedBox(
                width: Spacing.d24,
                height: Spacing.d176,
                child: Slider(
                  values: [20, 80],
                  direction: Axis.vertical,
                  ticks: true,
                  tickCount: 5,
                  seed: 'vr',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/slider-states.png'),
    );
  });
}
