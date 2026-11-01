import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// One row of an [InkMenuLevel] the arrows and typeahead can reach.
class InkMenuEntry {
  InkMenuEntry(this.node);

  /// The row's focus node; the row is highlighted while it has focus.
  final FocusNode node;

  /// The text typeahead matches.
  String? text;

  /// Disabled rows are skipped.
  bool enabled = true;

  /// The sub-menu the row opens, for sub triggers.
  InkMenuSubState? sub;

  /// The text of a row whose content is a [Text], for typeahead.
  static String? textOf(Widget child) => switch (child) {
    Text(:final data) => data,
    _ => null,
  };
}

/// The rows of one slip (the menu or a sub-menu) and the keyboard moves
/// between them, like Radix's `MenuContent` collection: Up and Down, Home
/// and End, and typeahead, in on-screen order, skipping disabled rows.
class InkMenuLevel {
  InkMenuLevel(this.node);

  /// The slip's own focus node: focused when no row is highlighted.
  final FocusNode node;

  final List<InkMenuEntry> _entries = [];

  /// Whether the last move came from the keyboard, which shows the focus
  /// bar on the highlighted row.
  bool viaKeys = false;

  /// The sub-menu open from this slip.
  InkMenuSubState? openSub;

  /// Typeahead.
  String _query = '';
  DateTime _typed = DateTime.fromMillisecondsSinceEpoch(0);

  /// Radix's typeahead timeout.
  static const Duration typeaheadTimeout = Duration(seconds: 1);

  void register(InkMenuEntry entry) => _entries.add(entry);

  void unregister(InkMenuEntry entry) => _entries.remove(entry);

  /// A row took focus: another open sub-menu closes.
  void focused(InkMenuEntry entry) {
    final sub = openSub;
    if (sub == null || identical(sub, entry.sub)) return;
    sub.close();
  }

  /// Takes the highlight off every row.
  void focusSelf() => node.requestFocus();

  /// Whether a row of this slip has focus.
  bool get rowFocused => _entries.any((entry) => entry.node.hasFocus);

  List<InkMenuEntry> get _ordered {
    final placed = <(InkMenuEntry, Offset)>[];
    for (final entry in _entries) {
      if (!entry.enabled) continue;
      if (entry.node.context?.findRenderObject() case final RenderBox box
          when box.attached) {
        placed.add((entry, box.localToGlobal(Offset.zero)));
      }
    }
    placed.sort((a, b) => a.$2.dy.compareTo(b.$2.dy));
    return [for (final (entry, _) in placed) entry];
  }

  void _go(InkMenuEntry entry) {
    viaKeys = true;
    entry.node.requestFocus();
  }

  /// Moves the highlight by [step] rows; from no row, Down goes to the
  /// first and Up to the last. [loop] wraps at the ends.
  void move(int step, {bool loop = false}) {
    final ordered = _ordered;
    if (ordered.isEmpty) return;
    final current = ordered.indexWhere((entry) => entry.node.hasFocus);
    if (current < 0) {
      edge(last: step < 0);
      return;
    }
    var next = current + step;
    if (next < 0 || next >= ordered.length) {
      if (!loop) return;
      next = next % ordered.length;
    }
    _go(ordered[next]);
  }

  /// Highlights the first row, or the last.
  void edge({required bool last}) {
    final ordered = _ordered;
    final target = switch (last) {
      true => ordered.lastOrNull,
      false => ordered.firstOrNull,
    };
    if (target == null) return;
    _go(target);
  }

  /// Highlights the next row whose text starts with what was typed: letters
  /// typed within a second build one search, and one letter typed again
  /// cycles through the rows starting with it.
  void typeahead(String char, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final fresh = at.difference(_typed) > typeaheadTimeout;
    _typed = at;
    final lower = char.toLowerCase();
    _query = switch (fresh) {
      true => lower,
      false => _query + lower,
    };
    final repeated = _query.split('').every((c) => c == lower);
    final query = switch (repeated) {
      true => lower,
      false => _query,
    };
    final ordered = _ordered;
    final current = ordered.indexWhere((entry) => entry.node.hasFocus);
    final start = switch (query.length == 1) {
      true => current + 1,
      false => current.clamp(0, ordered.length),
    };
    for (var step = 0; step < ordered.length; step++) {
      final entry = ordered[(start + step) % ordered.length];
      final text = entry.text?.trim().toLowerCase();
      if (text == null || !text.startsWith(query)) continue;
      _go(entry);
      return;
    }
  }
}

/// Hands the nearest slip's [InkMenuLevel] to its rows.
class InkMenuLevelScope extends InheritedWidget {
  const InkMenuLevelScope({
    super.key,
    required this.level,
    required super.child,
  });

  /// The slip's rows.
  final InkMenuLevel level;

  /// The nearest slip's level, or null outside a menu.
  static InkMenuLevel? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InkMenuLevelScope>()?.level;

  @override
  bool updateShouldNotify(InkMenuLevelScope oldWidget) =>
      !identical(oldWidget.level, level);
}
