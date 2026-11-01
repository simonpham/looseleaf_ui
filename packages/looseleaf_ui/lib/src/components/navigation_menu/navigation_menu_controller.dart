import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';

/// What a [NavigationMenu] shares with its parts: which item is open, the
/// hover intent that opens and closes them, the panels each item hands in
/// and where each trigger sits.
///
/// The menu owns it; parts reach it with [NavigationMenu.of].
class NavigationMenuController extends ChangeNotifier {
  NavigationMenuController({
    String? value,
    this.delay = NavigationMenu.defaultDelay,
    this.skipDelay = NavigationMenu.defaultSkipDelay,
  }) : _value = value;

  /// Radix's close grace after the pointer leaves the strip and the panel.
  static const Duration closeDelay = Duration(milliseconds: 150);

  String? _value;
  String? _previous;
  Timer? _openTimer;
  Timer? _closeTimer;
  Timer? _skipTimer;
  bool _skipping = false;
  final Map<String, NavigationMenuContent> _contents = {};
  final Map<String, GlobalKey> _triggers = {};
  final List<String> _order = [];

  /// How long the pointer rests on a trigger before its panel opens.
  Duration delay;

  /// How soon after a close another trigger opens without [delay].
  Duration skipDelay;

  /// Whether the panels share one slip under the strip.
  bool viewport = true;

  /// Hears every change asked for; when [controlled], the only effect.
  ValueChanged<String?>? onValueChange;

  /// Whether the menu's owner holds the open value.
  bool controlled = false;

  /// The tap region group of the strip and the panels.
  final Object groupId = Object();

  /// Wraps the open panel, so the keys can step into it.
  final FocusNode panelFocus = FocusNode(
    debugLabel: 'NavigationMenu panel',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The open item, or null.
  String? get value => _value;

  /// The item open before the current one, for the slide between panels.
  String? get previous => _previous;

  /// Whether a panel is open.
  bool get isOpen => _value != null;

  /// Opens [next] (null closes).
  void select(String? next) {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    if (next == _value) return;
    onValueChange?.call(next);
    if (controlled) return;
    _apply(next);
  }

  /// Takes the owner's [next] value.
  void sync(String? next) {
    if (next == _value) return;
    _apply(next);
  }

  void _apply(String? next) {
    if (next == null && _value != null) _startSkip();
    _previous = _value;
    _value = next;
    notifyListeners();
  }

  void _startSkip() {
    _skipping = true;
    _skipTimer?.cancel();
    _skipTimer = Timer(skipDelay, () => _skipping = false);
  }

  /// Opens [item] when open and closes it otherwise.
  void toggle(String item) => select(switch (_value == item) {
    true => null,
    false => item,
  });

  /// Closes the open panel.
  void close() => select(null);

  /// The pointer came onto [item]'s trigger: opens it after [delay], or
  /// at once while another panel is open or one just closed.
  void hoverTrigger(String item) {
    _closeTimer?.cancel();
    if (_value == item) return;
    _openTimer?.cancel();
    if (_value != null || _skipping || delay == Duration.zero) {
      select(item);
      return;
    }
    _openTimer = Timer(delay, () => select(item));
  }

  /// The pointer left the strip or the panel: closes after [closeDelay].
  void leave() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    if (_value == null) return;
    _closeTimer = Timer(closeDelay, close);
  }

  /// The pointer is back on the strip or the panel: keeps it open.
  void stay() => _closeTimer?.cancel();

  /// Hands in [item]'s panel (null takes it back).
  void setContent(String item, NavigationMenuContent? content) {
    switch (content) {
      case final panel?:
        _contents[item] = panel;
        if (!_order.contains(item)) _order.add(item);
      case null:
        _contents.remove(item);
        _order.remove(item);
    }
  }

  /// [item]'s panel, if it has one.
  NavigationMenuContent? contentOf(String? item) => _contents[item];

  /// Where [item] sits among the items with a panel, or -1.
  int indexOf(String? item) => _order.indexOf(item ?? '');

  /// The key on [item]'s tab, for the indicator.
  GlobalKey triggerKey(String item) =>
      _triggers.putIfAbsent(item, () => GlobalKey(debugLabel: item));

  /// Moves focus to the first focusable widget in the open panel.
  bool focusPanel() {
    final first = panelFocus.traversalDescendants
        .where((node) => node.canRequestFocus && !node.skipTraversal)
        .firstOrNull;
    if (first == null) return false;
    first.requestFocus();
    return true;
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _skipTimer?.cancel();
    panelFocus.dispose();
    super.dispose();
  }
}
