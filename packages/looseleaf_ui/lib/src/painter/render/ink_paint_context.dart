import 'dart:ui';

import 'package:looseleaf_ui/src/painter/render/ink_state_effects.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What ink markup resolves against when painted: the theme's tokens and
/// blend mode, the current color, textures and state effects.
class InkPaintContext {
  InkPaintContext({
    required this.theme,
    Color? currentColor,
    InkTextures? textures,
    this.state = InkStateEffects.none,
  }) : currentColor = currentColor ?? theme.colors.ink,
       textures = textures ?? InkTextures.instance;

  final LooseleafThemeData theme;
  final Color currentColor;
  final InkTextures textures;
  final InkStateEffects state;

  LooseleafColors get colors => theme.colors;

  /// A numeric `--ll-*` variable.
  double? scalar(String token) => theme.scalar(token);

  /// Identifies the inputs rendered pattern tiles depend on.
  Object get paintKey => (theme.colors, currentColor);
}
