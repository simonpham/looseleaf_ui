import 'package:flutter/widgets.dart';

/// Where an [InputGroupAddon] sits: before or after the control on its
/// line, or on a line of its own above or below it.
enum InputGroupAlign {
  /// Before the control (`inline-start`).
  inlineStart,

  /// After the control (`inline-end`).
  inlineEnd,

  /// A full-width line above the control (`block-start`).
  blockStart,

  /// A full-width line below the control (`block-end`).
  blockEnd,
}

/// What an [InputGroup] tells its parts: the control's focus node, the
/// group-wide states, and which addons surround the control.
class InputGroupScope extends InheritedWidget {
  const InputGroupScope({
    super.key,
    required this.focusNode,
    required this.disabled,
    required this.invalid,
    required this.aligns,
    required super.child,
  });

  /// The control's focus node; tapping an addon focuses it.
  final FocusNode focusNode;

  /// The control (and the group's buttons and text) are disabled.
  final bool disabled;

  /// The control holds an invalid value.
  final bool invalid;

  /// The alignments of the group's addons.
  final Set<InputGroupAlign> aligns;

  /// The nearest group, or null outside one.
  static InputGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InputGroupScope>();

  @override
  bool updateShouldNotify(InputGroupScope oldWidget) =>
      oldWidget.focusNode != focusNode ||
      oldWidget.disabled != disabled ||
      oldWidget.invalid != invalid ||
      !_sameAligns(oldWidget.aligns, aligns);

  static bool _sameAligns(Set<InputGroupAlign> a, Set<InputGroupAlign> b) =>
      a.length == b.length && a.containsAll(b);
}
