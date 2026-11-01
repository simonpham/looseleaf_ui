import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A value that changes with [LooseleafDensity], like upstream's
/// `compact:` / `calm:` class variants (`h-9 compact:h-8 calm:h-7`).
class ByDensity<T> {
  const ByDensity({
    required this.comfortable,
    required this.compact,
    required this.calm,
  });

  /// The same value at every density.
  const ByDensity.all(T value)
    : comfortable = value,
      compact = value,
      calm = value;

  final T comfortable;
  final T compact;
  final T calm;

  /// The value at [density].
  T resolve(LooseleafDensity density) => switch (density) {
    LooseleafDensity.comfortable => comfortable,
    LooseleafDensity.compact => compact,
    LooseleafDensity.calm => calm,
  };

  /// The value at the ambient [LooseleafTheme]'s density.
  T of(BuildContext context) => resolve(LooseleafTheme.of(context).density);
}
