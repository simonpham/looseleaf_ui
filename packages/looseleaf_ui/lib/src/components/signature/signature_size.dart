/// A [Signature]'s font size.
///
/// Mirrors `SIZE` in upstream `src/components/ui/signature.tsx`.
enum SignatureSize {
  sm(28),
  md(44),
  lg(64);

  const SignatureSize(this.fontSize);

  /// The CSS font size of the name, in px.
  final double fontSize;
}
