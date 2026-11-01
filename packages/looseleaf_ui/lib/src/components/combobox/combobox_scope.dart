import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';

/// Hands a [Combobox]'s [ComboboxController] to its parts, and tells them
/// whether they sit inside the popup.
class ComboboxScope extends InheritedWidget {
  const ComboboxScope({
    super.key,
    required this.controller,
    required this.revision,
    this.inContent = false,
    this.group,
    required super.child,
  });

  final ComboboxController controller;

  /// Bumped on every change, so parts rebuild.
  final int revision;

  /// Whether the parts are inside [ComboboxContent]: a [ComboboxInput]
  /// there is the popup's search box.
  final bool inContent;

  /// The [ComboboxGroup] the parts are in, if any.
  final Object? group;

  /// The nearest scope; parts must sit inside a [Combobox].
  static ComboboxScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ComboboxScope>();
    if (scope == null) {
      throw FlutterError('Combobox parts must be used inside a Combobox.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(ComboboxScope oldWidget) =>
      oldWidget.revision != revision ||
      oldWidget.controller != controller ||
      oldWidget.inContent != inContent ||
      oldWidget.group != group;
}
