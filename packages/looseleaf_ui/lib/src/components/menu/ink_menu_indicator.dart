import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The shapes a choice row's indicator comes in.
enum InkMenuIndicatorKind {
  /// A pencil box with a felt-tip tick.
  check,

  /// A pencil ring with a bold felt dot.
  radio,
}

/// The pencil box or ring at the start of a tick or radio row, with the
/// blue felt tick or dot written over it (wiped on) while [on].
///
/// Mirrors `MENU_INDICATOR` and `MENU_MARK` in upstream
/// `src/lib/menu-styles.ts`.
class InkMenuIndicator extends StatelessWidget {
  const InkMenuIndicator({super.key, required this.kind, required this.on});

  /// A box or a ring.
  final InkMenuIndicatorKind kind;

  /// Whether the tick or dot shows.
  final bool on;

  /// The tick's size (`size={22}`).
  static const double _tick = Spacing.d22;

  /// The dot's size (`size={26}`).
  static const double _dot = Spacing.d26;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final (outline, mark, size, lift) = switch (kind) {
      InkMenuIndicatorKind.check => ('square', 'check', _tick, -Spacing.d1),
      InkMenuIndicatorKind.radio => ('circle', 'dot', _dot, 0.0),
    };
    return ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          InkIcon(outline, size: Spacing.d16, color: colors.pencilMark),
          if (on)
            InkMarkWipe(
              duration: InkMotion.sheet,
              child: OverflowBox(
                maxWidth: size,
                maxHeight: size,
                child: Transform.translate(
                  offset: Offset(0, lift),
                  child: InkIcon(mark, size: size, color: colors.inkYou),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
