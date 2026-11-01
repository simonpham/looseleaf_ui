import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sketched disc at the end of an [AvatarGroup] for everyone who did
/// not fit: text such as "+3", or an icon.
///
/// Mirrors `AvatarGroupCount` in upstream `src/components/ui/avatar.tsx`.
class AvatarGroupCount extends StatefulWidget {
  const AvatarGroupCount({super.key, required this.child, this.seed});

  final Widget child;

  /// Pins the hand: the same seed always draws the same disc.
  final String? seed;

  @override
  State<AvatarGroupCount> createState() => _AvatarGroupCountState();
}

class _AvatarGroupCountState extends State<AvatarGroupCount> with InkSeed {
  static final _source = RecipeInkSource(
    avatarCountRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final group = AvatarGroupScope.maybeOf(context);
    final size = group?.size ?? AvatarSize.regular;
    final theme = LooseleafTheme.of(context);
    final small = size == AvatarSize.sm;
    return AvatarCut(
      color: group?.cut ?? theme.colors.paper,
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: switch (small) {
            true => 12,
            false => 14,
          },
          cssLineHeight: switch (small) {
            true => 16 / 12,
            false => 20 / 14,
          },
          fontWeight: FontWeight.w700,
          color: theme.colors.inkSoft,
        ),
        iconSize: size.countIcon,
        wrap: false,
        child: InkSurface(
          source: _source,
          seed: inkSeed(widget.seed),
          still: true,
          child: SizedBox.square(
            dimension: size.dimension,
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
