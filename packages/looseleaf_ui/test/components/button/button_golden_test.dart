import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

const _states = <String, Set<InkState>>{
  'rest': {},
  'hover': {InkState.hovered},
  'pressed': {InkState.pressed},
  'focus': {InkState.focused},
};

Widget _grid() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d20,
  children: [
    for (final variant in ButtonVariant.values)
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d20,
        children: [
          for (final MapEntry(key: name, value: states) in _states.entries)
            Button(
              variant: variant,
              seed: '${variant.id}-$name',
              forcedStates: states,
              child: Text(variant.id),
            ),
          Button(
            variant: variant,
            seed: '${variant.id}-disabled',
            disabled: true,
            child: Text(variant.id),
          ),
        ],
      ),
  ],
);

Widget _sizes() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d20,
  children: [
    for (final shape in ButtonShape.values)
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d16,
        children: [
          for (final size in ButtonSize.values)
            Button(
              variant: ButtonVariant.outline,
              size: size,
              shape: shape,
              seed: '${size.id}-${shape.name}',
              leading: switch (size.isIcon) {
                true => null,
                false => const _Square(),
              },
              child: switch (size.isIcon) {
                true => const _Square(),
                false => Text(size.id),
              },
            ),
        ],
      ),
  ],
);

class _Square extends StatelessWidget {
  const _Square();

  @override
  Widget build(BuildContext context) {
    final icon = IconTheme.of(context);
    return SizedBox.square(
      dimension: icon.size,
      child: ColoredBox(color: icon.color ?? const Color(0x00000000)),
    );
  }
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  for (final (name, build) in [
    ('button-states', _grid),
    ('button-sizes', _sizes),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(2400, 1400);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(componentHost(goldenPanel(build())));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile('../goldens/$name.png'),
      );
    });
  }
}
