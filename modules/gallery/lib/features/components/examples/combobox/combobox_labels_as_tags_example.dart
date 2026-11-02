import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxLabelsAsTagsExample extends StatefulWidget {
  const ComboboxLabelsAsTagsExample({super.key});

  @override
  State<ComboboxLabelsAsTagsExample> createState() =>
      _ComboboxLabelsAsTagsExampleState();
}

class _ComboboxLabelsAsTagsExampleState
    extends State<ComboboxLabelsAsTagsExample> {
  static const _labels = [
    'Design',
    'Garden',
    'Travel',
    'Recipes',
    'Field notes',
    'Ideas',
    'Reading',
    'Music',
  ];

  List<String> _values = const ['Design', 'Garden', 'Travel'];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.d384,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        const Label(child: Text('Labels')),
        Combobox.multiple(
          items: [for (final label in _labels) ComboboxItemData.of(label)],
          values: _values,
          onValuesChanged: (values) => setState(() => _values = values),
          label: 'Labels',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ComboboxChips(
                autoTone: true,
                child: ComboboxChipsInput(
                  placeholder: switch (_values.isEmpty) {
                    true => 'Add a label...',
                    false => '',
                  },
                ),
              ),
              ComboboxContent(
                children: [
                  ComboboxList(
                    children: [
                      const ComboboxEmpty(child: Text('No label like that.')),
                      for (final label in _labels)
                        ComboboxItem(value: label, child: Text(label)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
