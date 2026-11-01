import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_affine.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_scalar.dart';

/// How an element's blend mode is given.
enum InkBlend {
  /// No `mix-blend-mode`.
  none,

  /// `mix-blend-mode:var(--ll-blend)`: the theme's blend mode.
  theme,

  /// A literal mode, in [InkEffects.blendMode].
  literal,
}

/// The non-inherited attributes of one element: its transform, opacity,
/// clip, mask, blend, and the data attributes state layers read.
class InkEffects {
  const InkEffects({
    this.transform,
    this.opacity,
    this.clipPathId,
    this.maskId,
    this.blend = InkBlend.none,
    this.blendMode = BlendMode.srcOver,
    this.part,
    this.misregister = Offset.zero,
    this.hideOn = const {},
  });

  final InkAffine? transform;
  final InkScalar? opacity;
  final String? clipPathId;
  final String? maskId;
  final InkBlend blend;
  final BlendMode blendMode;

  /// `data-part`: `fill` parts shift by [misregister] on hover and press.
  final String? part;

  /// The `--mx` / `--my` offsets of a part.
  final Offset misregister;

  /// `data-hide-on`: states that fade this element out.
  final Set<String> hideOn;

  static const InkEffects none = InkEffects();

  /// Whether painting needs an offscreen layer (opacity, mask or blend).
  bool get needsLayer =>
      opacity != null || maskId != null || blend != InkBlend.none;
}
