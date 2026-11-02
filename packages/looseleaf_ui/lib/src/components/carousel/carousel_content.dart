import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_physics.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_scope.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_snaps.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The strip of slides of a [Carousel]: its [CarouselItem]s, [gap] apart,
/// in a window that clips them along the strip but lets drawings bleed 12
/// across it. Swipe or drag it.
///
/// Mirrors `CarouselContent` in upstream `src/components/ui/carousel.tsx`.
class CarouselContent extends StatelessWidget {
  const CarouselContent({
    super.key,
    required this.children,
    this.extent,
    this.gap = defaultGap,
  });

  final List<Widget> children;

  /// The strip's height. Horizontal strips default to square items; a
  /// vertical strip takes the height it is given, else room for square
  /// items (upstream `h-[200px]` on a vertical content).
  final double? extent;

  /// The room between items: upstream's `ps-4` on the items with `-ms-4`
  /// on the content (`pt-*` and `-mt-*` when vertical).
  final double gap;

  /// Upstream's default gap (`ps-4`).
  static const double defaultGap = Spacing.d16;

  /// How far drawings may reach past the strip across it (`py-3`).
  static const double bleed = Spacing.d12;

  @override
  Widget build(BuildContext context) {
    final scope = CarouselScope.maybeOf(context);
    scope?.onCount(children.length);
    final axis = scope?.axis ?? Axis.horizontal;
    final fraction = scope?.itemFraction ?? 1;
    final vertical = axis == Axis.vertical;
    final snaps = carouselSnaps(
      count: children.length,
      fraction: fraction,
      align: scope?.align ?? CarouselAlign.center,
      loop: scope?.loop ?? false,
    );
    final direction = switch (vertical) {
      true => AxisDirection.down,
      false => textDirectionToAxisDirection(Directionality.of(context)),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final along = switch (vertical) {
          true => extent ?? _verticalAlong(constraints, fraction),
          false => constraints.maxWidth,
        };
        final across = switch (vertical) {
          true => constraints.maxWidth,
          false => extent ?? _square(along, fraction),
        };
        final view = along + gap;
        final strip = ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Scrollable(
            controller: scope?.scrollController,
            axisDirection: direction,
            physics: CarouselPhysics(snaps: snaps),
            clipBehavior: Clip.none,
            viewportBuilder: (context, position) => Viewport(
              axisDirection: direction,
              offset: position,
              clipBehavior: Clip.none,
              slivers: [
                SliverFixedExtentList(
                  itemExtent: view * fraction,
                  delegate: SliverChildListDelegate([
                    for (final child in children)
                      Padding(
                        padding: switch (vertical) {
                          true => EdgeInsets.only(top: gap),
                          false => EdgeInsetsDirectional.only(start: gap),
                        },
                        child: child,
                      ),
                  ]),
                ),
              ],
            ),
          ),
        );
        return ClipRect(
          clipper: _BleedClipper(axis),
          child: SizedBox(
            height: switch (vertical) {
              true => along,
              false => across,
            },
            width: switch (vertical) {
              true => across,
              false => along,
            },
            child: OverflowBox(
              alignment: switch (vertical) {
                true => Alignment.bottomCenter,
                false => AlignmentDirectional.centerEnd,
              },
              minWidth: switch (vertical) {
                true => null,
                false => view,
              },
              maxWidth: switch (vertical) {
                true => null,
                false => view,
              },
              minHeight: switch (vertical) {
                true => view,
                false => null,
              },
              maxHeight: switch (vertical) {
                true => view,
                false => null,
              },
              child: strip,
            ),
          ),
        );
      },
    );
  }

  /// A square item's extent across the strip.
  double _square(double along, double fraction) =>
      (along + gap) * fraction - gap;

  /// A vertical strip's height: the bounded height it gets, else room for
  /// square items as wide as the strip.
  double _verticalAlong(BoxConstraints constraints, double fraction) {
    if (constraints.hasBoundedHeight) return constraints.maxHeight;
    return (constraints.maxWidth + gap) / fraction - gap;
  }
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
