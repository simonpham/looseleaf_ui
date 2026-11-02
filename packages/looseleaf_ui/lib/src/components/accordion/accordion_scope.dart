import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// What an [Accordion] hands its items.
class AccordionScope extends InheritedWidget {
  const AccordionScope({
    super.key,
    required this.open,
    required this.disabled,
    required this.touched,
    required this.bracket,
    required this.toggle,
    required this.triggers,
    required super.child,
  });

  /// The values of the open items.
  final Set<String> open;
  final bool disabled;

  /// Whether the user has toggled an item: the brace and the soak only play
  /// then (upstream `data-touched`).
  final bool touched;

  /// The margin bracket of every content; null draws none.
  final BracketKind? bracket;

  /// Opens or shuts the item with this value.
  final ValueChanged<String> toggle;

  /// The triggers' focus nodes in item order, for the arrow keys.
  final AccordionTriggers triggers;

  static AccordionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccordionScope>();

  @override
  bool updateShouldNotify(AccordionScope oldWidget) =>
      !setEquals(oldWidget.open, open) ||
      oldWidget.disabled != disabled ||
      oldWidget.touched != touched ||
      oldWidget.bracket != bracket ||
      oldWidget.toggle != toggle;

  static bool setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// The focus nodes of an accordion's triggers by item index: ArrowDown,
/// ArrowUp, Home and End move between them, looping, skipping disabled
/// ones.
class AccordionTriggers {
  final Map<int, FocusNode> _nodes = {};

  void register(int index, FocusNode node) => _nodes[index] = node;

  void unregister(int index, FocusNode node) {
    if (_nodes[index] == node) _nodes.remove(index);
  }

  List<FocusNode> get _ordered {
    final indices = _nodes.keys.toList()..sort();
    return indices
        .map((index) => _nodes[index])
        .nonNulls
        .where((node) => node.canRequestFocus)
        .toList();
  }

  /// Moves focus [by] triggers from [from]; loops at the ends.
  void move(FocusNode from, int by) {
    final nodes = _ordered;
    final at = nodes.indexOf(from);
    if (nodes.isEmpty || at < 0) return;
    nodes[(at + by) % nodes.length].requestFocus();
  }

  /// Focuses the first ([last] false) or last trigger.
  void edge({required bool last}) {
    final nodes = _ordered;
    if (nodes.isEmpty) return;
    switch (last) {
      case true:
        nodes.last.requestFocus();
      case false:
        nodes.first.requestFocus();
    }
  }
}

/// Where an item sits in its [Accordion]: its index, and whether it is the
/// last (which has no rule under it).
class AccordionSlot extends InheritedWidget {
  const AccordionSlot({
    super.key,
    required this.index,
    required this.last,
    required super.child,
  });

  final int index;
  final bool last;

  static AccordionSlot? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccordionSlot>();

  @override
  bool updateShouldNotify(AccordionSlot oldWidget) =>
      oldWidget.index != index || oldWidget.last != last;
}

/// What an [AccordionItem] hands its trigger and content.
class AccordionItemScope extends InheritedWidget {
  const AccordionItemScope({
    super.key,
    required this.value,
    required this.open,
    required this.disabled,
    required super.child,
  });

  final String value;
  final bool open;
  final bool disabled;

  static AccordionItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccordionItemScope>();

  @override
  bool updateShouldNotify(AccordionItemScope oldWidget) =>
      oldWidget.value != value ||
      oldWidget.open != open ||
      oldWidget.disabled != disabled;
}
