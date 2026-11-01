import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show PaintKey, RevealNibParams, revealNibRecipe;
import 'package:looseleaf_ui/src/components/reveal/reveal.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The fountain-pen nib that rides along the bottom of a wiping [Reveal],
/// from the reading start (or end, [fromEnd]) to past the other edge,
/// fading out at the end (upstream `ll-reveal-nib`).
class RevealNib extends StatefulWidget {
  const RevealNib({
    super.key,
    this.color = PaintKey.tomato,
    this.delay = Duration.zero,
    this.fromEnd = false,
  });

  final PaintKey color;
  final Duration delay;
  final bool fromEnd;

  /// The nib's side (`size-6`).
  static const double size = Spacing.d24;

  @override
  State<RevealNib> createState() => _RevealNibState();
}

class _RevealNibState extends State<RevealNib>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: RevealEffect.wipe.duration,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timer != null || _started) return;
    if (InkMotion.reducedIn(context)) {
      _progress.value = 1;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      setState(() => _started = true);
      unawaited(_progress.forward());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = RevealNibParams(color: widget.color);
    final source = RecipeInkSource(
      revealNibRecipe,
      params,
      json: params.toJson(),
    );
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final reversed = rtl != widget.fromEnd;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomSingleChildLayout(
          delegate: _NibLayout(_progress, reversed: reversed),
          child: AnimatedBuilder(
            animation: _progress,
            builder: (context, child) => Opacity(
              opacity: _opacity(_progress.value),
              child: child,
            ),
            child: SizedBox.square(
              dimension: RevealNib.size,
              child: InkSurface(
                source: source,
                seed: 'reveal-nib',
                still: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _opacity(double t) {
    if (!_started || t >= 1) return 0;
    if (t <= 0.9) return 1;
    return (1 - t) / 0.1;
  }
}

class _NibLayout extends SingleChildLayoutDelegate {
  _NibLayout(this.progress, {required this.reversed})
    : super(relayout: progress);

  final Animation<double> progress;
  final bool reversed;

  static const double _start = -0.02;
  static const double _end = 1.02;

  /// `-translate-x-[12%] translate-y-[12%]`.
  static const double _nudge = 0.12;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final eased = InkMotion.easeOut.transform(progress.value);
    final along = switch (reversed) {
      true => _end + (_start - _end) * eased,
      false => _start + (_end - _start) * eased,
    };
    return Offset(
      size.width * along - childSize.width * _nudge,
      size.height - childSize.height + childSize.height * _nudge,
    );
  }

  @override
  bool shouldRelayout(_NibLayout oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.reversed != reversed;
}
