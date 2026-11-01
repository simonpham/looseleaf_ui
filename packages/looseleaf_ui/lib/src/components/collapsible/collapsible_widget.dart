import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible_scope.dart';

/// A panel that opens and shuts: put a [CollapsibleTrigger] and a
/// [CollapsibleContent] anywhere below it.
///
/// Controlled with [open] and [onOpenChange], or left to itself from
/// [defaultOpen].
///
/// ```dart
/// Collapsible(
///   child: Column(children: [
///     CollapsibleTrigger(child: Text('Show more')),
///     CollapsibleContent(child: Text('The rest of the story.')),
///   ]),
/// )
/// ```
///
/// Mirrors `Collapsible` in upstream `src/components/ui/collapsible.tsx`.
class Collapsible extends StatefulWidget {
  const Collapsible({
    super.key,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.disabled = false,
  });

  final Widget child;

  /// Whether the panel is open; null leaves it to the collapsible.
  final bool? open;

  /// Whether an uncontrolled panel starts open.
  final bool defaultOpen;

  /// Called with the next open state when the trigger is used.
  final ValueChanged<bool>? onOpenChange;

  /// Stops the trigger from toggling.
  final bool disabled;

  /// The nearest collapsible's state, or null outside one.
  static CollapsibleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CollapsibleScope>();

  /// The nearest collapsible's state.
  static CollapsibleScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No Collapsible above this context.');
    return scope ??
        CollapsibleScope(
          open: false,
          disabled: true,
          touched: false,
          toggle: () {},
          child: const SizedBox(),
        );
  }

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  late bool _open = widget.defaultOpen;
  bool _touched = false;

  bool get _isOpen => widget.open ?? _open;

  void _toggle() {
    if (widget.disabled) return;
    final next = !_isOpen;
    setState(() {
      _touched = true;
      _open = next;
    });
    widget.onOpenChange?.call(next);
  }

  @override
  Widget build(BuildContext context) => CollapsibleScope(
    open: _isOpen,
    disabled: widget.disabled,
    touched: _touched,
    toggle: _toggle,
    child: widget.child,
  );
}
