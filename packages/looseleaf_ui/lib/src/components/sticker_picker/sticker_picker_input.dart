import 'package:looseleaf_ink/looseleaf_ink.dart';

/// A sticker a picker offers: its name, label, batch and search tags.
typedef StickerPickerItem = StickerCatalogEntry;

/// One sticker to offer in a `StickerPicker`, by [name], optionally with
/// its own [label], [category] and extra search [tags].
///
/// Mirrors `StickerPickerInput` in upstream
/// `src/components/ui/sticker-picker.tsx`.
class StickerPickerInput {
  const StickerPickerInput(
    this.name, {
    this.label,
    this.category,
    this.tags = const [],
  });

  /// The sticker's name in the catalog.
  final String name;

  /// The label shown; the catalog's when null.
  final String? label;

  /// The batch it is listed under; the catalog's when null.
  final String? category;

  /// Search words added to the catalog's.
  final List<String> tags;

  /// The picker's entries for [list]: the whole catalog when null,
  /// unknown names dropped.
  ///
  /// Mirrors `catalogFrom` in upstream `src/components/ui/sticker-picker.tsx`.
  static List<StickerPickerItem> catalogFrom(List<StickerPickerInput>? list) {
    final all = stickerCatalog();
    if (list == null) return all;
    final known = {for (final e in all) e.name: e};
    return [
      for (final entry in list)
        if (_base(entry.name, known) case final base?)
          StickerPickerItem(
            name: base.name,
            label: entry.label ?? base.label,
            category: entry.category ?? base.category,
            categoryLabel: switch (entry.category) {
              final key? => categoryLabel(key),
              null => base.categoryLabel,
            },
            tags: [...base.tags, ...entry.tags],
          ),
    ];
  }

  static StickerPickerItem? _base(
    String name,
    Map<String, StickerPickerItem> known,
  ) {
    if (known[name] case final entry?) return entry;
    if (!hasSticker(name)) return null;
    return StickerPickerItem(
      name: name,
      label: stickerLabel(name),
      category: 'stickers',
      categoryLabel: 'Stickers',
      tags: const [],
    );
  }
}
