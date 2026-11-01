import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/spinner/spinner.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row of looping pencil and a line while results are on their way;
/// show it while you fetch.
///
/// Mirrors `CommandLoading` in upstream `src/components/ui/command.tsx`.
class CommandLoading extends StatelessWidget {
  const CommandLoading({super.key, required this.child});

  /// The message, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.d16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: Spacing.d8,
          children: [
            const Spinner(variant: SpinnerVariant.loops, size: Spacing.d14),
            DefaultTextStyle.merge(
              style: CommandMetrics.small(theme),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
