import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sticker_sheet/sticker_sheet.dart';

/// What a [StickerSheet] shares with its items: which are peeled, ways to
/// peel and stick them, and the sheet's settings.
class StickerSheetScope extends InheritedWidget {
  const StickerSheetScope({
    super.key,
    required this.peeled,
    required this.peel,
    required this.stick,
    required this.size,
    required this.restorable,
    required this.disabled,
    required super.child,
  });

  /// The ids peeled off.
  final List<String> peeled;

  /// Peels an item off.
  final ValueChanged<StickerSheetPeel> peel;

  /// Sticks an item back on.
  final ValueChanged<StickerSheetPeel> stick;

  /// The stickers' size in pixels.
  final double size;

  /// Peeled stickers can be stuck back.
  final bool restorable;

  /// No item can be peeled.
  final bool disabled;

  /// The nearest sheet's scope.
  static StickerSheetScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StickerSheetScope>();
    if (scope == null) {
      throw FlutterError(
        'StickerSheetItem must be used inside a StickerSheet.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(StickerSheetScope oldWidget) =>
      !listEquals(oldWidget.peeled, peeled) ||
      oldWidget.size != size ||
      oldWidget.restorable != restorable ||
      oldWidget.disabled != disabled ||
      oldWidget.peel != peel ||
      oldWidget.stick != stick;
}
