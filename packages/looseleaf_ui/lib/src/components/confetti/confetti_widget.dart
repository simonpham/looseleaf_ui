import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_burst.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_controller.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_options.dart';
import 'package:looseleaf_ui/src/components/confetti/confetti_painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A layer that throws hand-cut confetti: strips, dots, stars, triangles,
/// curls and scraps leave in a cone, slow down like paper, sway, flip and
/// fade. The pieces stay inside the layer and never take input.
///
/// A burst goes off when [active] turns true, when [burstKey] changes, or
/// when [controller]'s `burst` is called; [options] are its defaults.
/// With a [child] the layer covers it; without one it fills its parent.
/// Reduced motion throws nothing. Confetti is decoration: say what
/// happened in words too.
///
/// ```dart
/// Confetti(
///   active: allDone,
///   options: const ConfettiOptions(spread: 90, count: 60),
///   child: const TaskCard(),
/// )
/// ```
///
/// Mirrors `Confetti` in upstream `src/components/ui/confetti.tsx`; the
/// flight is the engine's `simulate`, driven by a ticker.
class Confetti extends StatefulWidget {
  const Confetti({
    super.key,
    this.child,
    this.active = false,
    this.burstKey,
    this.controller,
    this.options = const ConfettiOptions(),
  });

  final Widget? child;

  /// Throws a burst each time this turns true (and on mount when true).
  final bool active;

  /// Throws a burst each time this changes.
  final Object? burstKey;

  /// Throws bursts on demand.
  final ConfettiController? controller;

  /// The default options of every burst.
  final ConfettiOptions options;

  static int _bursts = 0;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<Duration> _clock = ValueNotifier(Duration.zero);
  final GlobalKey _layer = GlobalKey();
  List<ConfettiBurst> _bursts = const [];

  @override
  void initState() {
    super.initState();
    widget.controller?.attach(_burst);
    if (widget.active) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _burst(null);
      });
    }
  }

  @override
  void didUpdateWidget(Confetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(_burst);
      widget.controller?.attach(_burst);
    }
    if (widget.active && !oldWidget.active) _burst(null);
    if (widget.burstKey != oldWidget.burstKey) _burst(null);
  }

  VoidCallback _burst(ConfettiOptions? extra) {
    if (InkMotion.reducedIn(context)) return () {};
    final running = _ticker.isActive;
    final burst = ConfettiBurst.simulate(
      widget.options.merge(extra),
      number: ++Confetti._bursts,
      started: switch (running) {
        true => _clock.value,
        false => Duration.zero,
      },
    );
    if (!running) {
      _clock.value = Duration.zero;
      _ticker.start();
    }
    _resolveOrigin(burst);
    setState(() => _bursts = [..._bursts, burst]);
    return () => _stop(burst);
  }

  void _resolveOrigin(ConfettiBurst burst) {
    final box = _layer.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    burst.origin = switch (burst.globalOrigin) {
      final global? => box.globalToLocal(global),
      null => box.size.center(Offset.zero),
    };
  }

  void _stop(ConfettiBurst burst) {
    if (!mounted || !_bursts.contains(burst)) return;
    _finish([burst]);
  }

  void _finish(List<ConfettiBurst> done) {
    setState(() {
      _bursts = [
        for (final burst in _bursts)
          if (!done.contains(burst)) burst,
      ];
    });
    if (_bursts.isEmpty) _ticker.stop();
    for (final burst in done) {
      burst.onDone?.call();
    }
  }

  void _tick(Duration elapsed) {
    for (final burst in _bursts) {
      if (burst.origin == null) _resolveOrigin(burst);
    }
    _clock.value = elapsed;
    final done = [
      for (final burst in _bursts)
        if (burst.doneAt(elapsed)) burst,
    ];
    if (done.isNotEmpty) _finish(done);
  }

  @override
  void dispose() {
    widget.controller?.detach(_burst);
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layer = IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: CustomPaint(
            key: _layer,
            size: Size.infinite,
            painter: switch (_bursts.isEmpty) {
              true => null,
              false => ConfettiPainter(
                bursts: _bursts,
                clock: _clock,
                theme: LooseleafTheme.of(context),
              ),
            },
          ),
        ),
      ),
    );
    final child = widget.child;
    if (child == null) return SizedBox.expand(child: layer);
    return Stack(
      children: [
        child,
        Positioned.fill(child: layer),
      ],
    );
  }
}
