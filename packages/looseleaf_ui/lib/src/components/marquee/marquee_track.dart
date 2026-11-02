import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/marquee/marquee.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A marquee's moving line: [children] in a row, repeated just enough times
/// to fill the width (at most [maxCopies]), sliding one copy's width per
/// loop at [speed] px a second (never faster than a 4 second loop) while
/// [running]. Only the first copy reaches screen readers, focus and taps.
/// Where motion is reduced there is one still copy, centred when it fits.
///
/// Mirrors the viewport, track and groups of upstream
/// `src/components/ui/marquee.tsx`.
class MarqueeTrack extends StatefulWidget {
  const MarqueeTrack({
    super.key,
    required this.children,
    this.speed = 60,
    this.direction = MarqueeDirection.start,
    this.running = true,
  });

  /// Upstream's `MAX_COPIES`.
  static const int maxCopies = 48;

  /// The shortest loop.
  static const double minSeconds = 4;

  /// The phrases, usually [MarqueeItem]s.
  final List<Widget> children;

  /// Pixels a second.
  final double speed;

  /// Which way the line runs.
  final MarqueeDirection direction;

  /// False holds the line where it is.
  final bool running;

  @override
  State<MarqueeTrack> createState() => _MarqueeTrackState();
}

class _MarqueeTrackState extends State<MarqueeTrack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  final GlobalKey _group = GlobalKey();
  int _copies = 2;
  double _groupWidth = 0;
  double _viewport = 0;
  bool _reduced = false;
  bool _measuring = false;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = InkMotion.reducedIn(context);
    _sync();
  }

  @override
  void didUpdateWidget(MarqueeTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) _retime();
    _sync();
  }

  void _sync() {
    final run = widget.running && !_reduced && _groupWidth > 0;
    if (run && !_loop.isAnimating) unawaited(_loop.repeat());
    if (!run && _loop.isAnimating) _loop.stop();
  }

  void _retime() {
    if (_groupWidth <= 0) return;
    final seconds = math.max(
      MarqueeTrack.minSeconds,
      _groupWidth / math.max(1, widget.speed),
    );
    final duration = Duration(microseconds: (seconds * 1e6).round());
    if (_loop.duration == duration) return;
    _loop.duration = duration;
    if (!_loop.isAnimating) return;
    _loop.stop();
    unawaited(_loop.repeat());
  }

  void _scheduleMeasure() {
    if (_measuring) return;
    _measuring = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _measuring = false;
      if (!mounted) return;
      final box = _group.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) return;
      final width = box.size.width;
      if (width <= 0) return;
      final copies = ((_viewport / width).ceil() + 1).clamp(
        2,
        MarqueeTrack.maxCopies,
      );
      if (width == _groupWidth && copies == _copies) return;
      setState(() {
        _groupWidth = width;
        _copies = copies;
      });
      _retime();
      _sync();
    });
  }

  double _shift(TextDirection textDirection) {
    final phase = switch (widget.direction) {
      MarqueeDirection.start => _loop.value,
      MarqueeDirection.end => 1 - _loop.value,
    };
    final sign = switch (textDirection) {
      TextDirection.ltr => -1,
      TextDirection.rtl => 1,
    };
    if (phase >= 1) return 0;
    return sign * phase * _groupWidth;
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.children,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.maxWidth;
        _scheduleMeasure();
        final first = KeyedSubtree(key: _group, child: group);
        if (_reduced) {
          final fits = _groupWidth <= _viewport;
          return ClipRect(
            child: OverflowBox(
              alignment: switch (fits) {
                true => Alignment.center,
                false => AlignmentDirectional.centerStart,
              },
              minWidth: 0,
              maxWidth: double.infinity,
              child: first,
            ),
          );
        }
        final textDirection = Directionality.of(context);
        return ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            minWidth: 0,
            maxWidth: double.infinity,
            child: AnimatedBuilder(
              animation: _loop,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shift(textDirection), 0),
                child: child,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  first,
                  for (var copy = 1; copy < _copies; copy++)
                    ExcludeSemantics(
                      child: ExcludeFocus(child: IgnorePointer(child: group)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
