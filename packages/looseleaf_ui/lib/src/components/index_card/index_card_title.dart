import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An index card's title in the script face, 26.4 px bold, leading none,
/// on one line sitting on the red rule; a longer title ends in an ellipsis.
///
/// Mirrors `IndexCardTitle` in upstream `src/components/ui/index-card.tsx`.
class IndexCardTitle extends StatelessWidget {
  const IndexCardTitle(this.child, {super.key});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      header: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 26.4,
          cssLineHeight: 1,
          fontWeight: FontWeight.w700,
          color: theme.colors.ink,
        ),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: child,
      ),
    );
  }
}
