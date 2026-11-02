import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of the drawn text fields, from upstream
/// `src/components/ui/input.tsx` (`frame` and `control`).
abstract final class InputMetrics {
  /// `h-9 compact:h-8 calm:h-7`.
  static const ByDensity<double> height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  /// The control's `px-3 py-1`.
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.symmetric(
    horizontal: Spacing.d12,
    vertical: Spacing.d4,
  );

  /// `aria-invalid:pe-9`: room for the drawn `!` at the end of the line.
  static const double invalidEnd = Spacing.d36;

  /// `start-3` / `end-3`: where a prefix or suffix sits inside the box.
  static const double slotInset = Spacing.d12;

  /// The field text: `font-hand text-base calm:text-[15px]` in
  /// `--ll-input-ink`, graphite when disabled.
  static TextStyle text(LooseleafThemeData theme, {bool disabled = false}) =>
      theme.typography.face(
        KevinSansFace.hand,
        cssSize: switch (theme.density) {
          LooseleafDensity.calm => 15,
          _ => 16,
        },
        cssLineHeight: 1.5,
        color: switch (disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.inputInk,
        },
      );
}
