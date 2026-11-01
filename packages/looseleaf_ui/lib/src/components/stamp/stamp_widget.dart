import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';

/// A rubber stamp impression: a framed box, a round seal with rim
/// lettering, a twelve-point burst or big slanted letters, in typewriter
/// capitals pressed through a worn pad and tilted a few degrees.
///
/// [name] starts from a preset in [stickers] (`stamp-approved`,
/// `stamp-draft`, `stamp-paid`, `stamp-urgent`, …); every other prop
/// overrides it. Without [text] or a preset there is nothing to stamp, and
/// nothing shows. [size] sets both [w] and [h]. The impression is an image
/// named by its words.
///
/// ```dart
/// const Stamp(name: 'stamp-approved')
/// const Stamp(text: 'Received', sub: 'Mar 14 2026', ink: StampPadInk.inkYou)
/// const Stamp(text: 'New', shape: StampShape.burst, size: 96)
/// ```
///
/// Mirrors upstream `src/components/ui/stamp.tsx`.
class Stamp extends StatelessWidget {
  const Stamp({
    super.key,
    this.name,
    this.text,
    this.shape,
    this.ink,
    this.sub,
    this.ring,
    this.w,
    this.h,
    this.size,
    this.tilt,
    this.ghost,
    this.dashed,
    this.seed,
    this.semanticLabel,
  });

  /// A stamp preset's name in [stickers].
  final String? name;

  /// The words; the preset's when null.
  final String? text;

  /// The outline; the preset's, else [StampShape.rect].
  final StampShape? shape;

  /// The pad ink; the preset's, else red.
  final StampPadInk? ink;

  /// A second, smaller line.
  final String? sub;

  /// Lettering around the rim of a round stamp.
  final String? ring;

  /// The width in pixels.
  final double? w;

  /// The height in pixels.
  final double? h;

  /// Both [w] and [h].
  final double? size;

  /// The tilt in degrees; seeded when null.
  final double? tilt;

  /// A faint second impression beside the first.
  final bool? ghost;

  /// A dashed inner frame.
  final bool? dashed;

  /// Pins the impression; the name, else the text, when null.
  final String? seed;

  /// The accessible name; the words when null.
  final String? semanticLabel;

  /// The preset [name] points at, when it is a stamp.
  StampGen? get preset => switch (stickers[name]) {
    final StampGen gen => gen,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final preset = this.preset;
    final words = text ?? preset?.text;
    if (words == null) return const SizedBox.shrink();
    final base = preset?.opts;
    final outline = shape ?? preset?.shape ?? StampShape.rect;
    final opts = StampOpts(
      ink: ink ?? base?.ink,
      sub: sub ?? base?.sub,
      ring: ring ?? base?.ring,
      w: size ?? w ?? base?.w,
      h: size ?? h ?? base?.h,
      tilt: tilt ?? base?.tilt,
      ghost: ghost ?? base?.ghost,
      dashed: dashed ?? base?.dashed,
      stars: base?.stars,
      wear: base?.wear,
      seed: seed ?? name ?? words,
    );
    return InkArt(
      cacheKey: [
        'stamp',
        words,
        outline.id,
        opts.ink?.name,
        opts.sub,
        opts.ring,
        opts.w,
        opts.h,
        opts.tilt,
        opts.ghost,
        opts.dashed,
        opts.stars,
        opts.wear,
        opts.seed,
      ].join('|'),
      draw: () => stamp(words, outline, opts),
      semanticLabel: semanticLabel ?? words,
    );
  }
}
