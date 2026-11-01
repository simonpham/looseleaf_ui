import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A popover's supporting line, in muted ink.
///
/// Mirrors `PopoverDescription` in upstream `src/components/ui/popover.tsx`.
class PopoverDescription extends StatelessWidget {
  const PopoverDescription(this.child, {super.key});

  /// The description.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: TextStyle(color: theme.colors.inkMuted),
      child: child,
    );
  }
}
