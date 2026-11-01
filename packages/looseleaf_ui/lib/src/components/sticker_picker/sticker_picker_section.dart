import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:looseleaf_ui/src/components/sticker_picker/sticker_picker.dart';

/// A titled run of stickers in a picker's list: the recent ones, a batch,
/// or what a search found.
class StickerPickerSection {
  const StickerPickerSection({
    required this.key,
    required this.label,
    required this.items,
  });

  /// Identifies the section.
  final String key;

  /// The heading.
  final String label;

  final List<StickerPickerItem> items;

  /// Whether [entry] matches every one of [words] (lower case) in its
  /// label, name, batch or tags.
  ///
  /// Mirrors `matches` in upstream `src/components/ui/sticker-picker.tsx`.
  static bool matches(StickerPickerItem entry, List<String> words) {
    final hay =
        '${entry.label} ${entry.name} ${entry.categoryLabel} '
                '${entry.tags.join(' ')}'
            .toLowerCase();
    return words.every(hay.contains);
  }

  /// The cell an arrow [key] moves to from section [s], item [i] in a grid
  /// of [cols] columns, crossing into the next or previous section; null
  /// at the ends.
  ///
  /// Mirrors `neighbour` in upstream `src/components/ui/sticker-picker.tsx`.
  static (int, int)? neighbour(
    List<StickerPickerSection> sections,
    (int, int) at,
    LogicalKeyboardKey key,
    int cols,
  ) {
    final (s, i) = at;
    final last = sections.length - 1;
    final count = sections[s].items.length;
    final col = i % cols;
    switch (key) {
      case LogicalKeyboardKey.arrowRight:
        if (i < count - 1) return (s, i + 1);
        if (s < last) return (s + 1, 0);
        return null;
      case LogicalKeyboardKey.arrowLeft:
        if (i > 0) return (s, i - 1);
        if (s > 0) return (s - 1, sections[s - 1].items.length - 1);
        return null;
      case LogicalKeyboardKey.arrowDown:
        if (i + cols < count) return (s, i + cols);
        if (s < last) {
          return (s + 1, math.min(col, sections[s + 1].items.length - 1));
        }
        return null;
      case LogicalKeyboardKey.arrowUp:
        if (i - cols >= 0) return (s, i - cols);
        if (s == 0) return null;
        final prev = sections[s - 1].items.length;
        final lastRow = ((prev - 1) ~/ cols) * cols;
        return (s - 1, math.min(lastRow + col, prev - 1));
    }
    return null;
  }
}
