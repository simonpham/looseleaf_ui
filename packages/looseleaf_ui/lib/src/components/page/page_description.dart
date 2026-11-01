import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page's standfirst: body size, in muted ink.
///
/// Mirrors `PageDescription` in upstream `src/components/ui/page.tsx`.
class PageDescription extends StatelessWidget {
  const PageDescription(this.child, {super.key});

  /// The description.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 16,
        cssLineHeight: 1.5,
        color: theme.colors.inkMuted,
      ),
      child: child,
    );
  }
}
