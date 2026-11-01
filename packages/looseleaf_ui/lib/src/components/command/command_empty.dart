import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/mascot/mascot.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What the palette says when no row matches: Stubby with his magnifier
/// over a script line. Shown only while nothing is shown.
///
/// Mirrors `CommandEmpty` in upstream `src/components/ui/command.tsx`.
class CommandEmpty extends StatelessWidget {
  const CommandEmpty({super.key, required this.child, this.mascot = true});

  /// The message, usually a [Text].
  final Widget child;

  /// Shows Stubby searching above the message.
  final bool mascot;

  @override
  Widget build(BuildContext context) {
    if (CommandScope.of(context).count > 0) return const SizedBox.shrink();
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
              style: CommandMetrics.empty(theme),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
