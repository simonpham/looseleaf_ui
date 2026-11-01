import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The strip of slides of a [Carousel]: its [CarouselItem]s, 16 apart, in a
/// window that clips them sideways but lets drawings bleed 12 above and
/// below. Swipe or drag it.
///
/// Mirrors `CarouselContent` in upstream `src/components/ui/carousel.tsx`.
class CarouselContent extends StatelessWidget {
  const CarouselContent({super.key, required this.children, this.extent});

  final List<Widget> children;

  /// The strip's height (its width when vertical); a horizontal strip
  /// measures its first item when null.
  final double? extent;

  /// The room between items (`ps-4` with `-ms-4`).
  static const double gap = Spacing.d16;

  /// How far drawings may reach past the strip across it (`py-3`).
  static const double bleed = Spacing.d12;

  @override
  Widget build(BuildContext context) {
    final scope = CarouselScope.maybeOf(context);
    scope?.onCount(children.length);
    final axis = scope?.axis ?? Axis.horizontal;
    final fraction = scope?.itemFraction ?? 1;
    final controller = scope?.controller;
    final vertical = axis == Axis.vertical;
    return LayoutBuilder(
      builder: (context, constraints) {
        final along = switch (vertical) {
          true => constraints.maxHeight,
          false => constraints.maxWidth,
        };
        final pages = PageView(
          controller: controller,
          scrollDirection: axis,
          padEnds: false,
          clipBehavior: Clip.none,
          onPageChanged: scope?.onPage,
          children: [
            for (final child in children)
              Padding(
                padding: switch (vertical) {
                  true => const EdgeInsets.only(top: gap),
                  false => const EdgeInsetsDirectional.only(start: gap),
                },
                child: child,
              ),
          ],
        );
        final measured = extent ?? _measure(along, fraction, vertical);
        return ClipRect(
          clipper: _BleedClipper(axis),
          child: SizedBox(
            height: switch (vertical) {
              true => along,
              false => measured,
            },
            width: switch (vertical) {
              true => measured,
              false => along,
            },
            child: OverflowBox(
              alignment: switch (vertical) {
                true => Alignment.bottomCenter,
                false => AlignmentDirectional.centerEnd,
              },
              minWidth: switch (vertical) {
                true => null,
                false => along + gap,
              },
              maxWidth: switch (vertical) {
                true => null,
                false => along + gap,
              },
              minHeight: switch (vertical) {
                true => along + gap,
                false => null,
              },
              maxHeight: switch (vertical) {
                true => along + gap,
                false => null,
              },
              child: pages,
            ),
          ),
        );
      },
    );
  }

  /// A square item's extent: slides are square unless [extent] says
  /// otherwise (the docs' `aspect-square` cards).
  static double _measure(double along, double fraction, bool vertical) =>
      (along + gap) * fraction - gap;
}

class _BleedClipper extends CustomClipper<Rect> {
  const _BleedClipper(this.axis);

  final Axis axis;

  @override
  Rect getClip(Size size) => switch (axis) {
    Axis.horizontal => Rect.fromLTRB(
      0,
      -CarouselContent.bleed,
      size.width,
      size.height + CarouselContent.bleed,
    ),
    Axis.vertical => Rect.fromLTRB(
      -CarouselContent.bleed,
      0,
      size.width + CarouselContent.bleed,
      size.height,
    ),
  };

  @override
  bool shouldReclip(_BleedClipper oldClipper) => oldClipper.axis != axis;
}
