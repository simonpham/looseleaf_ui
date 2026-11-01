import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Help under a field's control: small, in muted ink.
///
/// Mirrors `FormDescription` in upstream `src/components/ui/form.tsx`
/// (`text-sm text-muted-foreground`).
class FormDescription extends StatelessWidget {
  const FormDescription(this.child, {super.key});

  /// The help, usually a [Text].
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
