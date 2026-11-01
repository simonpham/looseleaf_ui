import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A card's supporting line: small, in muted ink.
///
/// Mirrors `CardDescription` in upstream `src/components/ui/card.tsx`.
class CardDescription extends StatelessWidget {
  const CardDescription(this.child, {super.key});

  /// The description.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkMuted,
      ),
      child: child,
    );
  }
}
