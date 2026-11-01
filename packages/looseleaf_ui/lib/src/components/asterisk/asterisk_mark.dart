import 'package:looseleaf_ink/looseleaf_ink.dart';

/// The footnote marks an [Asterisk] can draw.
///
/// Mirrors `AsteriskMark` and `MARKS` in upstream
/// `src/components/ui/asterisk.tsx`.
enum AsteriskMark {
  asterisk(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart('M12.3 3.6 L11.7 20.4', 1.3),
        StrokePart('M4.4 7.9 L19.6 16.3', 1.3),
        StrokePart('M19.1 7.5 L5.2 16.6', 1.3),
      ],
      small: [
        StrokePart('M12.4 3 L11.6 21', 1.1),
        StrokePart('M3.5 7.4 L20.3 16.8', 1.1),
        StrokePart('M20 7 L4.4 17', 1.1),
      ],
    ),
  ),
  star(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart(
          'M12.2 3.1 L14.8 9.3 L21.3 9.9 L16.4 14.3 L17.9 20.7 L12.1 17.3 '
          'L6.3 20.8 L7.7 14.3 L2.8 9.8 L9.4 9.3 L12.5 3.9',
          1.15,
        ),
      ],
      small: [
        StrokePart(
          'M12.2 2.6 L15 9 L21.6 9.7 L16.7 14.2 L18.2 21 L12.1 17.5 L5.9 21.1 '
          'L7.4 14.2 L2.4 9.6 L9.2 9 L12.6 3.4',
          1.05,
        ),
      ],
    ),
  ),
  dagger(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart('M12.1 2.9 L11.8 21.3', 1.3),
        StrokePart('M7.7 8.3 L16.4 7.8', 1.3),
      ],
      small: [
        StrokePart('M12.2 2.4 L11.8 21.8', 1.15),
        StrokePart('M6.9 8.4 L17.2 7.9', 1.15),
      ],
    ),
  ),
  doubleDagger(
    ArtDef(
      grid: ArtGrid.icon,
      parts: [
        StrokePart('M12.1 2.9 L11.8 21.3', 1.3),
        StrokePart('M7.7 7.6 L16.4 7.2', 1.3),
        StrokePart('M8.1 13.9 L15.9 14.3', 1.3),
      ],
      small: [
        StrokePart('M12.2 2.4 L11.8 21.8', 1.15),
        StrokePart('M6.9 7.6 L17.2 7.1', 1.15),
        StrokePart('M7.4 14.2 L16.8 14.6', 1.15),
      ],
    ),
  );

  const AsteriskMark(this.def);

  /// The drawing.
  final ArtDef def;

  /// The upstream name (`double-dagger`).
  String get id => switch (this) {
    doubleDagger => 'double-dagger',
    _ => name,
  };
}

/// The pen an [Asterisk] is drawn with.
enum AsteriskTone { red, ink, blue, pencil }
