/// A [Lettering] size: the CSS font size, and the larger one from the `sm`
/// breakpoint (640 px) up for the two biggest.
///
/// Mirrors `SIZE` in upstream `src/components/ui/lettering.tsx`.
enum LetteringSize {
  /// `text-3xl`.
  sm(30, 30),

  /// `text-5xl`.
  md(48, 48),

  /// `text-6xl`.
  lg(60, 60),

  /// `text-7xl sm:text-8xl`.
  xl(72, 96),

  /// `text-7xl sm:text-9xl`.
  hero(72, 128);

  const LetteringSize(this.cssSize, this.wideCssSize);

  final double cssSize;

  /// The size at 640 px wide and up.
  final double wideCssSize;

  /// Tailwind's `sm` breakpoint.
  static const double wideFrom = 640;

  /// The CSS size for a viewport [width] wide.
  double at(double width) => switch (width >= wideFrom) {
    true => wideCssSize,
    false => cssSize,
  };
}
