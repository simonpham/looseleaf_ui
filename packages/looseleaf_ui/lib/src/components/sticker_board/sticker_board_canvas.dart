import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet a [StickerBoard]'s stickers sit on: dot-grid paper (any
/// [stock]) filling the width, [height] tall (or the height a tight parent
/// such as [Expanded] gives it, upstream's `flex-1`), clipping stickers at
/// its edges. A press on bare paper lets go of the selection. With no stickers
/// it shows [empty] (“Nothing stuck down yet.”).
///
/// Mirrors `StickerBoardCanvas` in upstream
/// `src/components/ui/sticker-board.tsx`.
class StickerBoardCanvas extends StatelessWidget {
  const StickerBoardCanvas({
    super.key,
    this.stock = StockName.dotGrid,
    this.tilt = false,
    this.height = minHeight,
    this.empty,
  });

  /// Upstream's `min-h-72`.
  static const double minHeight = 288;

  /// The paper.
  final StockName stock;

  /// The seeded resting tilt of the paper.
  final bool tilt;

  /// The canvas height, at least [minHeight]; a parent with a tight height
  /// sets it instead.
  final double height;

  /// Shown when no sticker is on the board.
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final scope = StickerBoardScope.of(context);
    final theme = LooseleafTheme.of(context);
    final stacked = [...scope.items.indexed]
      ..sort((a, b) {
        final lifted = _rank(a.$2.id, scope.lifted).compareTo(
          _rank(b.$2.id, scope.lifted),
        );
        if (lifted != 0) return lifted;
        final byZ = a.$2.z.compareTo(b.$2.z);
        if (byZ != 0) return byZ;
        return a.$1.compareTo(b.$1);
      });
    return LayoutBuilder(
      builder: (context, outer) => _sheet(
        context,
        scope,
        theme,
        stacked,
        fillHeight: switch (outer.hasTightHeight) {
          true => outer.maxHeight,
          false => null,
        },
      ),
    );
  }

  Widget _sheet(
    BuildContext context,
    StickerBoardScope scope,
    LooseleafThemeData theme,
    List<(int, StickerBoardItem)> stacked, {
    required double? fillHeight,
  }) {
    final board = scope.board;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: board.widget.label,
      hint: switch (scope.editable) {
        true => StickerBoard.help,
        false => null,
      },
      child: Paper(
        stock: stock,
        tilt: tilt,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(
              switch (constraints.hasBoundedWidth) {
                true => constraints.maxWidth,
                false => 640,
              },
              fillHeight ?? math.max(minHeight, height),
            );
            board.canvasSize = size;
            return ClipRect(
              child: SizedBox(
                key: board.canvasKey,
                width: size.width,
                height: size.height,
                child: Focus(
                  focusNode: board.surfaceFocus,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (_) {
                            if (scope.editable) board.select(null);
                          },
                        ),
                      ),
                      for (final (_, item) in stacked)
                        StickerBoardSticker(key: ValueKey(item.id), item: item),
                      if (scope.items.isEmpty)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Padding(
                              padding: const EdgeInsets.all(Spacing.d24),
                              child: Center(
                                child: DefaultTextStyle.merge(
                                  textAlign: TextAlign.center,
                                  style: theme.typography.face(
                                    KevinSansFace.script,
                                    cssSize: 24,
                                    cssLineHeight: 32 / 24,
                                    color: theme.colors.pencilText,
                                  ),
                                  child:
                                      empty ??
                                      const Text('Nothing stuck down yet.'),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static int _rank(String id, String? lifted) => switch (id == lifted) {
    true => 1,
    false => 0,
  };
}
