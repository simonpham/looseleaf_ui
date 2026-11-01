import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/doodle/doodle.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/mascot/mascot.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// How [EmptyMedia] presents its picture.
enum EmptyMediaVariant {
  /// As it is.
  regular,

  /// On a 44 px slip of paper with a hatched shadow; icons are 24.
  icon,
}

/// The picture of an [Empty]: Stubby in a [pose], a [doodle], or any
/// [child] (an icon on a paper slip with [EmptyMediaVariant.icon]).
/// Decorative: the title carries the meaning.
///
/// Mirrors `EmptyMedia` in upstream `src/components/ui/empty.tsx`.
class EmptyMedia extends StatefulWidget {
  const EmptyMedia({
    super.key,
    this.variant = EmptyMediaVariant.regular,
    this.pose,
    this.doodle,
    this.size,
    this.seed,
    this.child,
  });

  final EmptyMediaVariant variant;

  /// A Stubby pose (`search`, `sleep`, `unplug`, …), drawn 96 big.
  final String? pose;

  /// A doodle name, drawn 80 big.
  final String? doodle;

  /// The mascot's or doodle's size.
  final double? size;

  /// Pins the hand of the slip, the mascot and the doodle.
  final String? seed;

  final Widget? child;

  @override
  State<EmptyMedia> createState() => _EmptyMediaState();
}

class _EmptyMediaState extends State<EmptyMedia> with InkSeed {
  static final _tile = RecipeInkSource(
    emptyMediaRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final pose = widget.pose;
    final doodle = widget.doodle;
    final content = <Widget>[
      if (pose != null)
        Mascot(
          pose: pose,
          size: widget.size ?? Mascot.defaultSize,
          seed: widget.seed,
        ),
      if (doodle != null)
        Doodle(doodle, size: widget.size ?? _doodleSize, seed: widget.seed),
      ?widget.child,
    ];
    final media = switch (content.length) {
      1 => content.single,
      _ => Row(mainAxisSize: MainAxisSize.min, children: content),
    };
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.d8),
        child: switch (widget.variant) {
          EmptyMediaVariant.regular => media,
          EmptyMediaVariant.icon => _slip(context, media),
        },
      ),
    );
  }

  /// `size={size ?? 80}` for doodles.
  static const double _doodleSize = 80;

  Widget _slip(BuildContext context, Widget media) {
    final theme = LooseleafTheme.of(context);
    return InkContent(
      style: TextStyle(color: theme.colors.ink),
      iconSize: Spacing.d24,
      child: InkSurface(
        source: _tile,
        seed: inkSeed(widget.seed),
        still: true,
        child: SizedBox.square(
          dimension: Spacing.d44,
          child: Center(child: media),
        ),
      ),
    );
  }
}
