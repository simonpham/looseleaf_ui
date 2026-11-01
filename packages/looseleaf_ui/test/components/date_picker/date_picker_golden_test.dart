import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

final DateTime _day = DateTime(2026, 9, 17);

Widget _picker(
  String seed, {
  DateTime? value,
  bool typeable = true,
  bool disabled = false,
  bool invalid = false,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 260,
  child: DatePicker(
    value: value,
    typeable: typeable,
    disabled: disabled,
    invalid: invalid,
    seed: seed,
    forcedStates: states,
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

  testWidgets('date-picker-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1300, 900);
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
                  _picker('a', value: _day),
                  _picker('b'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _picker('c', value: _day, states: const {InkState.focused}),
                  _picker('d', value: _day, invalid: true),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _picker('e', value: _day, disabled: true),
                  _picker('f', value: _day, typeable: false),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d24,
                children: [
                  _picker('g', typeable: false),
                  SizedBox(
                    width: 260,
                    child: DateRangePicker(
                      value: DateRange(
                        from: DateTime(2026, 9, 1),
                        to: DateTime(2026, 9, 9),
                      ),
                      seed: 'range',
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
      matchesGoldenFile('../goldens/date-picker-states.png'),
    );
  });

  testWidgets('date-picker-open with presets', (tester) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Align(
                alignment: const Alignment(-0.6, -0.8),
                child: SizedBox(
                  width: 288,
                  child: DatePicker(
                    value: _day,
                    open: true,
                    seed: 'open',
                    presets: [
                      for (final label in [
                        'Today',
                        'Tomorrow',
                        'In a week',
                        'Next month',
                      ])
                        DatePreset(label: label, value: () => _day),
                    ],
                    calendarBuilder: (context, selected, onSelect, _) =>
                        const SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(child: Text('Calendar')),
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
    await expectLater(
      find.byType(Overlay),
      matchesGoldenFile('../goldens/date-picker-open.png'),
    );
  });
}
