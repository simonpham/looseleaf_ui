import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(
  String name, {
  bool value = false,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d24,
  children: [
    for (final size in SwitchSize.values)
      Switch(
        value: value,
        size: size,
        disabled: disabled,
        invalid: invalid,
        seed: '$name-${size.name}',
        forcedStates: states,
        label: Text(name),
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

  testWidgets('switch-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              _row('Off'),
              _row('On', value: true),
              _row('Hover', states: const {InkState.hovered}),
              _row('Focus', value: true, states: const {InkState.focused}),
              _row('Invalid', invalid: true),
              _row('Disabled', disabled: true),
              _row('Disabled on', value: true, disabled: true),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/switch-states.png'),
    );
  });
}
