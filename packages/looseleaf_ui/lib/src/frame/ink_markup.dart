/// What a recipe returns: markup per state layer and the pad (in px) the
/// drawing reaches outside its box.
class InkMarkup {
  const InkMarkup({required this.parts, required this.pad});

  /// Layer name (`rest`, `hover`, …) to its SVG markup.
  final Map<String, String> parts;
  final double pad;
}
