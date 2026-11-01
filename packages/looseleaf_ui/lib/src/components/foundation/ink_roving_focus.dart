import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One item of an [InkRovingFocus] group.
class InkRovingEntry {
  InkRovingEntry(this.focusNode);

  /// The item's own node; the group sets its `skipTraversal`.
  final FocusNode focusNode;

  /// Whether the item is the group's current one (checked, pressed): Tab
  /// lands on it.
  bool active = false;

  /// Disabled items are skipped by the arrows.
  bool enabled = true;

  /// Called when an arrow key moves focus onto the item.
  VoidCallback? onArrive;
}

/// Arrow-key focus for a group of items, like Radix `RovingFocusGroup`:
/// the group is one Tab stop (the [InkRovingEntry.active] item, else the
/// first enabled one), and the arrow keys move between its items, looping
/// at the ends. Horizontal arrows follow the reading direction.
///
/// Items register an [InkRovingEntry] with [InkRovingFocus.maybeOf] and
/// pass its [InkRovingEntry.focusNode] to their focusable widget.
class InkRovingFocus extends StatefulWidget {
  const InkRovingFocus({
    super.key,
    required this.child,
    this.axis,
    this.loop = true,
  });

  /// The arrows that move: [Axis.horizontal] (left and right),
  /// [Axis.vertical] (up and down) or null for all four.
  final Axis? axis;

  /// Whether the arrows wrap around at the ends.
  final bool loop;

  final Widget child;

  /// The nearest group, or null outside one.
  static InkRovingFocusState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InkRovingScope>()?.state;

  @override
  State<InkRovingFocus> createState() => InkRovingFocusState();
}

/// The state of an [InkRovingFocus]: its registered items.
class InkRovingFocusState extends State<InkRovingFocus> {
  final List<InkRovingEntry> _entries = [];
  bool _syncScheduled = false;

  /// Adds [entry]; the group keeps items in registration (build) order.
  void register(InkRovingEntry entry) {
    _entries.add(entry);
    markChanged();
  }

  void unregister(InkRovingEntry entry) {
    _entries.remove(entry);
    markChanged();
  }

  /// Recomputes the Tab stop after this frame; items call it when they
  /// turn active or enabled.
  void markChanged() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _syncTabStop();
    });
  }

  void _syncTabStop() {
    final enabled = [
      for (final entry in _entries)
        if (entry.enabled) entry,
    ];
    final stop =
        enabled.where((entry) => entry.active).firstOrNull ??
        enabled.firstOrNull;
    for (final entry in _entries) {
      entry.focusNode.skipTraversal = !identical(entry, stop);
    }
  }

  List<InkRovingEntry> get _ordered {
    final placed = <(InkRovingEntry, Offset)>[];
    for (final entry in _entries) {
      if (!entry.enabled) continue;
      if (entry.focusNode.context?.findRenderObject() case final RenderBox box
          when box.attached) {
        placed.add((entry, box.localToGlobal(Offset.zero)));
      }
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    placed.sort((a, b) {
      if ((a.$2.dy - b.$2.dy).abs() > 1) return a.$2.dy.compareTo(b.$2.dy);
      return switch (rtl) {
        true => b.$2.dx.compareTo(a.$2.dx),
        false => a.$2.dx.compareTo(b.$2.dx),
      };
    });
    return [for (final (entry, _) in placed) entry];
  }

  void _move(int step) {
    final ordered = _ordered;
    final current = ordered.indexWhere((entry) => entry.focusNode.hasFocus);
    if (ordered.isEmpty || current < 0) return;
    var next = current + step;
    if (next < 0 || next >= ordered.length) {
      if (!widget.loop) return;
      next = next % ordered.length;
    }
    final target = ordered[next];
    target.focusNode.requestFocus();
    target.onArrive?.call();
  }

  void _moveHorizontal(int step) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    _move(switch (rtl) {
      true => -step,
      false => step,
    });
  }

  void _first(bool last) {
    final ordered = _ordered;
    if (ordered.isEmpty) return;
    final target = switch (last) {
      true => ordered.last,
      false => ordered.first,
    };
    target.focusNode.requestFocus();
    target.onArrive?.call();
  }

  Map<ShortcutActivator, VoidCallback> get _bindings {
    final axis = widget.axis;
    return {
      if (axis != Axis.vertical) ...{
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _moveHorizontal(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _moveHorizontal(1),
      },
      if (axis != Axis.horizontal) ...{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
      },
      const SingleActivator(LogicalKeyboardKey.home): () => _first(false),
      const SingleActivator(LogicalKeyboardKey.end): () => _first(true),
    };
  }

  @override
  Widget build(BuildContext context) => _InkRovingScope(
    state: this,
    child: CallbackShortcuts(bindings: _bindings, child: widget.child),
  );
}

class _InkRovingScope extends InheritedWidget {
  const _InkRovingScope({required this.state, required super.child});

  final InkRovingFocusState state;

  @override
  bool updateShouldNotify(_InkRovingScope oldWidget) =>
      oldWidget.state != state;
}
