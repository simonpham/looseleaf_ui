import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_controller.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_snaps.dart';

/// What a [Carousel] hands its parts, and what `Carousel.maybeOf(context)`
/// gives your own controls (upstream `useCarousel` and the Embla api).
class CarouselScope extends InheritedWidget {
  const CarouselScope({
    super.key,
    required this.axis,
    required this.controller,
    required this.scrollController,
    required this.selectedIndex,
    required this.snapCount,
    required this.loop,
    required this.align,
    required this.itemFraction,
    required this.seed,
    required this.onCount,
    required super.child,
  });

  /// [Axis.horizontal] slides sideways; [Axis.vertical] up and down.
  final Axis axis;

  /// The carousel's api: where it rests, and the calls that move it.
  final CarouselController controller;

  /// Scrolls the strip of [CarouselContent].
  final ScrollController scrollController;

  /// The slide the carousel rests on.
  final int selectedIndex;

  /// How many places it can rest on.
  final int snapCount;
  final bool loop;

  /// Where a slide lines up when the carousel rests on it.
  final CarouselAlign align;

  /// How much of the view one item takes (upstream `basis-*`).
  final double itemFraction;

  /// The drawing seed the dots derive theirs from.
  final String seed;

  /// Called by [CarouselContent] with its number of items.
  final ValueChanged<int> onCount;

  bool get canScrollPrev => loop || selectedIndex > 0;
  bool get canScrollNext => loop || selectedIndex < snapCount - 1;

  /// Slides to a snap.
  void scrollTo(int index) => controller.scrollTo(index);

  /// Slides back one snap.
  void scrollPrev() => controller.scrollPrev();

  /// Slides on one snap.
  void scrollNext() => controller.scrollNext();

  static CarouselScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CarouselScope>();

  @override
  bool updateShouldNotify(CarouselScope oldWidget) =>
      oldWidget.axis != axis ||
      oldWidget.controller != controller ||
      oldWidget.scrollController != scrollController ||
      oldWidget.selectedIndex != selectedIndex ||
      oldWidget.snapCount != snapCount ||
      oldWidget.loop != loop ||
      oldWidget.align != align ||
      oldWidget.itemFraction != itemFraction ||
      oldWidget.seed != seed;
}
