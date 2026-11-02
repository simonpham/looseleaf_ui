import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerGalleryExample extends StatelessWidget {
  const StickerGalleryExample({super.key});

  static const _shelves = [
    ('statusPointers', 'Status'),
    ('spaceWeather', 'Space'),
    ('foodDrink', 'Food'),
    ('officeDesk', 'Office'),
    ('natureAnimals', 'Nature'),
    ('facesCelebrate', 'Faces'),
    ('badgesStamps', 'Badges'),
  ];

  @override
  Widget build(BuildContext context) => Tabs(
    defaultValue: _shelves.first.$1,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: TabsList(
          children: [
            for (final (key, label) in _shelves)
              TabsTrigger(
                value: key,
                horizontalPadding: Spacing.d8,
                child: Text(label),
              ),
          ],
        ),
      ),
      for (final (key, label) in _shelves)
        TabsContent(
          value: key,
          child: Semantics(
            label: '$label stickers',
            child: _Shelf(
              names: [
                for (final name in stickerBatches[key]?.keys ?? <String>[])
                  if (!name.startsWith('stamp-')) name,
              ],
            ),
          ),
        ),
    ],
  );
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.names});

  static const _minCell = 144.0;

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              ((constraints.maxWidth + Spacing.d16) / (_minCell + Spacing.d16))
                  .floor()
                  .clamp(1, names.length);
          final cell =
              (constraints.maxWidth - Spacing.d16 * (columns - 1)) / columns;
          return Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d16,
            children: [
              for (final name in names)
                SizedBox(
                  width: cell,
                  child: Column(
                    spacing: Spacing.d4,
                    children: [
                      Sticker(name, size: 80),
                      Text(
                        name,
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.pencilText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
