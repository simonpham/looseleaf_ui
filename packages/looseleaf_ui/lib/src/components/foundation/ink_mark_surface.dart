import 'dart:async';

import 'package:flutter/widgets.dart';
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
/// [InkMarkDraw.wipe] clips the whole drawing. Reduced motion just shows it.
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

  /// `--ll-dur-draw`.
  static const Duration drawDuration = Duration(milliseconds: 600);

  @override
  State<InkMarkSurface> createState() => _InkMarkSurfaceState();
}

class _InkMarkSurfaceState extends State<InkMarkSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wipe = AnimationController(
    vsync: this,
    duration: InkMarkSurface.drawDuration,
    value: 1,
  );
  Timer? _timer;
  bool _started = true;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) return;
    _started = false;
    _wipe.value = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || _timer != null) return;
    if (InkMotion.reducedIn(context)) {
      _start(animate: false);
      return;
    }
    _timer = Timer(widget.delay, () => _start(animate: true));
  }

  void _start({required bool animate}) {
    if (!mounted) return;
    setState(() => _started = true);
    if (!animate) {
      _wipe.value = 1;
      return;
    }
    unawaited(
      _wipe.animateTo(1, curve: InkMotion.easeOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = InkSurface(
      source: widget.source,
      seed: widget.seed,
      still: true,
      states: switch (widget.animate &&
          _started &&
          widget.draw == InkMarkDraw.reveal) {
        true => const {InkState.checked},
        false => const {},
      },
      drawOn: widget.animate && widget.draw == InkMarkDraw.reveal,
      child: widget.child,
    );
    final shown = Visibility.maintain(visible: _started, child: surface);
    if (!widget.animate || widget.draw == InkMarkDraw.reveal) return shown;
    return ClipRect(
      clipper: _WipeClipper(
        _wipe,
        Directionality.maybeOf(context) ?? TextDirection.ltr,
      ),
      child: shown,
    );
  }
}

/// `ll-wipe`: `clip-path: inset(-10% 100% -10% -4%)` to
/// `inset(-10% -4% -10% -4%)`, overflowing far enough for the frame's pad.
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
