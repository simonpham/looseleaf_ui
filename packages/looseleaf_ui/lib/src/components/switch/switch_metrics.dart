import 'package:looseleaf_ui/src/theme/theme.dart';

/// [Switch] sizes, upstream's `size` prop.
enum SwitchSize {
  /// `h-6 w-11`, a 16 px thumb.
  regular,

  /// `h-5 w-9`, a 12 px thumb; calm density always uses it.
  sm;

  /// The size drawn at [density]: calm switches are always small.
  SwitchSize at(LooseleafDensity density) => switch (density) {
    LooseleafDensity.calm => SwitchSize.sm,
    _ => this,
  };

  /// The track's width.
  double get width => switch (this) {
    SwitchSize.regular => Spacing.d44,
    SwitchSize.sm => Spacing.d36,
  };

  /// The track's height.
  double get height => switch (this) {
    SwitchSize.regular => Spacing.d24,
    SwitchSize.sm => Spacing.d20,
  };

  /// `--sw-t`: the thumb's side.
  double get thumb => switch (this) {
    SwitchSize.regular => Spacing.d16,
    SwitchSize.sm => Spacing.d12,
  };

  /// `translate-x-1`: the thumb's inset when off.
  double get offInset => Spacing.d4;

  /// `--sw-on`: the thumb's offset when on.
  double get onInset => switch (this) {
    SwitchSize.regular => Spacing.d24,
    SwitchSize.sm => Spacing.d20,
  };
}
