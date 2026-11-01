import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';

/// Joins a strip tab to the [InkRovingFocus] of its [NavigationMenuList],
/// so the arrows walk the triggers and links. [rovingFocusNode] is the
/// widget's own node unless [externalFocusNode] gives one.
mixin NavigationMenuRoving<T extends StatefulWidget> on State<T> {
  FocusNode? _ownFocusNode;
  InkRovingEntry? _entry;
  InkRovingFocusState? _roving;

  /// The node the widget was given, if any.
  FocusNode? get externalFocusNode;

  /// Whether the tab can take focus.
  bool get rovingEnabled;

  /// The node the tab's focusable widget uses.
  FocusNode get rovingFocusNode =>
      externalFocusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _join(InkRovingFocus.maybeOf(context));
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(_entry?.focusNode, rovingFocusNode)) return;
    _join(_roving, force: true);
  }

  void _join(InkRovingFocusState? roving, {bool force = false}) {
    if (identical(roving, _roving) && !force) return;
    if (_entry case final old?) _roving?.unregister(old);
    _roving = roving;
    final entry = InkRovingEntry(rovingFocusNode);
    _entry = entry;
    roving?.register(entry);
  }

  /// Keeps the entry's enabled flag in step; call from build.
  void syncRoving() {
    final entry = _entry;
    if (entry == null || entry.enabled == rovingEnabled) return;
    entry.enabled = rovingEnabled;
    _roving?.markChanged();
  }

  @override
  void dispose() {
    if (_entry case final entry?) _roving?.unregister(entry);
    _ownFocusNode?.dispose();
    super.dispose();
  }
}
