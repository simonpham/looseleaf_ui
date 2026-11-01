import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A popover's title in the script face, 22 px, set solid.
///
/// Mirrors `PopoverTitle` in upstream `src/components/ui/popover.tsx`.
class PopoverTitle extends StatelessWidget {
  const PopoverTitle(this.child, {super.key});

  /// The title.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 22.4,
        cssLineHeight: 1,
        fontWeight: FontWeight.w600,
      ),
      child: Semantics(container: true, header: true, child: child),
    );
  }
}
