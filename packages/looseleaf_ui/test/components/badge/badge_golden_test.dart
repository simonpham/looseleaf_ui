import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final icon = IconTheme.of(context);
    return SizedBox.square(
      dimension: icon.size,
      child: ColoredBox(color: icon.color ?? const Color(0x00000000)),
    );
  }
}

Widget _variants() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d16,
  children: [
    for (final (name, states) in [
      ('rest', <InkState>{}),
      ('hover', {InkState.hovered}),
      ('focus', {InkState.focused}),
    ])
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d12,
        children: [
          for (final variant in BadgeVariant.values)
            Badge(
              variant: variant,
              seed: '${variant.id}-$name',
              forcedStates: states,
              onPressed: switch (name) {
                'rest' => null,
                _ => () {},
              },
              child: Text(variant.id),
            ),
        ],
      ),
  ],
);

Widget _sizes() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d16,
  children: [
    for (final size in BadgeSize.values)
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d12,
        children: [
          Badge(size: size, seed: 'l-${size.id}', child: Text(size.id)),
          Badge(
            size: size,
            variant: BadgeVariant.outline,
            seed: 'i-${size.id}',
            leading: const _Dot(),
            child: const Text('Icon'),
          ),
          for (final tone in BadgeTone.values)
            Badge(
              size: size,
              tone: tone,
              seed: '${tone.name}-${size.id}',
              child: Text(tone.name),
            ),
        ],
      ),
  ],
);

Widget _counts() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d16,
  children: [
    const Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        Badge(count: 3, seed: 'c3'),
        Badge(count: 8, variant: BadgeVariant.secondary, seed: 'c8'),
        Badge(count: 42, variant: BadgeVariant.outline, seed: 'c42'),
        Badge(count: 128, variant: BadgeVariant.destructive, seed: 'c128'),
        Badge(count: 1200, max: 999, variant: BadgeVariant.outline, seed: 'c'),
      ],
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        for (final (count, variant) in [
          (1, BadgeVariant.outline),
          (3, BadgeVariant.outline),
          (5, BadgeVariant.outline),
          (7, BadgeVariant.secondary),
          (12, BadgeVariant.primary),
          (9, BadgeVariant.destructive),
        ])
          Badge(tally: true, count: count, variant: variant, seed: 't$count'),
      ],
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

  for (final (name, build) in [
    ('badge-variants', _variants),
    ('badge-sizes', _sizes),
    ('badge-counts', _counts),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(2000, 600);
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
