import 'dart:ui';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [ButtonVariant]'s label color, from the `variant` classes of upstream
/// `buttonVariants` (`text-primary-foreground`, `text-paper`, …).
extension ButtonColors on ButtonVariant {
  /// The label color; disabled labels are `text-pencil-text`, and a hovered
  /// link turns `text-link-hover`.
  Color label(
    LooseleafColors colors, {
    required bool disabled,
    required bool hovered,
  }) {
    if (disabled) return colors.pencilText;
    return switch ((this, hovered)) {
      (ButtonVariant.destructive, _) => colors.paper,
      (ButtonVariant.link, false) => colors.link,
      (ButtonVariant.link, true) => colors.linkHover,
      _ => colors.ink,
    };
  }
}
