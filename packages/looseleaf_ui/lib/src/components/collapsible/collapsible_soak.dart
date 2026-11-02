import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Lets [child] soak into the paper when it mounts with [play]: it comes in
/// faint and settles to full strength over `--ll-dur-soak`, upstream's
/// `animate-soak` (`ll-soak`: 0.15, 0.9 at 55%, 1).
class CollapsibleSoak extends StatefulWidget {
  const CollapsibleSoak({super.key, required this.play, required this.child});

  final bool play;
  final Widget child;

  /// `--ll-dur-soak`.
  static const Duration duration = Duration(milliseconds: 520);

  @override
  State<CollapsibleSoak> createState() => _CollapsibleSoakState();
}

class _CollapsibleSoakState extends State<CollapsibleSoak>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _soak = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.15, end: 0.9), weight: 55),
    TweenSequenceItem(tween: Tween(begin: 0.9, end: 1), weight: 45),
  ]).chain(CurveTween(curve: InkMotion.easeOut));

  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: CollapsibleSoak.duration,
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.play || InkMotion.reducedIn(context)) return;
    if (_clock.isAnimating || _clock.value < 1) return;
    _clock.forward(from: 0);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _clock.drive(_soak), child: widget.child);
}
