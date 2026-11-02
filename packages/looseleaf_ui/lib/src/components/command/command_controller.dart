import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command_score.dart';

/// Scores [value] (and its [keywords]) against [search]; above zero shows
/// the row. Upstream cmdk's `filter` prop.
typedef CommandFilter = double Function(
  String value,
  String search,
  List<String> keywords,
);

/// One registered [CommandItem].
class CommandEntry {
  CommandEntry({
    required this.value,
    required this.keywords,
    required this.disabled,
    required this.group,
    required this.onSelect,
  });

  /// The value it is searched and chosen by.
  String value;

  /// More words the search matches.
  List<String> keywords;

  /// Skipped by the keys, not choosable.
  bool disabled;

  /// The [CommandGroup] it sits in, if any.
  Object? group;

  /// Called when it is chosen.
  ValueChanged<String>? onSelect;

  /// The row's context, for its place on screen and scrolling to it.
  BuildContext? context;
}

/// The state of a [Command]: the search text, the registered items, which
/// match, and the highlighted one. Items and groups listen to it.
///
/// Mirrors cmdk's store (`Command` in upstream `src/components/ui/command.tsx`).
class CommandController extends ChangeNotifier {
  CommandController({
    this.shouldFilter = true,
    this.filter,
    this.loop = false,
    this.vimBindings = true,
    this.onValueChange,
  }) {
    text.addListener(_onText);
  }

  /// The search box's text.
  final TextEditingController text = TextEditingController();

  /// The search box's focus.
  final FocusNode inputFocus = FocusNode(debugLabel: 'CommandInput');

  /// False keeps every row; the app filters (cmdk `shouldFilter`).
  bool shouldFilter;

  /// Scores rows against the search; cmdk's [commandScore] when null.
  CommandFilter? filter;

  /// The arrows wrap at the ends.
  bool loop;

  /// Ctrl + N / P / J / K move too.
  bool vimBindings;

  /// Hears the highlighted value change.
  ValueChanged<String?>? onValueChange;

  final List<CommandEntry> _entries = [];
  final Map<String, double> _scores = {};
  CommandFilter? _scoredWith;
  String? _highlighted;
  String _search = '';
  bool _notifyScheduled = false;

  /// The search, as typed.
  String get search => _search;

  /// The highlighted value.
  String? get highlighted => _highlighted;

  /// Whether rows are filtered and ranked: a search is typed and
  /// [shouldFilter] is on.
  bool get ranking => shouldFilter && _search.trim().isNotEmpty;

  /// How well a row of [value] and [keywords] matches the search: 1 when
  /// not [ranking], else the [filter]'s score; above zero shows it.
  double scoreOf(String value, List<String> keywords) {
    if (!ranking) return 1;
    final scorer = filter ?? commandScore;
    if (!identical(scorer, _scoredWith)) {
      _scores.clear();
      _scoredWith = scorer;
    }
    return _scores.putIfAbsent(
      '$value\u0000${keywords.join('\u0001')}',
      () => scorer(value, _search, keywords),
    );
  }

  /// Whether [entry] matches the search.
  bool matches(CommandEntry entry) => scoreOf(entry.value, entry.keywords) > 0;

  /// Whether the row of [value] is shown.
  bool visible(String value) =>
      _entries.where((entry) => entry.value == value).any(matches);

  /// Whether any row of [group] is shown.
  bool groupVisible(Object group) =>
      _entries.where((entry) => entry.group == group).any(matches);

  /// How many rows are shown.
  int get count => _entries.where(matches).length;

  /// Adds an item; the first one is highlighted.
  CommandEntry register(CommandEntry entry) {
    _entries.add(entry);
    _later();
    return entry;
  }

  /// Removes an item.
  void unregister(CommandEntry entry) {
    _entries.remove(entry);
    _later();
  }

  void _later() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      if (!hasListeners) return;
      _ensureHighlight();
      notifyListeners();
    });
  }

  void _onText() {
    if (text.text == _search) return;
    _search = text.text;
    _scores.clear();
    _setHighlight(_ordered.firstOrNull?.value);
    notifyListeners();
    _later();
  }

  void _ensureHighlight() {
    final current = _highlighted;
    final ordered = _ordered;
    if (current != null && ordered.any((entry) => entry.value == current)) {
      return;
    }
    _setHighlight(ordered.firstOrNull?.value);
  }

  void _setHighlight(String? value) {
    if (value == _highlighted) return;
    _highlighted = value;
    onValueChange?.call(value);
  }

  /// Highlights [value] (the pointer moving onto a row).
  void highlight(String? value) {
    if (value == _highlighted) return;
    _setHighlight(value);
    notifyListeners();
  }

  /// Chooses [value]: calls its row's `onSelect`.
  void select(String value) {
    final entry = _entries
        .where((entry) => entry.value == value && !entry.disabled)
        .firstOrNull;
    entry?.onSelect?.call(value);
  }

  /// The best score among the rows of [group] (cmdk ranks groups by it).
  double groupScore(Object group) => _entries
      .where((entry) => entry.group == group)
      .fold(
        0,
        (best, entry) => math.max(best, scoreOf(entry.value, entry.keywords)),
      );

  /// The shown, enabled rows in screen order: by position, or while
  /// [ranking] the order the list is about to show (loose rows by score,
  /// then the groups by their best score, each group's rows by score), so
  /// a new search highlights its best match at once.
  List<CommandEntry> get _ordered {
    final placed = <(CommandEntry, double)>[];
    for (final (index, entry) in _entries.indexed) {
      if (entry.disabled || !matches(entry)) continue;
      final box = entry.context?.findRenderObject();
      final top = switch (box) {
        final RenderBox placedBox
            when placedBox.attached && placedBox.hasSize =>
          placedBox.localToGlobal(Offset.zero).dy,
        _ => index.toDouble(),
      };
      placed.add((entry, top));
    }
    if (!ranking) {
      placed.sort((a, b) => a.$2.compareTo(b.$2));
      return [for (final (entry, _) in placed) entry];
    }
    final groupTops = <Object, double>{};
    for (final (entry, top) in placed) {
      if (entry.group case final group?) {
        groupTops[group] = math.min(groupTops[group] ?? top, top);
      }
    }
    (double, double) groupKey(CommandEntry entry) => switch (entry.group) {
      null => (double.infinity, double.negativeInfinity),
      final group => (groupScore(group), groupTops[group] ?? 0),
    };
    int compare((CommandEntry, double) a, (CommandEntry, double) b) {
      final (groupA, topA) = groupKey(a.$1);
      final (groupB, topB) = groupKey(b.$1);
      if (groupA != groupB) return groupB.compareTo(groupA);
      if (topA != topB) return topA.compareTo(topB);
      final scoreA = scoreOf(a.$1.value, a.$1.keywords);
      final scoreB = scoreOf(b.$1.value, b.$1.keywords);
      if (scoreA != scoreB) return scoreB.compareTo(scoreA);
      return a.$2.compareTo(b.$2);
    }

    placed.sort(compare);
    return [for (final (entry, _) in placed) entry];
  }

  void _move(int step) {
    final ordered = _ordered;
    if (ordered.isEmpty) return;
    final current = ordered.indexWhere((entry) => entry.value == _highlighted);
    var next = current + step;
    if (current < 0) next = 0;
    if (next < 0 || next >= ordered.length) {
      if (!loop) return;
      next = next % ordered.length;
    }
    _go(ordered[next]);
  }

  void _edge(bool last) {
    final ordered = _ordered;
    if (ordered.isEmpty) return;
    _go(switch (last) {
      true => ordered.last,
      false => ordered.first,
    });
  }

  void _go(CommandEntry entry) {
    highlight(entry.value);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final row = entry.context;
      if (row == null || !row.mounted) return;
      Scrollable.ensureVisible(
        row,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      );
      Scrollable.ensureVisible(
        row,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    });
  }

  /// The search box's keys: the arrows (and Ctrl + N / P / J / K), Home,
  /// End and Enter.
  KeyEventResult handleKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final vim = vimBindings && ctrl;
    if (key == LogicalKeyboardKey.arrowDown ||
        (vim &&
            (key == LogicalKeyboardKey.keyN ||
                key == LogicalKeyboardKey.keyJ))) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        (vim &&
            (key == LogicalKeyboardKey.keyP ||
                key == LogicalKeyboardKey.keyK))) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      _edge(false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      _edge(true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_highlighted case final value?) select(value);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    text
      ..removeListener(_onText)
      ..dispose();
    inputFocus.dispose();
    super.dispose();
  }
}

/// Hands a [CommandController] down to the parts of a [Command].
class CommandScope extends InheritedNotifier<CommandController> {
  const CommandScope({
    super.key,
    required CommandController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest command's controller.
  static CommandController of(BuildContext context) {
    final controller = context
        .dependOnInheritedWidgetOfExactType<CommandScope>()
        ?.notifier;
    if (controller == null) throw FlutterError('No Command above this widget.');
    return controller;
  }

  /// The nearest command's controller, or null.
  static CommandController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommandScope>()?.notifier;
}

/// The [CommandGroup] around a row.
class CommandGroupScope extends InheritedWidget {
  const CommandGroupScope({
    super.key,
    required this.group,
    required super.child,
  });

  /// The group's identity.
  final Object group;

  @override
  bool updateShouldNotify(CommandGroupScope oldWidget) =>
      oldWidget.group != group;
}
