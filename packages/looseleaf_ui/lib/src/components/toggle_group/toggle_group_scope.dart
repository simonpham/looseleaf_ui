import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle.dart';

/// Whether a [ToggleGroup] keeps one item on or any number.
enum ToggleGroupType {
  /// At most one item on; pressing it again turns it off.
  single,

  /// Any number of items on.
  multiple,
}

/// What a [ToggleGroup] tells each of its items: the pressed values, how to
/// change them, the shared look, and whether the item comes first.
class ToggleGroupScope<T> extends InheritedWidget {
  const ToggleGroupScope({
    super.key,
    required this.value,
    required this.onChanged,
    required this.type,
    required this.variant,
    required this.size,
    required this.spacing,
    required this.tone,
    required this.vertical,
    required this.disabled,
    required this.invalid,
    required this.first,
    required super.child,
  });

  /// The values pressed on.
  final Set<T> value;
  final ValueChanged<Set<T>>? onChanged;
  final ToggleGroupType type;
  final ToggleVariant variant;
  final ToggleSize size;

  /// The gap between items; 0 joins them into one drawn strip.
  final double spacing;

  final ToggleTone? tone;
  final bool vertical;
  final bool disabled;
  final bool invalid;

  /// Whether this item comes first: a joined first item draws no seam.
  final bool first;

  /// Whether items sit in one drawn strip.
  bool get joined => spacing == 0;

  /// The nearest group of [T], or null outside one.
  static ToggleGroupScope<T>? maybeOf<T>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ToggleGroupScope<T>>();

  /// The value set after pressing [item].
  Set<T> pressing(T item) {
    final on = value.contains(item);
    return switch ((type, on)) {
      (_, true) => {...value}..remove(item),
      (ToggleGroupType.single, false) => {item},
      (ToggleGroupType.multiple, false) => {...value, item},
    };
  }

  @override
  bool updateShouldNotify(ToggleGroupScope<T> oldWidget) =>
      !setEquals(oldWidget.value, value) ||
      oldWidget.onChanged != onChanged ||
      oldWidget.type != type ||
      oldWidget.variant != variant ||
      oldWidget.size != size ||
      oldWidget.spacing != spacing ||
      oldWidget.tone != tone ||
      oldWidget.vertical != vertical ||
      oldWidget.disabled != disabled ||
      oldWidget.invalid != invalid ||
      oldWidget.first != first;
}
