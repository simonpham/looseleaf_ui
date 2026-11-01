import 'package:flutter/widgets.dart';

/// What a [Carousel] hands its parts, and what `Carousel.of(context)` gives
/// your own controls (upstream `useCarousel` and the Embla api).
class CarouselScope extends InheritedWidget {
  const CarouselScope({
    super.key,
    required this.axis,
    required this.controller,
    required this.selectedIndex,
    required this.snapCount,
    required this.loop,
    required this.itemFraction,
    required this.seed,
    required this.scrollTo,
    required this.onPage,
    required this.onCount,
    required super.child,
  });

  /// [Axis.horizontal] slides sideways; [Axis.vertical] up and down.
  final Axis axis;
  final PageController controller;

  /// The slide the carousel rests on.
  final int selectedIndex;

  /// How many places it can rest on.
  final int snapCount;
  final bool loop;

  /// How much of the view one item takes (upstream `basis-*`).
  final double itemFraction;

  /// The drawing seed the dots derive theirs from.
  final String seed;

  /// Slides to a snap.
  final ValueChanged<int> scrollTo;

  /// Called by [CarouselContent] as its page changes.
  final ValueChanged<int> onPage;

  /// Called by [CarouselContent] with its number of items.
  final ValueChanged<int> onCount;

  bool get canScrollPrev => loop || selectedIndex > 0;
  bool get canScrollNext => loop || selectedIndex < snapCount - 1;

  /// Slides back one snap.
  void scrollPrev() {
    if (!canScrollPrev || snapCount == 0) return;
    scrollTo((selectedIndex - 1) % snapCount);
  }

  /// Slides on one snap.
  void scrollNext() {
    if (!canScrollNext || snapCount == 0) return;
    scrollTo((selectedIndex + 1) % snapCount);
  }

  static CarouselScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CarouselScope>();

  @override
  bool updateShouldNotify(CarouselScope oldWidget) =>
      oldWidget.axis != axis ||
      oldWidget.controller != controller ||
      oldWidget.selectedIndex != selectedIndex ||
      oldWidget.snapCount != snapCount ||
      oldWidget.loop != loop ||
      oldWidget.itemFraction != itemFraction ||
      oldWidget.seed != seed;
}
