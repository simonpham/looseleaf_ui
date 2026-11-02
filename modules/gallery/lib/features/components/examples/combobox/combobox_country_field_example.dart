import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxCountryFieldExample extends StatefulWidget {
  const ComboboxCountryFieldExample({super.key});

  @override
  State<ComboboxCountryFieldExample> createState() =>
      _ComboboxCountryFieldExampleState();
}

class _ComboboxCountryFieldExampleState
    extends State<ComboboxCountryFieldExample> {
  static const _countries = [
    ComboboxItemData(value: 'ar', label: 'Argentina'),
    ComboboxItemData(value: 'au', label: 'Australia'),
    ComboboxItemData(value: 'br', label: 'Brazil'),
    ComboboxItemData(value: 'ca', label: 'Canada'),
    ComboboxItemData(value: 'fr', label: 'France'),
    ComboboxItemData(value: 'de', label: 'Germany'),
    ComboboxItemData(value: 'jp', label: 'Japan'),
    ComboboxItemData(value: 'nz', label: 'New Zealand'),
  ];

  String? _country = 'nz';
  String? _sent;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Card(
        seed: 'ship',
        tape: PaperTape.top,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Shipping')),
              CardDescription(Text('Where should it go?')),
            ],
          ),
          CardContent(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d24,
              vertical: Spacing.d16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d8,
              children: [
                const Label(child: Text('Country')),
                Combobox(
                  items: _countries,
                  value: _country,
                  onChanged: (country) => setState(() => _country = country),
                  label: 'Country',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ComboboxInput(
                        placeholder: 'Start typing a country...',
                        semanticLabel: 'Country',
                        showClear: true,
                      ),
                      ComboboxContent(
                        children: [
                          ComboboxList(
                            children: [
                              const ComboboxEmpty(
                                child: Text('No such country.'),
                              ),
                              for (final country in _countries)
                                ComboboxItem(
                                  value: country.value,
                                  label: country.label,
                                  child: Text(country.label),
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
          ),
          CardFooter(
            divider: true,
            spacing: Spacing.d12,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    switch (_sent) {
                      null => 'Nothing sent yet.',
                      final code => 'Sent country code: $code',
                    },
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
              Button(
                onPressed: () => setState(() => _sent = _country ?? 'nothing'),
                child: const Text('Ship'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
