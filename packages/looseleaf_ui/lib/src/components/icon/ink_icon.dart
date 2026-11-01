import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/icon/icon_flip.dart';
import 'package:looseleaf_ui/src/components/icon/icon_missing.dart';

/// A hand-drawn icon from the 160 in the engine's catalog, redrawn (not
/// scaled) for its size: 12 px is one confident stroke, 48 px gets extras.
///
/// [name] takes the catalog id (`arrow-right`), and the Lucide spellings
/// shadcn snippets use (`ArrowRight`, `LucideArrowRight`, `ArrowRightIcon`,
/// old names like `alert-triangle`). An unknown name draws a boxed `?`.
///
/// Size comes from [size], else the ambient [IconTheme] (a `Button` sets
/// 16), else 16. In the `ui` tone the ink is the ambient icon or text color
/// (`currentColor`); [ArtTone.doodle] shows the accent wash.
///
/// Named `InkIcon` so it sits beside Flutter's own `Icon`.
///
/// ```dart
/// const InkIcon('search')
/// const InkIcon('bell', size: 32, tone: ArtTone.doodle, accent: ArtAccent.sky)
/// ```
///
/// Mirrors upstream `src/components/ui/icon.tsx`.
class InkIcon extends StatelessWidget {
  const InkIcon(
    this.name, {
    super.key,
    this.size,
    this.tone = ArtTone.ui,
    this.accent,
    this.seed,
    this.semanticLabel,
    this.flip = IconFlip.none,
    this.weight,
    this.color,
  });

  /// The icon id or a Lucide name.
  final String name;

  /// The size in pixels, at least 8; see the class docs for the default.
  final double? size;

  /// `ui` draws ink only; `doodle` adds the icon's accent wash.
  final ArtTone tone;

  /// The accent over the icon's own, in the doodle tone.
  final ArtAccent? accent;

  /// Pins the hand; the icon id when null, so an icon looks the same
  /// everywhere.
  final String? seed;

  /// Names the icon for screen readers; decorative when null. Name the
  /// control instead when the icon sits in one.
  final String? semanticLabel;

  /// Mirrors icons that allow it (arrows, hands).
  final IconFlip flip;

  /// The nib weight factor; small `ui` icons default to 1.12.
  final double? weight;

  /// The ink color over the ambient one.
  final Color? color;

  static const double _uiWeight = 1.12;
  static const double _uiWeightMaxPx = 20;
  static const double _fallbackSize = 16;

  /// The resolved catalog id of [name].
  String get id => resolveIconName(name);

  /// Whether [name] is in the catalog.
  bool get known => icons.containsKey(id);

  static double _nib(ArtDef def, double px) =>
      math.min(3.4, math.max(1.45, px * (def.nibK ?? 0.068)));

  @override
  Widget build(BuildContext context) {
    final id = this.id;
    final def = icons[id] ?? missingIcon;
    final ambient = context
        .dependOnInheritedWidgetOfExactType<IconTheme>()
        ?.data
        .size;
    final px = math
        .max(8, JsMath.roundInt(size ?? ambient ?? _fallbackSize))
        .toDouble();
    final small = tone == ArtTone.ui && px <= _uiWeightMaxPx;
    final k =
        weight ??
        switch (small) {
          true => _uiWeight,
          false => 1.0,
        };
    final nib = switch (k == 1) {
      true => null,
      false => _nib(def, px) * k,
    };
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final mirror = def.mirror ?? false;
    return InkArt(
      cacheKey:
          'icon|$id|${JsMath.numberToString(px)}|${tone.name}|'
          '${accent?.name ?? ''}|${seed ?? ''}|${JsMath.numberToString(k)}',
      draw: () => drawSkeleton(
        def,
        px,
        seed ?? id,
        DrawOpts(tone: tone, accent: accent, kind: ArtKind.icon, nib: nib),
      ).result,
      size: Size.square(px),
      color: color,
      semanticLabel: semanticLabel,
      flipX: (def.rtlFlip && rtl) || (mirror && flip == IconFlip.x),
      flipY: mirror && flip == IconFlip.y,
    );
  }
}
