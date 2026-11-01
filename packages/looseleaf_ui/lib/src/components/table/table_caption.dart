import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The line under an [InkTable] saying what it holds: muted script, 16
/// below the table.
///
/// Mirrors `TableCaption` in upstream `src/components/ui/table.tsx`.
class TableCaption extends StatelessWidget {
  const TableCaption({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d16),
      child: DefaultTextStyle.merge(
        textAlign: TextAlign.center,
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 18,
          cssLineHeight: 28 / 18,
          color: theme.colors.inkMuted,
        ),
        child: child,
      ),
    );
  }
}
