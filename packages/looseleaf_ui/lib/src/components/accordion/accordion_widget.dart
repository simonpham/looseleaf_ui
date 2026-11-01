import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/accordion/accordion_scope.dart';

/// Whether an [Accordion] opens one item at a time or several.
enum AccordionType { single, multiple }

/// Ruled rows that open to show more: a stack of [AccordionItem]s, each an
/// [AccordionTrigger] over an [AccordionContent].
///
/// Opening an item turns its chevron over, writes a margin brace beside
/// the text and lets the words soak in. [AccordionType.single] keeps one
/// open ([collapsible] lets it be shut again); [AccordionType.multiple]
/// opens any. Controlled with [value] and [onValueChange], or left to
/// itself from [defaultValue].
///
/// ```dart
/// Accordion(
///   collapsible: true,
///   defaultValue: const {'item-1'},
///   children: [
///     AccordionItem(
///       value: 'item-1',
///       child: Column(children: [
///         AccordionTrigger(child: Text('Is it accessible?')),
///         AccordionContent(child: Text('Yes.')),
///       ]),
///     ),
///   ],
/// )
/// ```
///
/// Mirrors `Accordion` in upstream `src/components/ui/accordion.tsx`.
class Accordion extends StatefulWidget {
  const Accordion({
    super.key,
    required this.children,
    this.type = AccordionType.single,
    this.collapsible = false,
    this.value,
    this.defaultValue = const {},
    this.onValueChange,
    this.disabled = false,
    this.bracket = BracketKind.curly,
  });

  /// The [AccordionItem]s.
  final List<Widget> children;

  final AccordionType type;

  /// With [AccordionType.single], lets the open item be shut again.
  final bool collapsible;

  /// The open items' values; null leaves it to the accordion.
  final Set<String>? value;

  /// The items an uncontrolled accordion starts with open.
  final Set<String> defaultValue;

  /// Called with the next open values when a trigger is used.
  final ValueChanged<Set<String>>? onValueChange;

  /// Disables every item.
  final bool disabled;

  /// The margin bracket beside opened content; null draws none.
  final BracketKind? bracket;

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  late Set<String> _open = widget.defaultValue;
  bool _touched = false;
  final AccordionTriggers _triggers = AccordionTriggers();

  Set<String> get _value => widget.value ?? _open;

  void _toggle(String item) {
    final open = _value;
    final Set<String> next = switch ((widget.type, open.contains(item))) {
      (AccordionType.multiple, true) => {...open}..remove(item),
      (AccordionType.multiple, false) => {...open, item},
      (AccordionType.single, true) when widget.collapsible => {},
      (AccordionType.single, true) => open,
      (AccordionType.single, false) => {item},
    };
    if (AccordionScope.setEquals(next, open)) return;
    setState(() {
      _touched = true;
      _open = next;
    });
    widget.onValueChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    return AccordionScope(
      open: _value,
      disabled: widget.disabled,
      touched: _touched,
      bracket: widget.bracket,
      toggle: _toggle,
      triggers: _triggers,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed)
            AccordionSlot(
              index: index,
              last: index == children.length - 1,
              child: child,
            ),
        ],
      ),
    );
  }
}
