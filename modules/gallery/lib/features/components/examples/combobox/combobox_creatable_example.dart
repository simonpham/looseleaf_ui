import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxCreatableExample extends StatefulWidget {
  const ComboboxCreatableExample({super.key});

  @override
  State<ComboboxCreatableExample> createState() =>
      _ComboboxCreatableExampleState();
}

class _ComboboxCreatableExampleState extends State<ComboboxCreatableExample> {
  List<String> _breads = const ['Sourdough', 'Focaccia', 'Rye', 'Brioche'];
  String? _value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.d256,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        const Label(child: Text('Bread')),
        Combobox(
          items: [for (final bread in _breads) ComboboxItemData.of(bread)],
          value: _value,
          onChanged: (value) => setState(() => _value = value),
          label: 'Bread',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ComboboxTrigger(
                semanticLabel: 'Bread',
                child: ComboboxValue(placeholder: 'Pick or add a bread...'),
              ),
              ComboboxContent(
                children: [
                  const ComboboxInput(placeholder: 'Search or add...'),
                  ComboboxList(
                    children: [
                      const ComboboxEmpty(child: Text('No bread yet.')),
                      for (final bread in _breads)
                        ComboboxItem(value: bread, child: Text(bread)),
                      ComboboxCreate(
                        onCreate: (text) =>
                            setState(() => _breads = [..._breads, text]),
                        builder: (context, text) => Text('Add "$text"'),
                      ),
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
