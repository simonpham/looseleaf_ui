import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sticker_picker/sticker_picker.dart';

/// What a [StickerPicker] shares with its content: the stickers on offer,
/// the recent ones, the chosen one and a way to choose.
class StickerPickerScope extends InheritedWidget {
  const StickerPickerScope({
    super.key,
    required this.catalog,
    required this.recent,
    required this.value,
    required this.choose,
    required super.child,
  });

  /// Every sticker on offer.
  final List<StickerPickerItem> catalog;

  /// Recently used sticker names, listed first.
  final List<String> recent;

  /// The chosen sticker's name.
  final String? value;

  /// Picks a sticker.
  final ValueChanged<StickerPickerItem> choose;

  /// The nearest picker's scope.
  static StickerPickerScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StickerPickerScope>();
    if (scope == null) {
      throw FlutterError(
        'Sticker picker parts must be used inside a StickerPicker.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(StickerPickerScope oldWidget) =>
      !identical(oldWidget.catalog, catalog) ||
      !listEquals(oldWidget.recent, recent) ||
      oldWidget.value != value ||
      oldWidget.choose != choose;
}
