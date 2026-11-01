import 'package:flutter/widgets.dart';

/// One slide of a [CarouselContent], read as a slide by screen readers.
///
/// Mirrors `CarouselItem` in upstream `src/components/ui/carousel.tsx`.
class CarouselItem extends StatelessWidget {
  const CarouselItem({super.key, required this.child, this.semanticLabel});

  final Widget child;

  /// Names the slide, such as "1 of 5".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, label: semanticLabel, child: child);
}
