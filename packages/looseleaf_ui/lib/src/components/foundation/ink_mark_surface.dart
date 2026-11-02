import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/ink_mark_wipe.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// How a mark draws itself on.
///
/// Mirrors upstream `MARK_WIPE` and `MARK_REVEAL`
/// (`src/hooks/use-mark-ink.tsx`).
enum InkMarkDraw {
  /// The whole drawing is wiped in from the reading start (`ll-wipe`).
  wipe,

  /// The drawing's `reveal` parts are drawn on stroke by stroke (`ll-draw`).
  reveal,
}

/// An [InkSurface] for a mark: no interaction, and with [animate] it holds
/// the drawing back and draws it on after [delay], once mounted.
///
/// [InkMarkDraw.reveal] uses the surface's own draw-on of `reveal` parts;
/// [InkMarkDraw.wipe] clips the whole drawing with [InkMarkWipe]. Reduced motion just shows it.
///
/// The phase logic of upstream `useMarkPhase` (`src/hooks/use-mark-ink.tsx`):
/// a mark plays when it first mounts rather than when it scrolls into view,
/// and remounting it (upstream `show` off and on) replays it.
class InkMarkSurface extends StatefulWidget {
  const InkMarkSurface({
    super.key,
    required this.source,
    required this.seed,
    this.draw = InkMarkDraw.reveal,
    this.animate = false,
    this.delay = Duration.zero,
    this.child,
  });

  final InkSource source;
  final String seed;
  final InkMarkDraw draw;

  /// Hold the drawing back and draw it on.
  final bool animate;

  /// The wait before drawing on (`--ll-draw-delay`).
  final Duration delay;

  /// Sizes the surface; null fills the constraints.
  final Widget? child;

  @override
  State<InkMarkSurface> createState() => _InkMarkSurfaceState();
}

class _InkMarkSurfaceState extends State<InkMarkSurface> {
  Timer? _timer;
  late bool _started = !_revealing;

  bool get _revealing => widget.animate && widget.draw == InkMarkDraw.reveal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || _timer != null) return;
    if (InkMotion.reducedIn(context)) {
      setState(() => _started = true);
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _started = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = InkSurface(
      source: widget.source,
      seed: widget.seed,
      still: true,
      states: switch (_revealing && _started) {
        true => const {InkState.checked},
        false => const {},
      },
      drawOn: _revealing,
      drawOnDuration: InkMotion.draw,
      child: widget.child,
    );
    if (widget.draw == InkMarkDraw.wipe) {
      return InkMarkWipe(
        animate: widget.animate,
        delay: widget.delay,
        child: surface,
      );
    }
    return Visibility.maintain(visible: _started, child: surface);
  }
}
