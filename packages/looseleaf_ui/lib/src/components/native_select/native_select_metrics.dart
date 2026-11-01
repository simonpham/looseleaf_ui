import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// [NativeSelect] sizes, upstream's `size` prop.
enum NativeSelectSize {
  /// `h-9 text-base`.
  regular,

  /// `h-8 text-[15px]`.
  sm;

  /// `h-*` with its `compact:` / `calm:` steps.
  ByDensity<double> get height => switch (this) {
    NativeSelectSize.regular => const ByDensity(
      comfortable: Spacing.d36,
      compact: Spacing.d32,
      calm: Spacing.d28,
    ),
    NativeSelectSize.sm => const ByDensity(
      comfortable: Spacing.d32,
      compact: Spacing.d28,
      calm: Spacing.d28,
    ),
  };

  /// The CSS font size at [density].
  double cssFontSize(LooseleafDensity density) => switch ((this, density)) {
    (NativeSelectSize.regular, LooseleafDensity.comfortable) ||
    (NativeSelectSize.regular, LooseleafDensity.compact) => 16,
    _ => 15,
  };
}

/// The metrics of [NativeSelect], from upstream
/// `src/components/ui/native-select.tsx`.
abstract final class NativeSelectMetrics {
  /// The select's `ps-3 pe-10`: room for the chevron cell at the end.
  static const EdgeInsetsDirectional padding = EdgeInsetsDirectional.only(
    start: Spacing.d12,
    end: Spacing.d40,
  );

  /// `aria-invalid:pe-14`: room for the `!` too.
  static const double invalidEnd = Spacing.d56;

  /// The chevron's `end-2`.
  static const double chevronEnd = Spacing.d8;

  /// The chevron's `size={16}`.
  static const double chevron = Spacing.d16;

  /// The gap between the box and its list.
  static const double popupGap = Spacing.d4;

  /// An option row's inset in the list.
  static const EdgeInsetsDirectional optionPadding =
      EdgeInsetsDirectional.symmetric(
        horizontal: Spacing.d12,
        vertical: Spacing.d4,
      );

  /// The list's inset.
  static const EdgeInsets listPadding = EdgeInsets.symmetric(
    vertical: Spacing.d4,
  );

  /// The tallest the list grows before it scrolls.
  static const double listMaxHeight = Spacing.d256;
}
