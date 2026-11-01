import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The title of an [Empty], in script.
///
/// Mirrors `EmptyTitle` in upstream `src/components/ui/empty.tsx`.
class EmptyTitle extends StatelessWidget {
  const EmptyTitle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      header: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 26.4,
          cssLineHeight: 1,
          fontWeight: FontWeight.w600,
          color: theme.colors.ink,
        ),
        child: child,
      ),
    );
  }
}
