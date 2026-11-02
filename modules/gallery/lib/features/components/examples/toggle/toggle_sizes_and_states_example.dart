import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleSizesAndStatesExample extends StatelessWidget {
  const ToggleSizesAndStatesExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.sm,
            defaultValue: true,
            semanticLabel: 'List, small',
            child: InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            defaultValue: true,
            semanticLabel: 'List',
            child: InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.lg,
            defaultValue: true,
            semanticLabel: 'List, large',
            child: InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.lg,
            tone: ToggleTone.marker,
            defaultValue: true,
            leading: InkIcon('pencil'),
            child: Text('Draw'),
          ),
        ],
      ),
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Toggle(
            value: false,
            disabled: true,
            leading: InkIcon('eye-off'),
            child: Text('Hidden'),
          ),
          Toggle(
            value: true,
            disabled: true,
            leading: InkIcon('eye-off'),
            child: Text('Hidden'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            value: false,
            disabled: true,
            child: Text('Locked'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            value: true,
            disabled: true,
            child: Text('Locked'),
          ),
        ],
      ),
    ],
  );
}
