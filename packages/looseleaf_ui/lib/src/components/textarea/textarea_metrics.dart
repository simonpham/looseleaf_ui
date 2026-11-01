import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The metrics of [Textarea], from upstream
/// `src/components/ui/textarea.tsx` (`frame`, `control`, `RULED_*`).
abstract final class TextareaMetrics {
  /// `min-h-16`.
  static const double minHeight = Spacing.d64;

  /// `min-h-24` when ruled.
  static const double ruledMinHeight = Spacing.d96;

  /// `leading-6`.
  static const double lineHeight = Spacing.d24;

  /// `RULED_LINE` (`leading-7`): the rule spacing.
  static const double ruledLineHeight = Spacing.d28;

  /// `RULED_TOP`: the top of the first ruled line.
  static const double ruleTop = Spacing.d8;

  /// The control's `px-3 py-2`.
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.symmetric(
    horizontal: Spacing.d12,
    vertical: Spacing.d8,
  );

  /// `pb-7`: room for the counter under the text.
  static const double countBottom = Spacing.d28;

  /// The counter's `end-6 bottom-1.5`.
  static const EdgeInsetsDirectional countInset = EdgeInsetsDirectional.only(
    end: Spacing.d24,
    bottom: Spacing.d6,
  );

  /// The corner the resize grip answers in.
  static const double grip = Spacing.d16;

  /// The field text with a line box of [lineHeight] pixels.
  static TextStyle text(
    LooseleafThemeData theme, {
    required double lineHeight,
    bool disabled = false,
  }) {
    final style = InputMetrics.text(theme, disabled: disabled);
    final cssSize = switch (theme.density) {
      LooseleafDensity.calm => 15.0,
      _ => 16.0,
    };
    return theme.typography
        .face(
          KevinSansFace.hand,
          cssSize: cssSize,
          cssLineHeight: lineHeight / cssSize,
        )
        .copyWith(color: style.color);
  }
}
