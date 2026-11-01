import 'package:looseleaf_ink/src/core/core.dart';

/// How a stroke part starts, ends and tapers, like a hand would draw it.
///
/// Mirrors `Hand` in `src/lib/ink/art/types.ts`.
final class Hand {
  /// A hand; unset fields fall back to soft ends and no taper.
  const Hand({this.start, this.end, this.taper});

  /// The stroke start.
  final StrokeStart? start;

  /// The stroke end.
  final StrokeEnd? end;

  /// Pressure falling along the stroke; 0 or null for none.
  final double? taper;
}
