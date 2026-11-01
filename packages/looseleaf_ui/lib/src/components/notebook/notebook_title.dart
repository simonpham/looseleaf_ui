import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/notebook/notebook_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A notebook page's heading in the script face, 28 px bold and one ruled
/// line high. The script sits lower in its line than the body face, so the
/// heading is lifted by the rule offset less about 3 px to stand on its
/// rule.
///
/// Mirrors `NotebookTitle` in upstream `src/components/ui/notebook.tsx`.
class NotebookTitle extends StatelessWidget {
  const NotebookTitle(this.child, {super.key});

  /// `top: calc(2.8px - var(--ll-rule-offset))`, the same 5.2 px for the
  /// 28, 24 and 30 px rhythms.
  static const double lift = 5.2;

  /// The heading, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final line = NotebookScope.maybeOf(context)?.lineHeight ?? Spacing.d28;
    return Semantics(
      container: true,
      header: true,
      child: Transform.translate(
        offset: const Offset(0, -lift),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: 28,
            cssLineHeight: line / 28,
            fontWeight: FontWeight.w700,
            color: theme.colors.ink,
          ),
          child: child,
        ),
      ),
    );
  }
}
