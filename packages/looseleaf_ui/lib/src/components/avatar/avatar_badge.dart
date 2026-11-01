import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A status dot on an [Avatar]'s bottom end corner: online, away, busy,
/// offline or marker. A small icon may sit in it (not at [AvatarSize.sm]).
///
/// Mirrors `AvatarBadge` in upstream `src/components/ui/avatar.tsx`.
class AvatarBadge extends StatefulWidget {
  const AvatarBadge({
    super.key,
    this.status = AvatarStatus.marker,
    this.seed,
    this.child,
    this.semanticLabel,
  });

  final AvatarStatus status;

  /// Pins the hand: the same seed always draws the same dot.
  final String? seed;

  /// An icon in the dot.
  final Widget? child;

  /// Reads the status out, such as "Online".
  final String? semanticLabel;

  @override
  State<AvatarBadge> createState() => _AvatarBadgeState();
}

class _AvatarBadgeState extends State<AvatarBadge> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final size = AvatarScope.maybeOf(context)?.size ?? AvatarSize.regular;
    final params = AvatarBadgeParams(status: widget.status);
    final theme = LooseleafTheme.of(context);
    final icon = size.badgeIcon;
    return PositionedDirectional(
      end: 0,
      bottom: 0,
      width: size.badge,
      height: size.badge,
      child: Semantics(
        label: widget.semanticLabel,
        child: InkContent(
          style: TextStyle(color: theme.colors.ink),
          iconSize: icon,
          child: InkSurface(
            source: RecipeInkSource(
              avatarBadgeRecipe,
              params,
              json: params.toJson(),
            ),
            seed: inkSeed(widget.seed),
            still: true,
            child: Center(
              child: switch (icon) {
                null => null,
                _ => widget.child,
              },
            ),
          ),
        ),
      ),
    );
  }
}
