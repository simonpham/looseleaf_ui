import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

const _frameworks = [
  ComboboxItemData(value: 'next', label: 'Next.js'),
  ComboboxItemData(value: 'sveltekit', label: 'SvelteKit'),
  ComboboxItemData(value: 'nuxt', label: 'Nuxt.js'),
  ComboboxItemData(value: 'remix', label: 'Remix'),
  ComboboxItemData(value: 'astro', label: 'Astro'),
];

const _labels = ['Design', 'Garden', 'Travel', 'Recipes', 'Ideas'];

Widget _trigger(
  String seed, {
  String? value,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 256,
  child: Combobox(
    items: _frameworks,
    value: value,
    disabled: disabled,
    invalid: invalid,
    child: ComboboxTrigger(
      seed: seed,
      forcedStates: states,
      child: const ComboboxValue(placeholder: 'Select framework...'),
    ),
  ),
);

Widget _field(String seed, {String? value, bool invalid = false}) => SizedBox(
  width: 256,
  child: Combobox(
    items: _frameworks,
    value: value,
    invalid: invalid,
    child: ComboboxInput(
      seed: seed,
      placeholder: 'Pick a framework',
      showClear: true,
    ),
  ),
);

Widget _panel(Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.paper,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: child,
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('combobox-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1300, 1300);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      overlayHost(
        _panel(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _trigger('t1', value: 'next'),
                  _trigger('t2'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _trigger('t3', states: const {InkState.focused}),
                  _trigger('t4', value: 'remix', invalid: true),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _trigger('t5', value: 'astro', disabled: true),
                  _field('f1', value: 'sveltekit'),
                ],
              ),
              SizedBox(
                width: 384,
                child: Combobox.multiple(
                  items: [
                    for (final label in _labels) ComboboxItemData.of(label),
                  ],
                  values: const ['Design', 'Garden', 'Travel'],
                  child: const ComboboxChips(
                    autoTone: true,
                    seed: 'chips',
                    child: ComboboxChipsInput(),
                  ),
                ),
              ),
              SizedBox(
                width: 384,
                child: Combobox.multiple(
                  items: [
                    for (final label in _labels) ComboboxItemData.of(label),
                  ],
                  values: const ['Recipes', 'Ideas'],
                  disabled: true,
                  child: const ComboboxChips(seed: 'chips-off'),
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
      matchesGoldenFile('../goldens/combobox-states.png'),
    );
  });

  testWidgets('combobox-open with the search and the list', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => const Align(
                alignment: Alignment(0, -0.85),
                child: SizedBox(
                  width: 256,
                  child: Combobox(
                    items: _frameworks,
                    value: 'next',
                    open: true,
                    label: 'Framework',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ComboboxTrigger(
                          seed: 'open',
                          child: ComboboxValue(
                            placeholder: 'Select framework...',
                          ),
                        ),
                        ComboboxContent(
                          seed: 'popup',
                          children: [
                            ComboboxInput(
                              placeholder: 'Search framework...',
                              seed: 'search',
                            ),
                            ComboboxList.items(
                              children: [
                                ComboboxEmpty(
                                  child: Text('No framework found.'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(Overlay),
      matchesGoldenFile('../goldens/combobox-open.png'),
    );
  });
}
