import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/carousel/carousel_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';

/// The arrow back to the previous slide: an outline icon button 48 before
/// the slides, dashed (disabled) on the first.
///
/// Mirrors `CarouselPrevious` in upstream `src/components/ui/carousel.tsx`.
class CarouselPrevious extends CarouselStep {
  const CarouselPrevious({
    super.key,
    super.variant,
    super.seed,
    super.semanticLabel = 'Previous slide',
  }) : super(forward: false);
}

/// The arrow on to the next slide: an outline icon button 48 after the
/// slides, dashed (disabled) on the last.
///
/// Mirrors `CarouselNext` in upstream `src/components/ui/carousel.tsx`.
class CarouselNext extends CarouselStep {
  const CarouselNext({
    super.key,
    super.variant,
    super.seed,
    super.semanticLabel = 'Next slide',
  }) : super(forward: true);
}

/// The shared body of [CarouselPrevious] and [CarouselNext]; the
/// [Carousel] places it by [forward].
class CarouselStep extends StatelessWidget {
  const CarouselStep({
    super.key,
    required this.forward,
    this.variant = ButtonVariant.outline,
    this.seed,
    required this.semanticLabel,
  });

  final bool forward;
  final ButtonVariant variant;
  final String? seed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = CarouselScope.maybeOf(context);
    final vertical = scope?.axis == Axis.vertical;
    final icon = switch ((vertical, forward)) {
      (false, false) => 'arrow-left',
      (false, true) => 'arrow-right',
      (true, false) => 'arrow-up',
      (true, true) => 'arrow-down',
    };
    final enabled = switch (forward) {
      true => scope?.canScrollNext ?? false,
      false => scope?.canScrollPrev ?? false,
    };
    return Button(
      variant: variant,
      size: ButtonSize.iconSm,
      disabled: !enabled,
      seed: seed,
      semanticLabel: semanticLabel,
      onPressed: switch (forward) {
        true => scope?.scrollNext,
        false => scope?.scrollPrev,
      },
      child: InkIcon(icon),
    );
  }
}
