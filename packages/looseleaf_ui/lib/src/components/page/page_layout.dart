/// How wide a [PaperPage] may grow.
///
/// Mirrors `PageWidth` in upstream `src/components/ui/page.tsx`.
enum PageWidth {
  sm(512),
  md(672),
  lg(896),
  xl(1152),
  full(double.infinity);

  const PageWidth(this.maxWidth);

  /// The largest width in px (`max-w-*`).
  final double maxWidth;
}

/// Which edges of a [PaperPage] are torn off a pad.
///
/// Mirrors `PageProps['torn']` in upstream `src/components/ui/page.tsx`.
enum PageTorn { top, bottom, both }
