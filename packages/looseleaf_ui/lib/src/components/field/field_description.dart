import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Help under (or beside) a field's control: small, in muted ink.
///
/// Mirrors `FieldDescription` in upstream `src/components/ui/field.tsx`
/// (`text-sm leading-normal text-muted-foreground`).
class FieldDescription extends StatelessWidget {
  const FieldDescription(this.child, {super.key});

  /// The help, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 1.5,
        color: theme.colors.inkMuted,
      ),
      child: child,
    );
  }
}
