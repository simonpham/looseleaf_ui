import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Slides you swipe, drag or step through: a [CarouselContent] of
/// [CarouselItem]s, with optional [CarouselPrevious] and [CarouselNext]
/// arrows and [CarouselDots] (tally ticks, every fifth a slash).
///
/// The arrows sit 48 outside the slides, in room the carousel keeps for
/// them. With focus inside, Left and Right (Up and Down when vertical,
/// mirrored right to left) step through, and screen readers hear "Slide
/// 2 of 5".
///
/// ```dart
/// Carousel(children: [
///   CarouselContent(children: [
///     for (final card in cards) CarouselItem(child: card),
///   ]),
///   CarouselPrevious(),
///   CarouselNext(),
/// ])
/// ```
///
/// Mirrors `Carousel` in upstream `src/components/ui/carousel.tsx` (Embla).
class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.children,
    this.axis = Axis.horizontal,
    this.loop = false,
    this.align = CarouselAlign.center,
    this.itemFraction = 1,
    this.controller,
    this.onSelect,
    this.seed,
    this.semanticLabel,
  });

  /// The [CarouselContent] and the controls.
  final List<Widget> children;

  /// Upstream `orientation`.
  final Axis axis;

  /// Wraps round from the last slide to the first (Embla `loop`).
  final bool loop;

  /// Where a slide lines up when the carousel rests on it (Embla `align`,
  /// `center` by default).
  final CarouselAlign align;

  /// How much of the view one item takes: 1, or `1 / 3` for three a view
  /// (upstream `basis-1/3` on the items).
  final double itemFraction;

  /// Drives the carousel from outside and reports where it rests
  /// (upstream `setApi`).
  final CarouselController? controller;

  /// Called with the snap the carousel comes to rest on (upstream
  /// `api.on("select")`).
  final ValueChanged<int>? onSelect;

  /// Pins the hand of the dots.
  final String? seed;

  /// Names the carousel for screen readers.
  final String? semanticLabel;

  /// How far outside the slides the arrows sit (`-start-12`).
  static const double arrowRoom = Spacing.d48;

  /// The nearest carousel's state, or null outside one.
  static CarouselScope? maybeOf(BuildContext context) =>
      CarouselScope.maybeOf(context);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> with InkSeed {
  final ScrollController _scroll = ScrollController();
  CarouselController? _ownController;
  int _count = 0;
  double? _view;

  /// The snap an arrow, key or tick is sliding to; snaps passed on the way
  /// are not selections.
  int? _target;

  CarouselController get _controller =>
      widget.controller ?? (_ownController ??= CarouselController());

  List<double> get _snaps => carouselSnaps(
    count: _count,
    fraction: widget.itemFraction,
    align: widget.align,
    loop: widget.loop,
  );

  int get _page => _controller.selectedIndex;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _bind(_controller);
  }

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      _sync(_page);
      return;
    }
    final previous = oldWidget.controller ?? _ownController;
    if (previous != null) _unbind(previous);
    _bind(_controller);
  }

  void _bind(CarouselController controller) {
    controller
      ..attach(_scrollTo)
      ..addListener(_onController);
    _sync(math.min(controller.selectedIndex, math.max(0, _snaps.length - 1)));
  }

  void _unbind(CarouselController controller) {
    controller
      ..detach(_scrollTo)
      ..removeListener(_onController);
  }

  void _onController() {
    if (mounted) setState(() {});
  }

  void _sync(int index) => _controller.sync(
    index: index,
    snapCount: _snaps.length,
    loop: widget.loop,
  );

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final view = position.viewportDimension;
    if (view <= 0) return;
    final page = nearestCarouselSnap(_snaps, position.pixels / view);
    if (_target case final target? when target != page) return;
    _select(page);
  }

  void _select(int page) {
    final snap = math.min(page, math.max(0, _snaps.length - 1));
    if (snap == _page) return;
    _sync(snap);
    widget.onSelect?.call(snap);
  }

  void _onCount(int count) {
    if (count == _count) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _count = count;
      _sync(math.min(_page, math.max(0, _snaps.length - 1)));
    });
  }

  /// Keeps the strip on its snap when the view changes size.
  bool _onMetrics(ScrollMetricsNotification notification) {
    final view = notification.metrics.viewportDimension;
    if (view == _view) return false;
    final resized = _view != null;
    _view = view;
    if (!resized || !_scroll.hasClients) return false;
    final snaps = _snaps;
    if (_page >= snaps.length) return false;
    _scroll.jumpTo(snaps[_page] * view);
    return false;
  }

  void _scrollTo(int index) {
    if (!_scroll.hasClients) return;
    final snaps = _snaps;
    if (snaps.isEmpty) return;
    final target = math.max(0, math.min(index, snaps.length - 1));
    final offset = snaps[target] * _scroll.position.viewportDimension;
    final duration = InkMotion.of(context, InkMotion.sheet);
    _select(target);
    if (duration == Duration.zero) {
      _scroll.jumpTo(offset);
      return;
    }
    _target = target;
    unawaited(
      _scroll
          .animateTo(offset, duration: duration, curve: InkMotion.easeOut)
          .whenComplete(() => _target = null),
    );
  }

  @override
  void dispose() {
    _unbind(_controller);
    _scroll.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  Map<ShortcutActivator, VoidCallback> _keys(CarouselScope scope) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final (back, forward) = switch ((widget.axis, rtl)) {
      (Axis.vertical, _) => (
        LogicalKeyboardKey.arrowUp,
        LogicalKeyboardKey.arrowDown,
      ),
      (Axis.horizontal, false) => (
        LogicalKeyboardKey.arrowLeft,
        LogicalKeyboardKey.arrowRight,
      ),
      (Axis.horizontal, true) => (
        LogicalKeyboardKey.arrowRight,
        LogicalKeyboardKey.arrowLeft,
      ),
    };
    return {
      SingleActivator(back): scope.scrollPrev,
      SingleActivator(forward): scope.scrollNext,
    };
  }

  @override
  Widget build(BuildContext context) {
    final snapCount = _snaps.length;
    final selected = math.min(_page, math.max(0, snapCount - 1));
    final children = widget.children;
    final content = children.whereType<CarouselContent>();
    final steps = children.whereType<CarouselStep>();
    final rest = [
      for (final child in children)
        if (child is! CarouselContent && child is! CarouselStep) child,
    ];
    final room = switch (steps.isEmpty) {
      true => 0.0,
      false => Carousel.arrowRoom,
    };
    final vertical = widget.axis == Axis.vertical;
    final slides = Stack(
      children: [
        Padding(
          padding: switch (vertical) {
            true => EdgeInsets.symmetric(vertical: room),
            false => EdgeInsetsDirectional.symmetric(horizontal: room),
          },
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _onMetrics,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [...content],
            ),
          ),
        ),
        for (final step in steps)
          switch ((vertical, step.forward)) {
            (false, false) => PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Center(child: step),
            ),
            (false, true) => PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              child: Center(child: step),
            ),
            (true, false) => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: step),
            ),
            (true, true) => Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(child: step),
            ),
          },
      ],
    );
    return CarouselScope(
      axis: widget.axis,
      controller: _controller,
      scrollController: _scroll,
      selectedIndex: selected,
      snapCount: snapCount,
      loop: widget.loop,
      align: widget.align,
      itemFraction: widget.itemFraction,
      seed: inkSeed(widget.seed),
      onCount: _onCount,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        child: _Keys(
          keys: _keys,
          child: FocusTraversalGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                slides,
                ...rest,
                Semantics(
                  container: true,
                  liveRegion: true,
                  label: switch (snapCount > 1) {
                    true => 'Slide ${selected + 1} of $snapCount',
                    false => '',
                  },
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Binds the carousel's arrow keys, read from the scope below the
/// [Carousel] so they step the live state.
class _Keys extends StatelessWidget {
  const _Keys({required this.keys, required this.child});

  final Map<ShortcutActivator, VoidCallback> Function(CarouselScope scope) keys;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = CarouselScope.maybeOf(context);
    if (scope == null) return child;
    return CallbackShortcuts(bindings: keys(scope), child: child);
  }
}
