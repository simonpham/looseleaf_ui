import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The handwriting on a hover card's margin: the script face, 22 px, set
/// tight, 10 px under the media and 4 px in from the sides.
///
/// Mirrors `HoverCardCaption` in upstream `src/components/ui/hover-card.tsx`.
class HoverCardCaption extends StatelessWidget {
  const HoverCardCaption(this.child, {super.key});

  /// The caption.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: Spacing.d10,
        left: Spacing.d4,
        right: Spacing.d4,
      ),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 22.4,
          cssLineHeight: 1.25,
          color: theme.colors.ink,
        ),
        child: child,
      ),
    );
  }
}
