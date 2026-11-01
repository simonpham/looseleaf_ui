import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/reveal/reveal.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Plays one [RevealEffect] on [child] after [delay], once mounted: the
/// building block of [Reveal]. [fromEnd] wipes in from the reading end.
/// Where motion is reduced the child simply shows.
class RevealMotion extends StatefulWidget {
  const RevealMotion({
    super.key,
    required this.child,
    this.effect = RevealEffect.wipe,
    this.delay = Duration.zero,
    this.fromEnd = false,
  });

  final Widget child;
  final RevealEffect effect;
  final Duration delay;
  final bool fromEnd;

  @override
  State<RevealMotion> createState() => _RevealMotionState();
}

class _RevealMotionState extends State<RevealMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.effect.duration,
  );
  Timer? _timer;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = InkMotion.reducedIn(context);
    if (_timer != null || _progress.value > 0) return;
    if (_reduced || widget.effect == RevealEffect.wipe) {
      _progress.value = 1;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
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
    if (widget.effect == RevealEffect.wipe) return _wipe(context);
    final wetInk = LooseleafTheme.of(context).colors.wetInkFrom;
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final pose = widget.effect.poseAt(_progress.value);
        final posed = Transform.translate(
          offset: pose.offset,
          child: Transform.rotate(
            angle: pose.rotation,
            child: Transform.scale(scale: pose.scale, child: child),
          ),
        );
        final tinted = switch (pose.wet > 0) {
          true => ColorFiltered(
            colorFilter: ColorFilter.mode(
              wetInk.withValues(alpha: pose.wet),
              BlendMode.srcATop,
            ),
            child: posed,
          ),
          false => posed,
        };
        return Opacity(
          opacity: pose.opacity,
          alwaysIncludeSemantics: true,
          child: tinted,
        );
      },
    );
  }

  Widget _wipe(BuildContext context) {
    final wipe = InkMarkWipe(
      animate: !_reduced,
      delay: widget.delay,
      child: widget.child,
    );
    if (!widget.fromEnd) return wipe;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final flipped = switch (direction) {
      TextDirection.ltr => TextDirection.rtl,
      TextDirection.rtl => TextDirection.ltr,
    };
    return Directionality(
      textDirection: flipped,
      child: InkMarkWipe(
        animate: !_reduced,
        delay: widget.delay,
        child: Directionality(textDirection: direction, child: widget.child),
      ),
    );
  }
}
