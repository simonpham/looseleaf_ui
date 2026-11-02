import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _item(
  String name, {
  bool disabled = false,
  bool? invalid,
  Set<InkState> states = const {},
}) => InkRadioGroupItem<String>(
  value: name,
  disabled: disabled,
  invalid: invalid,
  seed: name,
  forcedStates: states,
  label: Text(name),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('radio-group-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d48,
                children: [
                  InkRadioGroup<String>(
                    value: 'Comfortable',
                    children: [
                      _item('Default'),
                      _item('Comfortable'),
                      _item('Hover', states: const {InkState.hovered}),
                      _item('Focus', states: const {InkState.focused}),
                    ],
                  ),
                  InkRadioGroup<String>(
                    value: 'Disabled on',
                    children: [
                      _item('Invalid', invalid: true),
                      _item('Disabled', disabled: true),
                      _item('Disabled on', disabled: true),
                    ],
                  ),
                ],
              ),
              InkRadioGroup<String>(
                value: 'Card',
                direction: Axis.horizontal,
                invalid: true,
                children: [_item('Card'), _item('PayPal'), _item('Cash')],
              ),
              const InkRadioGroup<String>(
                value: 'studio',
                children: [
                  InkRadioGroupItem(
                    value: 'studio',
                    size: Spacing.d20,
                    seed: 'studio',
                    label: Text('Studio'),
                    description: Text(
                      'Ten notebooks and the good highlighters.',
                    ),
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
      matchesGoldenFile('../goldens/radio-group-states.png'),
    );
  });
}
