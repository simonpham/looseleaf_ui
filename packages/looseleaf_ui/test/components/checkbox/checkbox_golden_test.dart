import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(
  String name, {
  bool? value = false,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d24,
  children: [
    for (final size in [Spacing.d16, Spacing.d20, Spacing.d28])
      Checkbox(
        value: value,
        disabled: disabled,
        invalid: invalid,
        size: size,
        seed: '$name-$size',
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

  testWidgets('checkbox-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d20,
            children: [
              _row('Unchecked'),
              _row('Hover', states: const {InkState.hovered}),
              _row('Focus', states: const {InkState.focused}),
              _row('Checked', value: true),
              _row('Indeterminate', value: null),
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
      matchesGoldenFile('../goldens/checkbox-states.png'),
    );
  });

  testWidgets('checkbox-draw-on halfway through the tick', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    var value = false;
    await tester.pumpWidget(
      componentHost(
        StatefulBuilder(
          builder: (context, setState) => goldenPanel(
            Checkbox(
              value: value,
              size: Spacing.d28,
              seed: 'draw-on',
              onChanged: (next) => setState(() => value = next),
              label: const Text('Drawn on'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(InkSurface));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/checkbox-draw-on.png'),
    );
    await tester.pumpAndSettle();
  });
}
