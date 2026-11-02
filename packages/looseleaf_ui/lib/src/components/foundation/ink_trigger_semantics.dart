import 'package:flutter/widgets.dart';

/// Hands a trigger's state to the control built inside it, like upstream's
/// `asChild` merging `aria-expanded` onto the child. A [Semantics] around
/// that control would make a node of its own; controls such as `Button`
/// read this instead and report [expanded] on their own node.
class InkTriggerSemantics extends InheritedWidget {
  const InkTriggerSemantics({super.key, this.expanded, required super.child});

  /// Whether what the trigger controls is open; null reports nothing.
  final bool? expanded;

  /// The nearest trigger's state, or null outside one.
  static InkTriggerSemantics? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InkTriggerSemantics>();

  @override
  bool updateShouldNotify(InkTriggerSemantics oldWidget) =>
      expanded != oldWidget.expanded;
}
