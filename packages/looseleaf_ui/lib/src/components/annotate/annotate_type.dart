/// The mark an [Annotate] draws; `id` is the upstream name.
///
/// Mirrors `AnnotateType` in upstream `src/components/ui/annotate.tsx`.
enum AnnotateType {
  underline('underline'),
  box('box'),
  circle('circle'),
  highlight('highlight'),
  strikeThrough('strike-through'),
  crossedOff('crossed-off'),
  brackets('brackets'),
  scribble('scribble');

  const AnnotateType(this.id);

  /// The upstream name.
  final String id;
}
