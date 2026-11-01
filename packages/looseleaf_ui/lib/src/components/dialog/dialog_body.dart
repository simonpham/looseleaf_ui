import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The scrolling middle of a long dialog: at most 60 % of the window (and
/// 512 px) tall, in 15 px text. It is a tab stop with a focus ring, so the
/// arrow and page keys scroll it; set [focusable] false when it holds its
/// own focusable controls.
///
/// Mirrors `DialogBody` in upstream `src/components/ui/dialog.tsx`.
class DialogBody extends StatefulWidget {
  const DialogBody({
    super.key,
    required this.child,
    this.focusable = true,
    this.controller,
  });

  /// The content.
  final Widget child;

  /// Whether it takes focus to scroll by keyboard.
  final bool focusable;

  /// The scroll controller.
  final ScrollController? controller;

  @override
  State<DialogBody> createState() => _DialogBodyState();
}

class _DialogBodyState extends State<DialogBody> {
  bool _ring = false;

  static const Map<ShortcutActivator, Intent> _keys = {
    SingleActivator(LogicalKeyboardKey.arrowUp): ScrollIntent(
      direction: AxisDirection.up,
    ),
    SingleActivator(LogicalKeyboardKey.arrowDown): ScrollIntent(
      direction: AxisDirection.down,
    ),
    SingleActivator(LogicalKeyboardKey.pageUp): ScrollIntent(
      direction: AxisDirection.up,
      type: ScrollIncrementType.page,
    ),
    SingleActivator(LogicalKeyboardKey.pageDown): ScrollIntent(
      direction: AxisDirection.down,
      type: ScrollIncrementType.page,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final window = MediaQuery.maybeSizeOf(context)?.height ?? double.infinity;
    final tallest = math.min(
      DialogMetrics.bodyMaxHeight,
      window * DialogMetrics.bodyMaxFraction,
    );
    final scroller = SingleChildScrollView(
      controller: widget.controller,
      padding: const EdgeInsets.symmetric(vertical: Spacing.d4),
      child: FocusableActionDetector(
        enabled: widget.focusable,
        shortcuts: _keys,
        onShowFocusHighlight: (shown) => setState(() => _ring = shown),
        child: DefaultTextStyle.merge(
          style: theme.typography.interface(cssSize: 15),
          child: widget.child,
        ),
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: tallest),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          scroller,
          if (_ring)
            Positioned.fill(
              left: -Spacing.d3,
              top: -Spacing.d3,
              right: -Spacing.d3,
              bottom: -Spacing.d3,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colors.focus,
                      width: Spacing.d2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
