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
    this.itemFraction = 1,
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

  /// How much of the view one item takes: 1, or `1 / 3` for three a view
  /// (upstream `basis-1/3` on the items).
  final double itemFraction;

  /// Called with the snap the carousel comes to rest on (upstream `setApi`
  /// plus `api.on("select")`).
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
  late final PageController _controller = PageController(
    viewportFraction: widget.itemFraction,
  );
  int _page = 0;
  int _count = 0;

  /// The snap an arrow, key or tick is sliding to; pages passed on the way
  /// are not selections.
  int? _target;

  int get _snapCount {
    if (_count == 0) return 0;
    if (widget.loop || widget.itemFraction >= 1) return _count;
    final perView = (1 / widget.itemFraction).round();
    return math.max(1, _count - perView + 1);
  }

  void _onPage(int page) {
    if (_target case final target? when target != page) return;
    _select(page);
  }

  void _select(int page) {
    final snap = math.min(page, math.max(0, _snapCount - 1));
    if (snap == _page) return;
    setState(() => _page = snap);
    widget.onSelect?.call(snap);
  }

  void _onCount(int count) {
    if (count == _count) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _count = count);
    });
  }

  void _scrollTo(int index) {
    if (!_controller.hasClients) return;
    final target = math.max(0, math.min(index, _snapCount - 1));
    final duration = InkMotion.of(context, InkMotion.sheet);
    _select(target);
    if (duration == Duration.zero) {
      _controller.jumpToPage(target);
      return;
    }
    _target = target;
    unawaited(
      _controller
          .animateToPage(target, duration: duration, curve: InkMotion.easeOut)
          .whenComplete(() => _target = null),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
    final snapCount = _snapCount;
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
          child: Column(mainAxisSize: MainAxisSize.min, children: [...content]),
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
      selectedIndex: selected,
      snapCount: snapCount,
      loop: widget.loop,
      itemFraction: widget.itemFraction,
      seed: inkSeed(widget.seed),
      scrollTo: _scrollTo,
      onPage: _onPage,
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
