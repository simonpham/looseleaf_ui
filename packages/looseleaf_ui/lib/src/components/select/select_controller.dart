import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';

/// What a [Select] shares with its parts: the chosen and highlighted
/// values, whether it is open, its items, and the ways to change them.
class SelectController {
  const SelectController({
    required this.value,
    required this.open,
    required this.highlighted,
    required this.disabled,
    required this.items,
    required this.groupId,
    required this.triggerFocus,
    required this.listKey,
    required this.scroll,
    required this.triggerWidth,
    required this.placement,
    required this.measuring,
    required this.seed,
    required this.setOpen,
    required this.select,
    required this.highlight,
    required this.rowKey,
    required this.onTriggerKey,
    required this.onListKey,
    required this.measure,
  });

  /// The chosen value, or null.
  final String? value;

  /// Whether the list is open.
  final bool open;

  /// The value of the row under the highlighter, or null.
  final String? highlighted;

  /// The whole select is disabled.
  final bool disabled;

  /// Every [SelectItem] of the content, in order.
  final List<SelectItem> items;

  /// The tap region group of the trigger and the list.
  final Object groupId;

  /// The trigger's focus node.
  final FocusNode triggerFocus;

  /// The key of the list's content, for measuring.
  final GlobalKey listKey;

  /// The list's scroll position.
  final ScrollController scroll;

  /// Reads the trigger's width, for the list's least width.
  final double Function() triggerWidth;

  /// Where an item-aligned list goes; null until measured.
  final SelectPlacement? placement;

  /// Whether an item-aligned list is laid out unseen to be measured.
  final bool measuring;

  /// Pins the list's paper: the content's `seed`, else the select's own.
  final String seed;

  /// Opens or closes the list.
  final ValueChanged<bool> setOpen;

  /// Chooses a value and closes the list.
  final ValueChanged<String> select;

  /// Moves the highlighter to a value, or takes it away with null.
  final ValueChanged<String?> highlight;

  /// The key of a row, for measuring and scrolling it into view.
  final GlobalKey Function(String value) rowKey;

  /// Handles a key on the closed trigger.
  final KeyEventResult Function(KeyEvent event) onTriggerKey;

  /// Handles a key in the open list.
  final KeyEventResult Function(KeyEvent event) onListKey;

  /// Measures the laid-out list to place it over the trigger.
  final VoidCallback measure;

  /// The chosen item, or null.
  SelectItem? get chosen =>
      items.where((item) => item.value == value).firstOrNull;

  /// Opens a closed list and closes an open one.
  void toggle() => setOpen(!open);
}

/// Hands a [SelectController] down to the parts of a [Select].
class SelectScope extends InheritedWidget {
  const SelectScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The select's controller.
  final SelectController controller;

  @override
  bool updateShouldNotify(SelectScope oldWidget) => true;
}
