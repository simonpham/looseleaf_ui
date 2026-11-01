import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sonner/sonner.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Where a [Toaster] stacks its toasts.
enum ToasterPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  bool get top => switch (this) {
    topLeft || topCenter || topRight => true,
    _ => false,
  };

  bool get right => this == topRight || this == bottomRight;
  bool get center => this == topCenter || this == bottomCenter;
}

/// Shows the toasts sent with [toast] over [child], stacked in a corner:
/// paper slips that are tossed in (dropped in, away from the right), tuck
/// behind each other, fan out while the pointer is over them, time out
/// after [duration] (paused on hover) and can be swiped away.
///
/// Wrap the app (or a page) once:
///
/// ```dart
/// Toaster(child: app)
/// // anywhere:
/// toast.success('Notebook saved', description: 'All 48 pages are safe.');
/// ```
///
/// Mirrors `Toaster` in upstream `src/components/ui/sonner.tsx` (sonner).
class Toaster extends StatefulWidget {
  const Toaster({
    super.key,
    required this.child,
    this.controller,
    this.position = ToasterPosition.bottomRight,
    this.decoration = ToastDecoration.none,
    this.closeButton = false,
    this.expand = false,
    this.visibleToasts = 3,
    this.duration = const Duration(milliseconds: 4000),
    this.gap = Spacing.d14,
    this.offset = Spacing.d24,
    this.semanticLabel = 'Notifications',
  });

  final Widget child;

  /// The toasts to show; [ToastController.instance] (what [toast] sends to)
  /// when null.
  final ToastController? controller;

  final ToasterPosition position;

  /// Tape or a pin on every toast.
  final ToastDecoration decoration;

  /// Puts a close button on every toast.
  final bool closeButton;

  /// Keeps the stack fanned out.
  final bool expand;

  /// How many toasts show at once.
  final int visibleToasts;

  /// How long a toast stays.
  final Duration duration;

  /// The space between fanned-out toasts, and the step between tucked ones.
  final double gap;

  /// The distance from the screen's edges.
  final double offset;

  /// The landmark's name.
  final String semanticLabel;

  /// How far a swipe must go to throw a toast away (sonner's threshold).
  static const double swipeThreshold = 45;

  /// The scale lost per tucked toast.
  static const double tuckScale = 0.05;

  /// How long a toast takes to leave.
  static const Duration leave = Duration(milliseconds: 200);

  @override
  State<Toaster> createState() => _ToasterState();
}

class _ToasterState extends State<Toaster> {
  final List<ToastData> _shown = [];
  final Set<Object> _leaving = {};
  final Map<Object, double> _heights = {};
  final Map<Object, double> _drag = {};
  final Map<Object, Timer> _timers = {};
  final Map<Object, Duration> _remaining = {};
  final Map<Object, Stopwatch> _clocks = {};
  bool _hovered = false;
  late ToastController _controller =
      widget.controller ?? ToastController.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    _apply();
  }

  @override
  void didUpdateWidget(Toaster oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.controller ?? ToastController.instance;
    if (identical(next, _controller)) return;
    _controller.removeListener(_sync);
    _controller = next..addListener(_sync);
    _sync();
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _sync() => setState(_apply);

  void _apply() {
    final live = _controller.toasts;
    final ids = {for (final toast in live) toast.id};
    for (final shown in [..._shown]) {
      if (ids.contains(shown.id) || _leaving.contains(shown.id)) continue;
      _leaving.add(shown.id);
      _stop(shown.id);
      _timers[(#leave, shown.id)] = Timer(Toaster.leave, () {
        _timers.remove((#leave, shown.id));
        setState(() {
          _leaving.remove(shown.id);
          _shown.removeWhere((toast) => toast.id == shown.id);
          _heights.remove(shown.id);
          _drag.remove(shown.id);
        });
      });
    }
    for (final toast in live) {
      final at = _shown.indexWhere((shown) => shown.id == toast.id);
      if (at < 0) {
        _shown.add(toast);
        _start(toast, restart: true);
        continue;
      }
      final changed = _shown[at].type != toast.type;
      _shown[at] = toast;
      if (changed) _start(toast, restart: true);
    }
  }

  Duration? _lifetime(ToastData toast) {
    if (toast.type == ToastType.loading) return null;
    return toast.duration ?? widget.duration;
  }

  void _start(ToastData toast, {bool restart = false}) {
    final life = _lifetime(toast);
    _timers.remove(toast.id)?.cancel();
    if (life == null) {
      _remaining.remove(toast.id);
      return;
    }
    if (restart) _remaining[toast.id] = life;
    final left = _remaining[toast.id] ?? life;
    if (_hovered) return;
    _clocks[toast.id] = Stopwatch()..start();
    _timers[toast.id] = Timer(left, () {
      toast.onAutoClose?.call();
      _controller.dismiss(toast.id);
    });
  }

  void _stop(Object id) {
    _timers.remove(id)?.cancel();
    final clock = _clocks.remove(id);
    final left = _remaining[id];
    if (clock == null || left == null) return;
    _remaining[id] = left - clock.elapsed;
  }

  void _hover(bool hovered) {
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
    for (final toast in _shown) {
      if (_leaving.contains(toast.id)) continue;
      switch (hovered) {
        case true:
          _stop(toast.id);
        case false:
          _start(toast);
      }
    }
  }

  void _onHeight(Object id, double height) {
    if (_heights[id] == height) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _heights[id] = height);
    });
  }

  void _close(ToastData toast) => _controller.dismiss(toast.id);

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    final screen = MediaQuery.maybeSizeOf(context)?.width ?? ToastCard.width;
    final width = math.min(ToastCard.width, screen - 2 * Spacing.d16);
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: switch (position.top) {
            true => widget.offset,
            false => null,
          },
          bottom: switch (position.top) {
            true => null,
            false => widget.offset,
          },
          left: switch ((position.center, position.right)) {
            (true, _) => 0,
            (false, false) => widget.offset,
            (false, true) => null,
          },
          right: switch ((position.center, position.right)) {
            (true, _) => 0,
            (false, true) => widget.offset,
            (false, false) => null,
          },
          child: Semantics(
            container: true,
            label: widget.semanticLabel,
            child: Align(
              widthFactor: switch (position.center) {
                true => null,
                false => 1,
              },
              heightFactor: 1,
              child: MouseRegion(
                onEnter: (_) => _hover(true),
                onExit: (_) => _hover(false),
                child: SizedBox(width: width, child: _stack(context)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stack(BuildContext context) {
    final newestFirst = _shown.reversed.toList();
    if (newestFirst.isEmpty) return const SizedBox.shrink();
    final expanded = widget.expand || _hovered;
    final top = widget.position.top;
    final front = newestFirst.first;
    final frontHeight = _heights[front.id] ?? 0;
    final offsets = <double>[];
    var run = 0.0;
    for (final (index, toast) in newestFirst.indexed) {
      offsets.add(switch (expanded) {
        true => run,
        false => index * widget.gap,
      });
      run += (_heights[toast.id] ?? 0) + widget.gap;
    }
    final shownCount = math.min(newestFirst.length, widget.visibleToasts);
    final height = switch (expanded) {
      true => run - widget.gap,
      false => frontHeight + (shownCount - 1) * widget.gap,
    };
    final duration = InkMotion.of(context, InkMotion.sheet);
    return SizedBox(
      height: math.max(0, height),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (index, toast) in newestFirst.indexed.toList().reversed)
            AnimatedPositioned(
              key: ValueKey(toast.id),
              duration: duration,
              curve: InkMotion.easeOut,
              left: 0,
              right: 0,
              top: switch (top) {
                true => offsets[index],
                false => null,
              },
              bottom: switch (top) {
                true => null,
                false => offsets[index],
              },
              child: _toast(context, toast, index, expanded, frontHeight),
            ),
        ],
      ),
    );
  }

  Widget _toast(
    BuildContext context,
    ToastData toast,
    int index,
    bool expanded,
    double frontHeight,
  ) {
    final hidden = index >= widget.visibleToasts || _leaving.contains(toast.id);
    final tucked = !expanded && index > 0;
    final dx = _drag[toast.id] ?? 0;
    final duration = InkMotion.of(context, InkMotion.sheet);
    Widget card = _Measured(
      onHeight: (height) => _onHeight(toast.id, height),
      tight: tucked,
      child: ToastCard(
        toast: toast,
        onClose: () => _close(toast),
        closeButton: widget.closeButton,
        decoration: widget.decoration,
        showContent: !tucked,
      ),
    );
    if (tucked && frontHeight > 0) {
      card = SizedBox(height: frontHeight, child: card);
    }
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
        opacity: switch (hidden) {
          true => 0,
          false => (1 - dx.abs() / (Toaster.swipeThreshold * 3)).clamp(0, 1),
        },
        duration: InkMotion.of(context, Toaster.leave),
        child: AnimatedScale(
          scale: switch (tucked) {
            true => 1 - index * Toaster.tuckScale,
            false => 1,
          },
          alignment: switch (widget.position.top) {
            true => Alignment.bottomCenter,
            false => Alignment.topCenter,
          },
          duration: duration,
          child: GestureDetector(
            onHorizontalDragUpdate: switch (toast.dismissible) {
              true => (details) => setState(
                () => _drag[toast.id] = dx + details.delta.dx,
              ),
              false => null,
            },
            onHorizontalDragEnd: switch (toast.dismissible) {
              true => (_) => _endSwipe(toast),
              false => null,
            },
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: ToastEntrance(
                arrival: switch (widget.position.right) {
                  true => ToastArrival.toss,
                  false => ToastArrival.drop,
                },
                child: card,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _endSwipe(ToastData toast) {
    final dx = _drag[toast.id] ?? 0;
    if (dx.abs() < Toaster.swipeThreshold) {
      setState(() => _drag[toast.id] = 0);
      return;
    }
    toast.onDismiss?.call();
    _close(toast);
  }
}

/// Reports its child's natural height, unless [tight] (a tucked toast is
/// held to the front one's height and must not report that).
class _Measured extends SingleChildRenderObjectWidget {
  const _Measured({
    required this.onHeight,
    required this.tight,
    required super.child,
  });

  final ValueChanged<double> onHeight;
  final bool tight;

  @override
  _RenderMeasured createRenderObject(BuildContext context) =>
      _RenderMeasured(onHeight, tight);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasured renderObject) {
    renderObject
      ..onHeight = onHeight
      ..tight = tight;
  }
}

class _RenderMeasured extends RenderProxyBox {
  _RenderMeasured(this.onHeight, this.tight);

  ValueChanged<double> onHeight;
  bool tight;

  @override
  void performLayout() {
    super.performLayout();
    if (!tight) onHeight(size.height);
  }
}
