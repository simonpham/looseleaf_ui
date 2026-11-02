import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupSpacingExample extends StatefulWidget {
  const ToggleGroupSpacingExample({super.key});

  @override
  State<ToggleGroupSpacingExample> createState() =>
      _ToggleGroupSpacingExampleState();
}

class _ToggleGroupSpacingExampleState extends State<ToggleGroupSpacingExample> {
  var _value = <String>{};

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final reactions = [
      ('star', 'Star', colors.orangeText),
      ('heart', 'Heart', colors.red),
      ('bookmark', 'Bookmark', colors.inkYou),
    ];
    return ToggleGroup<String>(
      type: ToggleGroupType.multiple,
      variant: ToggleVariant.outline,
      spacing: Spacing.d8,
      size: ToggleSize.sm,
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      semanticLabel: 'Reactions',
      children: [
        for (final (icon, label, color) in reactions)
          ToggleGroupItem(
            value: icon,
            semanticLabel: 'Toggle $icon',
            leading: InkIcon(
              icon,
              color: switch (_value.contains(icon)) {
                true => color,
                false => null,
              },
            ),
            child: Text(label),
          ),
      ],
    );
  }
}
