import 'dart:ui';

import 'package:looseleaf_ui/src/theme/theme.dart';

/// The riso ink a [Lettering] prints its misregistered second pass in.
///
/// Mirrors `TONE` in upstream `src/components/ui/lettering.tsx`.
enum LetteringTone {
  marker,
  tomato,
  tangerine,
  lemon,
  grass,
  teal,
  sky,
  grape,
  bubblegum;

  /// The paint token.
  Color of(LooseleafColors colors) => switch (this) {
    marker => colors.marker,
    tomato => colors.tomato,
    tangerine => colors.tangerine,
    lemon => colors.lemon,
    grass => colors.grass,
    teal => colors.teal,
    sky => colors.sky,
    grape => colors.grape,
    bubblegum => colors.bubblegum,
  };
}
