import 'package:flutter/widgets.dart';

/// What an [InkRadioGroup] tells its items: the checked value, how to check
/// another, and the group-wide flags.
class RadioGroupScope<T> extends InheritedWidget {
  const RadioGroupScope({
    super.key,
    required this.value,
    required this.onChanged,
    required this.disabled,
    required this.invalid,
    required super.child,
  });

  /// The checked value, or null when none is.
  final T? value;

  /// Checks [value]'s item.
  final ValueChanged<T>? onChanged;

  /// Every item is disabled.
  final bool disabled;

  /// Every item is drawn invalid unless it says otherwise.
  final bool invalid;

  /// The nearest group of [T], or null outside one.
  static RadioGroupScope<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RadioGroupScope<T>>();

  @override
  bool updateShouldNotify(RadioGroupScope<T> oldWidget) =>
      oldWidget.value != value ||
      oldWidget.onChanged != onChanged ||
      oldWidget.disabled != disabled ||
      oldWidget.invalid != invalid;
}
