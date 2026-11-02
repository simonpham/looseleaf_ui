import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Wipes [child] in from the reading start after [delay], once mounted,
/// like upstream's `ll-wipe` keyframes (`clip-path: inset(...)`). The clip
/// overflows the child so ink pads are not cut. Without [animate], or
/// where motion is reduced, the child simply shows.
///
/// Mirrors upstream `MARK_WIPE` (`src/hooks/use-mark-ink.tsx`).
class InkMarkWipe extends StatefulWidget {
  const InkMarkWipe({
    super.key,
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    this.duration = InkMotion.draw,
  });

  final Widget child;
  final bool animate;
  final Duration delay;
  final Duration duration;

  @override
  State<InkMarkWipe> createState() => _InkMarkWipeState();
}

class _InkMarkWipeState extends State<InkMarkWipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: switch (widget.animate) {
      true => 0,
      false => 1,
    },
  );
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_progress.value > 0 || _timer != null) return;
    if (InkMotion.reducedIn(context)) {
      _progress.value = 1;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      unawaited(_progress.animateTo(1, curve: InkMotion.easeOut));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRect(
    clipper: _WipeClipper(
      _progress,
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    ),
    child: widget.child,
  );
}

class _WipeClipper extends CustomClipper<Rect> {
  _WipeClipper(this.progress, this.direction) : super(reclip: progress);

  final Animation<double> progress;
  final TextDirection direction;

  static const double _overflow = 32;

  @override
  Rect getClip(Size size) {
    final full = Rect.fromLTRB(
      -_overflow,
      -_overflow,
      size.width + _overflow,
      size.height + _overflow,
    );
    final shown = full.width * progress.value;
    return switch (direction) {
      TextDirection.ltr => Rect.fromLTWH(
        full.left,
        full.top,
        shown,
        full.height,
      ),
      TextDirection.rtl => Rect.fromLTRB(
        full.right - shown,
        full.top,
        full.right,
        full.bottom,
      ),
    };
  }

  @override
  bool shouldReclip(_WipeClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.direction != direction;
}
