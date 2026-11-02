import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A person: a picture circled by hand, with initials on a marker disc
/// while there is none.
///
/// Stack the parts in [children]: an [AvatarImage], an [AvatarFallback]
/// (shown until the image loads, and when it fails) and an [AvatarBadge].
///
/// ```dart
/// Avatar(children: [
///   AvatarImage(image: NetworkImage(url)),
///   AvatarFallback(name: 'Jo Okafor'),
///   AvatarBadge(status: AvatarStatus.online),
/// ])
/// ```
///
/// Mirrors `Avatar` in upstream `src/components/ui/avatar.tsx`.
class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    required this.children,
    this.size,
    this.dimension,
    this.ring = AvatarRing.ink,
    this.seed,
  });

  final List<Widget> children;

  /// The size; null takes the [AvatarGroup]'s, else [AvatarSize.regular].
  final AvatarSize? size;

  /// The avatar's side when no [size] fits, like upstream's `size-12`
  /// class; the initials and badge keep [size]'s metrics.
  final double? dimension;

  /// The hand-drawn ring; null draws none (upstream `ring="none"`).
  final AvatarRing? ring;

  /// Pins the hand: the same seed always draws the same ring.
  final String? seed;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> with InkSeed {
  bool _loaded = false;

  void _onLoaded(bool loaded) {
    if (_loaded == loaded) return;
    setState(() => _loaded = loaded);
  }

  @override
  Widget build(BuildContext context) {
    final group = AvatarGroupScope.maybeOf(context);
    final size = widget.size ?? group?.size ?? AvatarSize.regular;
    final ring = widget.ring;
    return AvatarScope(
      size: size,
      loaded: _loaded,
      onLoaded: _onLoaded,
      child: AvatarCut(
        color: group?.cut,
        child: SizedBox.square(
          dimension: widget.dimension ?? size.dimension,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              ...widget.children.where((child) => child is! AvatarBadge),
              if (ring != null) IgnorePointer(child: _ring(ring)),
              ...widget.children.whereType<AvatarBadge>(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(AvatarRing ring) {
    final params = AvatarRingParams(ring: ring);
    return InkSurface(
      source: RecipeInkSource(avatarRingRecipe, params, json: params.toJson()),
      seed: inkSeed(widget.seed),
      still: true,
    );
  }
}

/// The 2 px ring in [color] that cuts an avatar out of the one before it
/// in a group (upstream `CUT`, a box shadow); nothing when [color] is null.
class AvatarCut extends StatelessWidget {
  const AvatarCut({super.key, required this.color, required this.child});

  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cut = color;
    if (cut == null) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: cut, spreadRadius: Spacing.d2)],
      ),
      child: child,
    );
  }
}
