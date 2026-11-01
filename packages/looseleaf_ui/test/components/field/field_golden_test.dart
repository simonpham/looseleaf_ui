import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';
import '../../support/paper_panel.dart';

Widget _form() => const SizedBox(
  width: 448,
  child: FieldSet(
    children: [
      FieldLegend(Text('Your notebook')),
      FieldDescription(Text('Everything is saved as you write, in pencil.')),
      FieldGroup(
        children: [
          Field(
            children: [
              FieldLabel(required: true, seed: 'name', child: Text('Name')),
              Input(seed: 'name', placeholder: 'Field notes'),
              FieldDescription(
                Text('Shows on the spine. You can change it later.'),
              ),
            ],
          ),
          Field(
            invalid: true,
            children: [
              FieldLabel(child: Text('Password')),
              Input(seed: 'pass', invalid: true, placeholder: 'pencil'),
              FieldDescription(Text('Eight characters and a number.')),
              FieldError(
                seed: 'pass',
                errors: ['Use at least 8 characters.', 'Add a number.'],
              ),
            ],
          ),
          FieldSeparator(seed: 'then', child: Text('then')),
          Field(
            disabled: true,
            children: [
              FieldLabel(child: Text('About')),
              Textarea(seed: 'about', disabled: true, placeholder: 'Later'),
            ],
          ),
        ],
      ),
    ],
  ),
);

const _plans = [
  ('starter', 'Starter', 'One notebook, one pen, no rush.'),
  ('studio', 'Studio', 'Ten notebooks and the good highlighters.'),
  ('workshop', 'Workshop', 'A whole desk. Washi tape included.'),
];

Widget _choices() => SizedBox(
  width: 448,
  child: FieldGroup(
    children: [
      Field(
        orientation: FieldOrientation.horizontal,
        children: [
          const FieldContent(
            children: [
              FieldLabel(child: Text('Sync to the cloud')),
              FieldDescription(Text('Keeps every page on all your devices.')),
            ],
          ),
          Switch(value: true, seed: 'sync', onChanged: (_) {}),
        ],
      ),
      const FieldSeparator(seed: 'sep'),
      const Field(
        orientation: FieldOrientation.responsive,
        children: [
          FieldContent(
            children: [
              FieldTitle(Text('Display name')),
              FieldDescription(Text('Sits in a row on wide boxes.')),
            ],
          ),
          SizedBox(
            width: Spacing.d176,
            child: Input(seed: 'display', placeholder: 'Ada'),
          ),
        ],
      ),
      FieldSet(
        children: [
          const FieldLegend(Text('Plan'), variant: FieldLegendVariant.label),
          RadioGroup<String>(
            value: 'studio',
            onChanged: (_) {},
            children: [
              for (final (index, (value, title, help)) in _plans.indexed)
                FieldLabel(
                  seed: value,
                  checked: value == 'studio',
                  forcedStates: switch (index) {
                    2 => const {InkState.hovered},
                    _ => const {},
                  },
                  child: Field(
                    orientation: FieldOrientation.horizontal,
                    children: [
                      FieldContent(
                        children: [
                          FieldTitle(Text(title)),
                          FieldDescription(Text(help)),
                        ],
                      ),
                      RadioGroupItem(value: value, seed: value),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, build) in [
    ('field-form', _form),
    ('field-choices', _choices),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(1100, 1500);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(overlayHost(paperPanel(build())));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }
}
