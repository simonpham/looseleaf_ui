import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxFrameworkExample extends StatefulWidget {
  const ComboboxFrameworkExample({super.key});

  @override
  State<ComboboxFrameworkExample> createState() =>
      _ComboboxFrameworkExampleState();
}

class _ComboboxFrameworkExampleState extends State<ComboboxFrameworkExample> {
  static const _frameworks = [
    ComboboxItemData(value: 'next', label: 'Next.js'),
    ComboboxItemData(value: 'sveltekit', label: 'SvelteKit'),
    ComboboxItemData(value: 'nuxt', label: 'Nuxt.js'),
    ComboboxItemData(value: 'remix', label: 'Remix'),
    ComboboxItemData(value: 'astro', label: 'Astro'),
  ];

  String? _value = 'next';

  @override
  Widget build(BuildContext context) => Combobox(
    items: _frameworks,
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    label: 'Framework',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: Spacing.d256,
          child: ComboboxTrigger(
            semanticLabel: 'Framework',
            child: ComboboxValue(placeholder: 'Select framework...'),
          ),
        ),
        ComboboxContent(
          children: [
            const ComboboxInput(placeholder: 'Search framework...'),
            ComboboxList(
              children: [
                const ComboboxEmpty(child: Text('No framework found.')),
                ComboboxGroup(
                  children: [
                    for (final framework in _frameworks)
                      ComboboxItem(
                        value: framework.value,
                        child: Text(framework.label),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
