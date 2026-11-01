import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A napkin's title in the script face, 32 px bold, leading none.
///
/// Mirrors `NapkinTitle` in upstream `src/components/ui/napkin.tsx`.
class NapkinTitle extends StatelessWidget {
  const NapkinTitle(this.child, {super.key});

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
          cssSize: 32,
          cssLineHeight: 1,
          fontWeight: FontWeight.w700,
          color: theme.colors.ink,
        ),
        child: child,
      ),
    );
  }
}
