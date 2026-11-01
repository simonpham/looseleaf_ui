/// Where [Paper] lays its tape strips.
///
/// Mirrors `TapePlacement` in upstream `src/components/ui/paper.tsx`.
enum PaperTape {
  /// One strip across the top-left corner.
  corner,

  /// One strip along the top, centred.
  top,

  /// A strip across each top corner.
  both,
}
