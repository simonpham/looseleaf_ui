import 'package:flutter/widgets.dart';

/// Hands a marquee's pause state to its [MarqueeControl].
///
/// Mirrors `MarqueeContext` in upstream `src/components/ui/marquee.tsx`.
class MarqueeScope extends InheritedWidget {
  const MarqueeScope({
    super.key,
    required this.paused,
    required this.onToggle,
    required super.child,
  });

  /// Whether the ticker is paused by its own state (not by hover or focus).
  final bool paused;

  /// Flips [paused].
  final VoidCallback onToggle;

  /// The nearest marquee's scope; throws outside a marquee.
  static MarqueeScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MarqueeScope>();
    if (scope != null) return scope;
    throw FlutterError('MarqueeControl must be used inside a Marquee.');
  }

  @override
  bool updateShouldNotify(MarqueeScope oldWidget) =>
      oldWidget.paused != paused || oldWidget.onToggle != onToggle;
}
