import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _row(
  ItemVariant variant,
  String icon,
  String title,
  String description,
  String action,
) => InkItem(
  variant: variant,
  seed: title,
  children: [
    ItemMedia(
      variant: ItemMediaVariant.icon,
      seed: title,
      child: InkIcon(icon, seed: icon),
    ),
    ItemContent(
      children: [ItemTitle(Text(title)), ItemDescription(Text(description))],
    ),
    ItemActions(
      children: [
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          seed: action,
          onPressed: () {},
          child: Text(action),
        ),
      ],
    ),
  ],
);

Widget _variants() => SizedBox(
  width: 448,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d24,
    children: [
      _row(
        ItemVariant.regular,
        'bell',
        'Notifications',
        'Choose what lands in your inbox.',
        'Edit',
      ),
      _row(
        ItemVariant.outline,
        'user',
        'Profile',
        'Your name, your face, your pencil case.',
        'Open',
      ),
      _row(
        ItemVariant.muted,
        'settings',
        'Preferences',
        'Density, motion and the color of the desk.',
        'Change',
      ),
      InkItem(
        variant: ItemVariant.outline,
        size: ItemSize.sm,
        seed: 'small',
        children: [
          const ItemContent(children: [ItemTitle(Text('Small'))]),
          ItemActions(
            children: [
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                seed: 'undo',
                onPressed: () {},
                child: const Text('Undo'),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
);

const _pages = [
  ('file', 'Quarterly pages', 'Last opened on Tuesday, tidy.'),
  ('folder', 'Receipts', 'Forty-one of them, all crumpled.'),
  ('calendar', 'Calendar', 'Three things this week, one of them cake.'),
];

Widget _ruled() => SizedBox(
  width: 448,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d32,
    children: [
      ItemGroup(
        ruled: true,
        children: [
          for (final (index, (icon, title, description)) in _pages.indexed)
            InkItem(
              seed: title,
              onPressed: () {},
              forcedStates: switch (index) {
                1 => const {InkState.hovered},
                2 => const {InkState.focused},
                _ => const {},
              },
              children: [
                ItemMedia(
                  variant: ItemMediaVariant.icon,
                  seed: title,
                  child: InkIcon(icon, seed: icon),
                ),
                ItemContent(
                  children: [
                    ItemTitle(Text(title)),
                    ItemDescription(Text(description)),
                  ],
                ),
                const InkIcon('chevron-right', size: Spacing.d16, seed: 'c'),
              ],
            ),
        ],
      ),
      const ItemGroup(
        children: [
          InkItem(
            size: ItemSize.sm,
            children: [
              ItemContent(children: [ItemTitle(Text('Before the separator'))]),
            ],
          ),
          ItemSeparator(seed: 'pencil'),
          InkItem(
            size: ItemSize.sm,
            children: [
              ItemContent(children: [ItemTitle(Text('Between them'))]),
            ],
          ),
          ItemSeparator(variant: SeparatorVariant.dashed, seed: 'dashed'),
          InkItem(
            size: ItemSize.sm,
            children: [
              ItemContent(children: [ItemTitle(Text('After it'))]),
            ],
          ),
        ],
      ),
      const InkItem(
        variant: ItemVariant.outline,
        seed: 'photo',
        children: [
          ItemHeader(
            children: [
              Text('Tuesday'),
              Badge(seed: 'b', child: Text('new')),
            ],
          ),
          ItemMedia(
            variant: ItemMediaVariant.image,
            child: ColoredBox(
              color: Color(0xFF7FA37C),
              child: SizedBox.square(dimension: Spacing.d40),
            ),
          ),
          ItemContent(
            children: [
              ItemTitle(Text('Pond walk')),
              ItemDescription(Text('Twelve photos, two of them ducks.')),
            ],
          ),
          ItemFooter(children: [Text('3 comments'), Text('share')]),
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
    ('item-variants', _variants),
    ('item-lists', _ruled),
  ]) {
    testWidgets('$name in the light theme', (tester) async {
      tester.view.physicalSize = const Size(1100, 1500);
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
