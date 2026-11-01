import 'package:flutter/widgets.dart';

/// Holds [InkMenuRadioItem]s: the one whose value is [value] wears the dot,
/// and choosing another calls [onChanged] with its value.
///
/// Mirrors the `*MenuRadioGroup` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuRadioGroup extends StatelessWidget {
  const InkMenuRadioGroup({
    super.key,
    required this.children,
    this.value,
    this.onChanged,
  });

  /// The radio rows.
  final List<Widget> children;

  /// The chosen value.
  final String? value;

  /// Called with the value of the row chosen.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => InkMenuRadioScope(
    value: value,
    onChanged: onChanged,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

/// Hands an [InkMenuRadioGroup]'s value to its rows.
class InkMenuRadioScope extends InheritedWidget {
  const InkMenuRadioScope({
    super.key,
    required this.value,
    required this.onChanged,
    required super.child,
  });

  /// The chosen value.
  final String? value;

  /// Called with the value of the row chosen.
  final ValueChanged<String>? onChanged;

  /// The nearest group, or null.
  static InkMenuRadioScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InkMenuRadioScope>();

  @override
  bool updateShouldNotify(InkMenuRadioScope oldWidget) =>
      oldWidget.value != value || oldWidget.onChanged != onChanged;
}
