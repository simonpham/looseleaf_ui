import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Small soft-ink text at the foot of a napkin.
///
/// Mirrors `NapkinFooter` in upstream `src/components/ui/napkin.tsx`.
class NapkinFooter extends StatelessWidget {
  const NapkinFooter(this.child, {super.key});

  /// The footer, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkSoft,
      ),
      child: child,
    );
  }
}
