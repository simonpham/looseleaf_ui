import 'package:flutter/foundation.dart';

/// Drives a [Carousel] from outside and tells you where it rests: the
/// Embla api upstream hands you through `setApi`. Its [value] is the
/// selected snap; listen to it for upstream's `api.on("select")`.
///
/// ```dart
/// final carousel = CarouselController();
/// Carousel(controller: carousel, children: [...]);
/// ValueListenableBuilder(
///   valueListenable: carousel,
///   builder: (context, index, _) => Text('Slide ${index + 1}'),
/// );
/// ```
///
/// Mirrors `CarouselApi` in upstream `src/components/ui/carousel.tsx`.
class CarouselController extends ChangeNotifier
    implements ValueListenable<int> {
  int _index = 0;
  int _snapCount = 0;
  bool _loop = false;
  ValueChanged<int>? _scrollTo;

  /// The snap the carousel rests on (Embla `selectedScrollSnap()`).
  @override
  int get value => _index;

  /// The same as [value].
  int get selectedIndex => _index;

  /// How many places the carousel can rest on (Embla
  /// `scrollSnapList().length`).
  int get snapCount => _snapCount;

  /// Whether [scrollPrev] goes anywhere.
  bool get canScrollPrev => _loop || _index > 0;

  /// Whether [scrollNext] goes anywhere.
  bool get canScrollNext => _loop || _index < _snapCount - 1;

  /// Slides to the snap at [index].
  void scrollTo(int index) => _scrollTo?.call(index);

  /// Slides back one snap, round to the last when it loops.
  void scrollPrev() {
    if (!canScrollPrev || _snapCount == 0) return;
    scrollTo((_index - 1) % _snapCount);
  }

  /// Slides on one snap, round to the first when it loops.
  void scrollNext() {
    if (!canScrollNext || _snapCount == 0) return;
    scrollTo((_index + 1) % _snapCount);
  }

  /// Binds the carousel that answers [scrollTo]; the [Carousel] calls it.
  void attach(ValueChanged<int> scrollTo) => _scrollTo = scrollTo;

  /// Unbinds [scrollTo] if it is the one attached; the [Carousel] calls it.
  void detach(ValueChanged<int> scrollTo) {
    if (_scrollTo == scrollTo) _scrollTo = null;
  }

  /// Records where the carousel rests; the [Carousel] calls it.
  void sync({required int index, required int snapCount, required bool loop}) {
    if (index == _index && snapCount == _snapCount && loop == _loop) return;
    _index = index;
    _snapCount = snapCount;
    _loop = loop;
    notifyListeners();
  }
}
