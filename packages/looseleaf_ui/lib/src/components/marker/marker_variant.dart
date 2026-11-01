/// How a [Marker] sets off its words.
///
/// Mirrors `markerVariants` in upstream `src/components/ui/marker.tsx`.
enum MarkerVariant {
  /// Small print in a row, usually after an icon: someone joined.
  regular,

  /// A pencil rule on each side of the words, written in script: a day.
  separator,

  /// One rule under the whole row: a section heading.
  border,
}
