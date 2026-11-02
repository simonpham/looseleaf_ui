import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';

/// Orders the rows of a [CommandList] or [CommandGroup] while the search
/// ranks them, like cmdk's `sort`: other children (and disabled rows) keep
/// their place first, then the matching rows by score, then (in a list)
/// the groups by their best row. Ties keep their order.
abstract final class CommandRank {
  /// [children] in the order to show them, each keyed by its place in
  /// [children] so rows keep their state as they move.
  static List<Widget> order(
    CommandController controller,
    List<Widget> children,
  ) {
    final keyed = [
      for (final (index, child) in children.indexed)
        (KeyedSubtree(key: ValueKey(index), child: child), child),
    ];
    if (!controller.ranking) return [for (final (slot, _) in keyed) slot];
    final fixed = <Widget>[];
    final items = <(Widget, double)>[];
    final groups = <(Widget, double)>[];
    for (final (slot, child) in keyed) {
      switch (child) {
        case CommandItem(disabled: false):
          items.add((slot, _itemScore(controller, child)));
        case CommandGroup(:final children):
          groups.add((slot, _best(controller, children)));
        default:
          fixed.add(slot);
      }
    }
    return [...fixed, ..._byScore(items), ..._byScore(groups)];
  }

  static double _itemScore(CommandController controller, CommandItem item) =>
      switch (item.searchValue) {
        final value? => controller.scoreOf(value, item.keywords),
        null => 0,
      };

  static double _best(CommandController controller, List<Widget> children) {
    var best = 0.0;
    for (final child in children) {
      if (child is! CommandItem) continue;
      final score = _itemScore(controller, child);
      if (score > best) best = score;
    }
    return best;
  }

  static List<Widget> _byScore(List<(Widget, double)> scored) {
    final indexed =
        [
          for (final (index, (widget, score)) in scored.indexed)
            (widget, score, index),
        ]..sort((a, b) {
          if (a.$2 != b.$2) return b.$2.compareTo(a.$2);
          return a.$3.compareTo(b.$3);
        });
    return [for (final (widget, _, _) in indexed) widget];
  }
}
