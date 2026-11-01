import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The explanation of an [Empty]: small muted text with relaxed leading.
///
/// Mirrors `EmptyDescription` in upstream `src/components/ui/empty.tsx`.
class EmptyDescription extends StatelessWidget {
  const EmptyDescription({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 1.625,
        color: theme.colors.inkMuted,
      ),
      child: child,
    );
  }
}
