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
  bool ruled = false,
  bool showCount = false,
  int? maxLength,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 280,
  child: Textarea(
    controller: switch (text) {
      final value? => TextEditingController(text: value),
      null => null,
    },
    placeholder: name,
    disabled: disabled,
    invalid: invalid,
    readOnly: readOnly,
    ruled: ruled,
    showCount: showCount,
    maxLength: maxLength,
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

  testWidgets('textarea-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1300);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Tell us what happened…'),
                  _field(
                    'Grows',
                    text: 'It grows with what you write,\nline after line,\nuntil you stop.',
                  ),
                ],
              ),
              Row(
                spacing: Spacing.d24,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Invalid', text: 'Too short', invalid: true),
                  _field('Disabled', disabled: true),
                ],
              ),
              Row(
                spacing: Spacing.d24,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _field('Read only', text: 'Printed value', readOnly: true),
                  _field(
                    'Counted',
                    text: 'Twelve chars',
                    showCount: true,
                    maxLength: 280,
                  ),
                ],
              ),
              _field(
                'Dear diary…',
                text: 'Dear diary,\ntoday I drew a field\nwith rules on it.',
                ruled: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/textarea-states.png'),
    );
  });
}
