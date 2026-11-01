import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What an [Avatar] shows without a picture: initials on a marker disc
/// whose color is chosen from the [name], so a name always gets the same
/// one. Hidden once the [AvatarImage] has loaded.
///
/// Mirrors `AvatarFallback` in upstream `src/components/ui/avatar.tsx`.
class AvatarFallback extends StatelessWidget {
  const AvatarFallback({
    super.key,
    this.name,
    this.tone,
    this.seed,
    this.child,
  });

  /// The person's name: picks the tone and the initials, and is read out.
  final String? name;

  /// The disc's marker, over the one picked from [name].
  final AvatarTone? tone;

  /// Pins the hand; the [name] when null.
  final String? seed;

  /// Content instead of the initials (an icon, other text).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = AvatarScope.maybeOf(context);
    if (scope?.loaded ?? false) return const SizedBox.shrink();
    final size = scope?.size ?? AvatarSize.regular;
    final basis = name ?? '';
    final params = AvatarFallbackParams(tone: tone ?? avatarTone(basis));
    final theme = LooseleafTheme.of(context);
    final content = switch ((child, name)) {
      (final Widget content, _) => content,
      (null, final String named) => Semantics(
        label: named,
        child: ExcludeSemantics(child: Text(avatarInitials(named))),
      ),
      (null, null) => const SizedBox.shrink(),
    };
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: size.cssFontSize,
        cssLineHeight: size.cssLineHeight,
        fontWeight: FontWeight.w700,
        color: theme.colors.ink,
      ),
      wrap: false,
      child: _FallbackDisc(
        source: RecipeInkSource(
          avatarFallbackRecipe,
          params,
          json: params.toJson(),
        ),
        seed: seed ?? name,
        child: Center(child: content),
      ),
    );
  }
}

class _FallbackDisc extends StatefulWidget {
  const _FallbackDisc({
    required this.source,
    required this.seed,
    required this.child,
  });

  final InkSource source;
  final String? seed;
  final Widget child;

  @override
  State<_FallbackDisc> createState() => _FallbackDiscState();
}

class _FallbackDiscState extends State<_FallbackDisc> with InkSeed {
  @override
  Widget build(BuildContext context) => InkSurface(
    source: widget.source,
    seed: inkSeed(switch (widget.seed) {
      '' => null,
      final seed => seed,
    }),
    still: true,
    child: widget.child,
  );
}
