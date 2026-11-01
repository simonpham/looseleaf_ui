import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The focus scope of a popup, like Radix's `FocusScope`: on open it moves
/// focus to the first focusable widget inside (or the popup itself) when
/// [autofocus]; [trapped] keeps Tab cycling inside (modal popups), otherwise
/// Tab walks out and [onFocusOutside] fires. On close it hands focus back to
/// whatever had it before, when [restoreFocus] and focus has not moved on to
/// something else meanwhile.
class OverlayFocus extends StatefulWidget {
  const OverlayFocus({
    super.key,
    required this.child,
    this.autofocus = true,
    this.trapped = false,
    this.restoreFocus = true,
    this.onFocusOutside,
    this.debugLabel,
  });

  /// The popup.
  final Widget child;

  /// Moves focus inside on open.
  final bool autofocus;

  /// Keeps Tab inside.
  final bool trapped;

  /// Gives focus back on close; read when the popup closes.
  final bool restoreFocus;

  /// Called when focus leaves the popup for elsewhere.
  final VoidCallback? onFocusOutside;

  /// A label for the focus scope.
  final String? debugLabel;

  @override
  State<OverlayFocus> createState() => _OverlayFocusState();
}

class _OverlayFocusState extends State<OverlayFocus> {
  late final FocusScopeNode _scope = FocusScopeNode(
    debugLabel: widget.debugLabel ?? 'OverlayFocus',
    traversalEdgeBehavior: _edge,
  );
  FocusNode? _previous;
  bool _hadFocus = false;

  TraversalEdgeBehavior get _edge => switch (widget.trapped) {
    true => TraversalEdgeBehavior.closedLoop,
    false => TraversalEdgeBehavior.parentScope,
  };

  @override
  void initState() {
    super.initState();
    _previous = FocusManager.instance.primaryFocus;
    _scope.addListener(_onFocus);
    if (!widget.autofocus) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final first = _scope.traversalDescendants
          .where((node) => node.canRequestFocus && !node.skipTraversal)
          .firstOrNull;
      switch (first) {
        case final node?:
          node.requestFocus();
        case null:
          _scope.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(OverlayFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scope.traversalEdgeBehavior = _edge;
  }

  void _onFocus() {
    if (_scope.hasFocus) {
      _hadFocus = true;
      return;
    }
    if (!_hadFocus) return;
    _hadFocus = false;
    widget.onFocusOutside?.call();
  }

  @override
  void dispose() {
    final focusInside = _scope.hasFocus;
    final current = FocusManager.instance.primaryFocus;
    final unclaimed = focusInside || current == null || current == _previous;
    final previous = _previous;
    _scope
      ..removeListener(_onFocus)
      ..dispose();
    if (widget.restoreFocus && unclaimed && previous != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (previous.context == null) return;
        previous.requestFocus();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FocusScope(
    node: _scope,
    child: FocusTraversalGroup(child: widget.child),
  );
}
