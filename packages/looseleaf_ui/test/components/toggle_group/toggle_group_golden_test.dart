import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _group(
  String name, {
  Set<String> value = const {'Center'},
  ToggleVariant variant = ToggleVariant.primary,
  double spacing = 0,
  Axis direction = Axis.horizontal,
  bool disabled = false,
  bool invalid = false,
  ToggleSize size = ToggleSize.regular,
  String? focused,
}) => ToggleGroup<String>(
  value: value,
  variant: variant,
  spacing: spacing,
  direction: direction,
  disabled: disabled,
  invalid: invalid,
  size: size,
  seed: name,
  children: [
    for (final item in ['Left', 'Center', 'Right'])
      ToggleGroupItem(
        value: item,
        seed: '$name-$item',
        forcedStates: {if (item == focused) InkState.focused},
        child: Text(item),
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

  testWidgets('toggle-group-variants in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1100);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d32,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  _group('joined'),
                  _group('focus', focused: 'Right'),
                  _group('outline', variant: ToggleVariant.outline),
                  _group('spaced', spacing: Spacing.d8),
                  _group(
                    'spaced-outline',
                    spacing: Spacing.d8,
                    variant: ToggleVariant.outline,
                    value: const {'Left', 'Right'},
                  ),
                  _group('sm', size: ToggleSize.sm),
                  _group('lg', size: ToggleSize.lg),
                  _group('invalid', invalid: true),
                  _group('disabled', disabled: true),
                ],
              ),
              _group(
                'vertical',
                direction: Axis.vertical,
                variant: ToggleVariant.outline,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/toggle-group-variants.png'),
    );
  });

  testWidgets('toggle-group-stretch in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          SizedBox(
            width: Spacing.d320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d16,
              children: [
                ToggleGroup<String>(
                  value: const {'Week'},
                  variant: ToggleVariant.outline,
                  seed: 'stretch',
                  children: [
                    for (final item in ['Day', 'Week', 'Month'])
                      Expanded(
                        child: ToggleGroupItem(
                          value: item,
                          seed: 'stretch-$item',
                          child: Text(item),
                        ),
                      ),
                  ],
                ),
                ToggleGroup<String>(
                  value: const {'Tue'},
                  seed: 'scroll',
                  children: [
                    for (final item in [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ])
                      ToggleGroupItem(
                        value: item,
                        seed: 'scroll-$item',
                        child: Text(item),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/toggle-group-stretch.png'),
    );
  });
}
