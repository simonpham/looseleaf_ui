import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(
  String name, {
  ToggleVariant variant = ToggleVariant.primary,
  bool value = false,
  bool disabled = false,
  bool invalid = false,
  ToggleTone? tone,
  Set<InkState> states = const {},
}) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d16,
  children: [
    for (final size in ToggleSize.values) ...[
      Toggle(
        value: value,
        variant: variant,
        size: size,
        disabled: disabled,
        invalid: invalid,
        tone: tone,
        seed: '$name-${size.name}',
        forcedStates: states,
        child: Text(name),
      ),
      Toggle(
        value: value,
        variant: variant,
        size: size,
        disabled: disabled,
        invalid: invalid,
        tone: tone,
        seed: '$name-${size.name}-icon',
        forcedStates: states,
        child: const Text('B'),
      ),
    ],
  ],
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('toggle-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: [
              _row('Off'),
              _row('On', value: true),
              _row('Marker', value: true, tone: ToggleTone.marker),
              _row('Hover', states: const {InkState.hovered}),
              _row('Focus', states: const {InkState.focused}),
              _row('Outline', variant: ToggleVariant.outline),
              _row('Outline on', variant: ToggleVariant.outline, value: true),
              _row('Invalid', invalid: true),
              _row('Disabled', disabled: true),
              _row('Disabled on', disabled: true, value: true),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/toggle-states.png'),
    );
  });
}
