import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const Key _shot = Key('shot');

Widget _stage(Widget child) => RepaintBoundary(
  key: _shot,
  child: Paper(
    stock: StockName.dotGrid,
    tilt: false,
    shadow: PaperShadow.none,
    seed: 'stage',
    child: Overlay(
      initialEntries: [OverlayEntry(builder: (context) => child)],
    ),
  ),
);

Future<void> _shotOf(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_stage(child)));
  await tester.pumpAndSettle();
}

List<Widget> _pens({bool quill = true}) => [
  const SelectItem(value: 'felt', child: Text('Felt tip')),
  const SelectItem(value: 'pencil', child: Text('Pencil')),
  const SelectItem(value: 'marker', child: Text('Marker')),
  if (quill)
    const SelectItem(
      value: 'quill',
      disabled: true,
      child: Text('Quill (out of ink)'),
    ),
];

Widget _field(
  String label,
  String seed, {
  String? value,
  SelectSize size = SelectSize.regular,
  bool invalid = false,
  bool disabled = false,
  Set<InkState> states = const {},
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  spacing: Spacing.d8,
  children: [
    Label(child: Text(label)),
    SizedBox(
      width: 190,
      child: Select(
        defaultValue: value,
        disabled: disabled,
        content: SelectContent(children: _pens()),
        child: SelectTrigger(
          seed: seed,
          size: size,
          invalid: invalid,
          forcedStates: states,
          child: const SelectValue(placeholder: 'Pick a pen'),
        ),
      ),
    ),
  ],
);

const List<(String, List<String>)> _zones = [
  (
    'North America',
    [
      'Eastern (EST)',
      'Central (CST)',
      'Mountain (MST)',
      'Pacific (PST)',
      'Alaska (AKST)',
      'Hawaii (HST)',
    ],
  ),
  (
    'Europe & Africa',
    [
      'Greenwich Mean (GMT)',
      'Central European (CET)',
      'Eastern European (EET)',
      'West Africa (WAT)',
      'Central Africa (CAT)',
      'East Africa (EAT)',
    ],
  ),
  (
    'Asia',
    [
      'Moscow (MSK)',
      'India (IST)',
      'China (CST)',
      'Japan (JST)',
      'Korea (KST)',
    ],
  ),
];

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('select-states in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(520, 300),
      Padding(
        padding: const EdgeInsets.all(Spacing.d24),
        child: Wrap(
          spacing: Spacing.d32,
          runSpacing: Spacing.d20,
          children: [
            _field('Default', 'a'),
            _field('Small', 'b', size: SelectSize.sm, value: 'pencil'),
            _field('Invalid', 'c', invalid: true),
            _field('Disabled', 'd', value: 'felt', disabled: true),
            _field(
              'Hover',
              'e',
              value: 'marker',
              states: {InkState.hovered},
            ),
            _field('Focus', 'f', states: {InkState.focused}),
          ],
        ),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/select-states.png'),
    );
  });

  testWidgets('select-popper in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(420, 330),
      Align(
        alignment: const Alignment(0, -0.8),
        child: SizedBox(
          width: 190,
          child: Select(
            defaultValue: 'banana',
            defaultOpen: true,
            content: SelectContent(
              position: SelectPosition.popper,
              seed: 'fruits',
              children: [
                SelectGroup(
                  children: [
                    const SelectLabel(Text('Fruits')),
                    for (final fruit in [
                      'Apple',
                      'Banana',
                      'Blueberry',
                      'Grapes',
                      'Pineapple',
                    ])
                      SelectItem(
                        value: fruit.toLowerCase(),
                        child: Text(fruit),
                      ),
                  ],
                ),
              ],
            ),
            child: const SelectTrigger(
              seed: 'fruit',
              child: SelectValue(placeholder: 'Pick a fruit'),
            ),
          ),
        ),
      ),
    );
    final select = Select.of(tester.element(find.byType(SelectItem).first));
    select.highlight('blueberry');
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/select-popper.png'),
    );
  });

  testWidgets('select-groups in the light theme', (tester) async {
    await _shotOf(
      tester,
      const Size(460, 420),
      Center(
        child: SizedBox(
          width: 260,
          child: Select(
            defaultValue: 'Central European (CET)',
            defaultOpen: true,
            content: SelectContent(
              maxHeight: 288,
              seed: 'zones',
              children: [
                for (final (index, (region, zones)) in _zones.indexed)
                  SelectGroup(
                    children: [
                      if (index > 0) SelectSeparator(seed: region),
                      SelectLabel(Text(region)),
                      for (final zone in zones)
                        SelectItem(value: zone, child: Text(zone)),
                    ],
                  ),
              ],
            ),
            child: const SelectTrigger(
              seed: 'zone',
              child: SelectValue(placeholder: 'Select a time zone'),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(_shot),
      matchesGoldenFile('../goldens/select-groups.png'),
    );
  });
}
