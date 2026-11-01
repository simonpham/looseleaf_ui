import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Faces that overlap (every member is the group's [size] square), each cut out of the last by a paper-colored ring;
/// end it with an [AvatarGroupCount] for everyone who did not fit.
///
/// ```dart
/// AvatarGroup(children: [
///   Avatar(children: [AvatarFallback(name: 'Ada Lovelace')]),
///   Avatar(children: [AvatarFallback(name: 'Jo Okafor')]),
///   AvatarGroupCount(child: Text('+3')),
/// ])
/// ```
///
/// Mirrors `AvatarGroup` in upstream `src/components/ui/avatar.tsx`.
class AvatarGroup extends StatelessWidget {
  const AvatarGroup({
    super.key,
    required this.children,
    this.size = AvatarSize.regular,
    this.cut,
  });

  final List<Widget> children;

  /// The size of every avatar and the count, and how far they overlap.
  final AvatarSize size;

  /// The cut-out ring's color (`--ll-avatar-group-ring`); the card's paper
  /// when null.
  final Color? cut;

  @override
  Widget build(BuildContext context) {
    final side = size.dimension;
    final step = side - size.overlap;
    return AvatarGroupScope(
      size: size,
      cut: cut ?? LooseleafTheme.of(context).colors.paper,
      child: SizedBox(
        width: switch (children.length) {
          0 => 0,
          final count => side + (count - 1) * step,
        },
        height: side,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (index, child) in children.indexed)
              PositionedDirectional(
                start: index * step,
                top: 0,
                width: side,
                height: side,
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}
