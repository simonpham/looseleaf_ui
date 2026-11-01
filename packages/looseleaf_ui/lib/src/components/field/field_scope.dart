import 'package:flutter/widgets.dart';

/// Hands a [Field]'s state to its parts: `data-invalid` turns the label
/// red, `data-disabled` turns it graphite.
class FieldScope extends InheritedWidget {
  const FieldScope({
    super.key,
    required this.invalid,
    required this.disabled,
    required super.child,
  });

  final bool invalid;
  final bool disabled;

  /// The nearest field's scope; null outside a field.
  static FieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FieldScope>();

  @override
  bool updateShouldNotify(FieldScope oldWidget) =>
      oldWidget.invalid != invalid || oldWidget.disabled != disabled;
}

/// Hands a [FieldGroup]'s width to responsive fields (upstream's
/// `@container/field-group` query) and tells nested groups they are nested.
class FieldGroupScope extends InheritedWidget {
  const FieldGroupScope({
    super.key,
    required this.wide,
    required super.child,
  });

  /// Whether the group is at least 448 px wide (`@md`).
  final bool wide;

  /// The nearest group's scope; null outside a group.
  static FieldGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FieldGroupScope>();

  @override
  bool updateShouldNotify(FieldGroupScope oldWidget) => oldWidget.wide != wide;
}
