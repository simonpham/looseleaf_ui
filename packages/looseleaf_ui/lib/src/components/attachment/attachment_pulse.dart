import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Breathes [child] between full and half opacity while [active], like
/// Tailwind's `animate-pulse`; holds still where motion is reduced.
class AttachmentPulse extends StatefulWidget {
  const AttachmentPulse({super.key, required this.active, required this.child});

  /// Whether it breathes.
  final bool active;

  final Widget child;

  @override
  State<AttachmentPulse> createState() => _AttachmentPulseState();
}

class _AttachmentPulseState extends State<AttachmentPulse>
    with SingleTickerProviderStateMixin {
  static const Curve _curve = Cubic(0.4, 0, 0.6, 1);

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: AttachmentMetrics.pulse,
  );
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: _curve)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: _curve)),
      weight: 1,
    ),
  ]).animate(_clock);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AttachmentPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final breathe = widget.active && !InkMotion.reducedIn(context);
    if (breathe && !_clock.isAnimating) {
      _clock.repeat();
      return;
    }
    if (breathe) return;
    _clock
      ..stop()
      ..value = 0;
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}
