import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';

/// Moves the focused sticker by ([dx], [dy]) pixels.
class StickerMoveIntent extends Intent {
  const StickerMoveIntent(this.dx, this.dy);

  final double dx;
  final double dy;
}

/// Turns the focused sticker by [degrees].
class StickerTurnIntent extends Intent {
  const StickerTurnIntent(this.degrees);

  final double degrees;
}

/// Sizes the focused sticker by [factor].
class StickerResizeIntent extends Intent {
  const StickerResizeIntent(this.factor);

  final double factor;
}

/// Sets the focused sticker upright at full size.
class StickerResetIntent extends Intent {
  const StickerResetIntent();
}

/// Moves the focused sticker through the stack.
class StickerReorderIntent extends Intent {
  const StickerReorderIntent(this.how);

  final StickerReorder how;
}

/// Removes the focused sticker.
class StickerDeleteIntent extends Intent {
  const StickerDeleteIntent();
}

/// Duplicates the focused sticker.
class StickerDuplicateIntent extends Intent {
  const StickerDuplicateIntent();
}

/// Cancels a drag, else lets go of the sticker.
class StickerReleaseIntent extends Intent {
  const StickerReleaseIntent();
}

Map<ShortcutActivator, Intent> _arrows(
  double step, {
  bool shift = false,
  bool alt = false,
}) => {
  SingleActivator(LogicalKeyboardKey.arrowRight, shift: shift, alt: alt):
      StickerMoveIntent(step, 0),
  SingleActivator(LogicalKeyboardKey.arrowLeft, shift: shift, alt: alt):
      StickerMoveIntent(-step, 0),
  SingleActivator(LogicalKeyboardKey.arrowDown, shift: shift, alt: alt):
      StickerMoveIntent(0, step),
  SingleActivator(LogicalKeyboardKey.arrowUp, shift: shift, alt: alt):
      StickerMoveIntent(0, -step),
};

/// The keys of a focused sticker on a [StickerBoard].
///
/// Mirrors the `keys` handler of `BoardItem` in upstream
/// `src/components/ui/sticker-board.tsx`.
final Map<ShortcutActivator, Intent> stickerBoardShortcuts = {
  ..._arrows(StickerBoard.step),
  ..._arrows(StickerBoard.bigStep, shift: true),
  ..._arrows(StickerBoard.fineStep, alt: true),
  const CharacterActivator('['): const StickerTurnIntent(-StickerBoard.turn),
  const CharacterActivator(']'): const StickerTurnIntent(StickerBoard.turn),
  const CharacterActivator('{'): const StickerTurnIntent(
    -StickerBoard.bigTurn,
  ),
  const CharacterActivator('}'): const StickerTurnIntent(StickerBoard.bigTurn),
  const CharacterActivator('r'): const StickerTurnIntent(StickerBoard.turn),
  const CharacterActivator('R'): const StickerTurnIntent(-StickerBoard.bigTurn),
  const CharacterActivator('='): const StickerResizeIntent(StickerBoard.zoom),
  const CharacterActivator('+'): const StickerResizeIntent(
    StickerBoard.bigZoom,
  ),
  const CharacterActivator('-'): const StickerResizeIntent(
    1 / StickerBoard.zoom,
  ),
  const CharacterActivator('_'): const StickerResizeIntent(
    1 / StickerBoard.bigZoom,
  ),
  const CharacterActivator('0'): const StickerResetIntent(),
  const SingleActivator(LogicalKeyboardKey.pageUp): const StickerReorderIntent(
    StickerReorder.forward,
  ),
  const SingleActivator(LogicalKeyboardKey.pageUp, shift: true):
      const StickerReorderIntent(StickerReorder.front),
  const SingleActivator(LogicalKeyboardKey.pageDown):
      const StickerReorderIntent(StickerReorder.backward),
  const SingleActivator(LogicalKeyboardKey.pageDown, shift: true):
      const StickerReorderIntent(StickerReorder.back),
  const SingleActivator(LogicalKeyboardKey.delete): const StickerDeleteIntent(),
  const SingleActivator(LogicalKeyboardKey.backspace):
      const StickerDeleteIntent(),
  const SingleActivator(LogicalKeyboardKey.keyD, control: true):
      const StickerDuplicateIntent(),
  const SingleActivator(LogicalKeyboardKey.keyD, meta: true):
      const StickerDuplicateIntent(),
  const SingleActivator(LogicalKeyboardKey.escape):
      const StickerReleaseIntent(),
};
