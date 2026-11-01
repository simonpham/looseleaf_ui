import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Plain graphite words in an [InputGroupAddon]: a unit, a prefix, a
/// counter. 15 px Kevin Sans Hand, bold like its addon.
///
/// Mirrors `InputGroupText` in upstream `src/components/ui/input-group.tsx`.
class InputGroupText extends StatelessWidget {
  const InputGroupText({super.key, required this.child});

  /// The words, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final disabled = InputGroupScope.maybeOf(context)?.disabled ?? false;
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        fontWeight:
            DefaultTextStyle.of(context).style.fontWeight ?? FontWeight.w400,
        color: switch (disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.inkMuted,
        },
      ),
      iconSize: Spacing.d16,
      child: child,
    );
  }
}
