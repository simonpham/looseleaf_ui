import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';

/// Hands a [StickerBoard]'s state to its canvas, stickers and toolbar.
class StickerBoardScope extends InheritedWidget {
  const StickerBoardScope({
    super.key,
    required this.board,
    required this.items,
    required this.selectedId,
    required this.editable,
    required this.lifted,
    required super.child,
  });

  /// The board: its edits and settings.
  final StickerBoardState board;

  /// The stickers, mended.
  final List<StickerBoardItem> items;

  /// The selected sticker, if it is on the board.
  final String? selectedId;

  /// Stickers can be moved and edited.
  final bool editable;

  /// The sticker being dragged.
  final String? lifted;

  /// The nearest board's scope.
  static StickerBoardScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StickerBoardScope>();
    if (scope == null) {
      throw FlutterError(
        'Sticker board parts must be used inside a StickerBoard.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(StickerBoardScope oldWidget) =>
      oldWidget.items != items ||
      oldWidget.selectedId != selectedId ||
      oldWidget.editable != editable ||
      oldWidget.lifted != lifted ||
      oldWidget.board != board;
}
