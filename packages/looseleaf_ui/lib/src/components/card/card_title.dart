import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A card's title in the script face, 27 px, set solid.
///
/// Mirrors `CardTitle` in upstream `src/components/ui/card.tsx`.
class CardTitle extends StatelessWidget {
  const CardTitle(this.child, {super.key});

  /// The title.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 27.2,
        cssLineHeight: 1,
        fontWeight: FontWeight.w600,
      ),
      child: Semantics(container: true, header: true, child: child),
    );
  }
}
