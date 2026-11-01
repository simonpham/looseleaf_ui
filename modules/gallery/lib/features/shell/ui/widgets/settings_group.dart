import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A labelled group of settings in the display settings popover.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Text(
          label,
          style: theme.typography.stamp(
            cssSize: 12,
            color: theme.colors.inkMuted,
          ),
        ),
        child,
      ],
    );
  }
}
