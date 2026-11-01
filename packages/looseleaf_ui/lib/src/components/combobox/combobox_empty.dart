import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/mascot/mascot.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What the list says when the search matches nothing: Stubby with a
/// magnifier over a script line. Hidden while the combobox is loading.
///
/// Mirrors `ComboboxEmpty` in upstream `src/components/ui/combobox.tsx`
/// (`CommandEmpty`).
class ComboboxEmpty extends StatelessWidget {
  const ComboboxEmpty({super.key, required this.child, this.mascot = true});

  /// The message, usually a [Text].
  final Widget child;

  /// Shows Stubby searching above the message.
  final bool mascot;

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    if (controller.loading || controller.hasResults) {
      return const SizedBox.shrink();
    }
    final theme = LooseleafTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d16,
          vertical: Spacing.d20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d4,
          children: [
            if (mascot) const Mascot(pose: 'search', size: Spacing.d64),
            DefaultTextStyle.merge(
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 20,
                cssLineHeight: 1.25,
                color: theme.colors.inkMuted,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
