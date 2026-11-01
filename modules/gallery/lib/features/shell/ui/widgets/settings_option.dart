import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A radio choice with a hint under its label, upstream `Option` in
/// `src/docs/shell/SettingsMenu.tsx`.
class SettingsOption<T> extends StatelessWidget {
  const SettingsOption({
    super.key,
    required this.value,
    required this.label,
    required this.hint,
  });

  final T value;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return RadioGroupItem<T>(
      value: value,
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d2,
        children: [
          Text(label, style: theme.typography.label()),
          Text(
            hint,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 1.375,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
