import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Sizes and text of the sketchpad's parts, from the classes in upstream
/// `src/components/ui/sketchpad.tsx`.
abstract final class SketchpadMetrics {
  /// A tool label's `pb-[5px]`.
  static const double toolLabelBottom = 5;

  /// A swatch or width button's `size-7`.
  static const double pick = Spacing.d28;

  /// A disabled swatch's `disabled:opacity-60`.
  static const double disabledOpacity = 0.6;

  /// The keyboard cursor's steps: Alt, plain and Shift arrows.
  static const double nudgeFine = 2;
  static const double nudge = 8;
  static const double nudgeFar = 32;

  /// A tool label: `font-hand text-[14px] leading-none font-bold`, pencil
  /// when disabled.
  static TextStyle toolLabel(
    LooseleafThemeData theme, {
    required bool disabled,
  }) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: 14,
    cssLineHeight: 1,
    fontWeight: FontWeight.w700,
    color: switch (disabled) {
      true => theme.colors.pencilText,
      false => theme.colors.ink,
    },
  );
}
