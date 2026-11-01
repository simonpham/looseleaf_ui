import 'package:flutter/widgets.dart';

/// Sets how long tooltips below wait before opening ([delay], none by
/// default, like upstream), and lets the next tooltip open at once when one
/// closed less than [skipDelay] ago, so a sweep along a toolbar reads
/// without waiting.
///
/// Mirrors `TooltipProvider` in upstream `src/components/ui/tooltip.tsx`
/// (Radix `delayDuration`, `skipDelayDuration`).
class TooltipProvider extends StatefulWidget {
  const TooltipProvider({
    super.key,
    this.delay = Duration.zero,
    this.skipDelay = const Duration(milliseconds: 300),
    required this.child,
  });

  /// The wait before a tooltip opens on hover.
  final Duration delay;

  /// How soon after one tooltip closes the next opens without waiting.
  final Duration skipDelay;

  /// The tooltips' subtree.
  final Widget child;

  /// The nearest provider, or null.
  static TooltipProviderState? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_TooltipProviderScope>()
      ?.state;

  @override
  State<TooltipProvider> createState() => TooltipProviderState();
}

/// The live state of a [TooltipProvider]: its delays and when a tooltip last
/// closed.
class TooltipProviderState extends State<TooltipProvider> {
  DateTime? _closedAt;
  int _open = 0;

  /// How long a tooltip opening now should wait: nothing while another is
  /// open or just closed.
  Duration get openDelay {
    if (_open > 0) return Duration.zero;
    final closed = _closedAt;
    if (closed == null) return widget.delay;
    if (DateTime.now().difference(closed) < widget.skipDelay) {
      return Duration.zero;
    }
    return widget.delay;
  }

  /// Notes that a tooltip opened.
  void opened() => _open++;

  /// Notes that a tooltip just closed.
  void closed() {
    if (_open > 0) _open--;
    _closedAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) =>
      _TooltipProviderScope(state: this, child: widget.child);
}

class _TooltipProviderScope extends InheritedWidget {
  const _TooltipProviderScope({required this.state, required super.child});

  final TooltipProviderState state;

  @override
  bool updateShouldNotify(_TooltipProviderScope oldWidget) =>
      oldWidget.state != state;
}
