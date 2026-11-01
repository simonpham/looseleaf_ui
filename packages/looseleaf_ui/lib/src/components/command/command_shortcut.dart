import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/kbd/kbd.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row's keyboard shortcut at its end: [keys] on a keycap, or any
/// [child], in small muted type.
///
/// Mirrors `CommandShortcut` in upstream `src/components/ui/command.tsx`.
class CommandShortcut extends StatelessWidget {
  /// A keycap reading [keys].
  const CommandShortcut(String this.keys, {super.key}) : child = null;

  /// A shortcut of your own widgets.
  const CommandShortcut.custom({super.key, required Widget this.child})
    : keys = null;

  /// The keycap's text.
  final String? keys;

  /// The custom content.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: CommandMetrics.small(theme),
      child: switch ((keys, child)) {
        (final text?, _) => Kbd(child: Text(text)),
        (_, final custom?) => custom,
        _ => const SizedBox.shrink(),
      },
    );
  }
}
