import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _countries = [
  NativeSelectOption(value: 'is', label: 'Iceland'),
  NativeSelectOption(value: 'pt', label: 'Portugal'),
  NativeSelectOption(value: 'jp', label: 'Japan', disabled: true),
  NativeSelectOption(value: 'ca', label: 'Canada'),
];

Widget _select(
  String name, {
  String? value,
  NativeSelectSize size = NativeSelectSize.regular,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => NativeSelect<String>(
  value: value,
  options: _countries,
  placeholder: 'Choose a country',
  size: size,
  disabled: disabled,
  invalid: invalid,
  seed: name,
  forcedStates: states,
  onChanged: (_) {},
);

Widget _panel(Widget child) => SizedBox(
  width: 540,
  height: 420,
  child: RepaintBoundary(
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: child,
            ),
          ),
        ),
      ],
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

  testWidgets('native-select-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        _panel(
          Align(
            alignment: Alignment.topLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d24,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d16,
                  children: [
                    _select('placeholder'),
                    _select('chosen', value: 'pt'),
                    _select(
                      'hover',
                      value: 'is',
                      states: const {InkState.hovered},
                    ),
                    _select(
                      'focus',
                      value: 'ca',
                      states: const {InkState.focused},
                    ),
                    _select('invalid', invalid: true),
                    _select('disabled', value: 'pt', disabled: true),
                    _select('sm', value: 'is', size: NativeSelectSize.sm),
                  ],
                ),
                _select('open', value: 'pt'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Portugal').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/native-select-states.png'),
    );
  });
}
