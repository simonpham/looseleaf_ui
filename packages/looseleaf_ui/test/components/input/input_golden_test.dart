import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _field(
  String name, {
  String? text,
  bool disabled = false,
  bool invalid = false,
  bool readOnly = false,
  bool obscureText = false,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 280,
  child: Input(
    controller: switch (text) {
      final value? => TextEditingController(text: value),
      null => null,
    },
    placeholder: name,
    disabled: disabled,
    invalid: invalid,
    readOnly: readOnly,
    obscureText: obscureText,
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

  testWidgets('input-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              Row(
                spacing: Spacing.d24,
                children: [
                  _field('you@example.com'),
                  _field('Ada', text: 'Ada Lovelace'),
                ],
              ),
              Row(
                spacing: Spacing.d24,
                children: [
                  _field('Hover', states: const {InkState.hovered}),
                  _field(
                    'Focus',
                    text: 'Focused',
                    states: const {InkState.focused},
                  ),
                ],
              ),
              Row(
                spacing: Spacing.d24,
                children: [
                  _field('Invalid', text: 'not-an-email', invalid: true),
                  _field('Disabled', disabled: true),
                ],
              ),
              Row(
                spacing: Spacing.d24,
                children: [
                  _field('Read only', text: 'Printed value', readOnly: true),
                  _field('Password', text: 'hunter2', obscureText: true),
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
      matchesGoldenFile('../goldens/input-states.png'),
    );
  });
}
