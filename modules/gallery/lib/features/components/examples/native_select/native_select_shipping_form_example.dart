import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectShippingFormExample extends StatefulWidget {
  const NativeSelectShippingFormExample({super.key});

  @override
  State<NativeSelectShippingFormExample> createState() =>
      _NativeSelectShippingFormExampleState();
}

class _NativeSelectShippingFormExampleState
    extends State<NativeSelectShippingFormExample> {
  static const _countries = {'is': 'Iceland', 'pt': 'Portugal', 'ca': 'Canada'};
  static const _regions = {
    'is': ['Reykjavik', 'Akureyri'],
    'pt': ['Lisbon', 'Porto', 'Faro'],
    'ca': ['Ontario', 'Quebec', 'Alberta'],
  };
  static const double _twoColumnsFrom = Spacing.d160 * 2;

  final _nameFocus = FocusNode();
  String? _country;
  String? _region;
  bool _missing = false;
  String _sent = '';

  @override
  void dispose() {
    _nameFocus.dispose();
    super.dispose();
  }

  void _ship() => setState(() {
    final country = _country;
    _missing = country == null;
    if (country == null) return;
    final region = _region ?? _regions[country]?.first;
    _sent = 'Ships to $region, $country';
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final regions = _regions[_country] ?? const ['Choose a country first'];
    final country = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        const Label(required: true, child: Text('Country')),
        NativeSelect<String>(
          value: _country,
          invalid: _missing,
          placeholder: 'Choose…',
          onChanged: (country) => setState(() {
            _country = country;
            _region = null;
            _missing = false;
          }),
          options: [
            for (final MapEntry(:key, :value) in _countries.entries)
              NativeSelectOption(value: key, label: value),
          ],
        ),
      ],
    );
    final region = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Label(disabled: _country == null, child: const Text('Region')),
        NativeSelect<String>(
          value: _region ?? regions.first,
          disabled: _country == null,
          onChanged: (region) => setState(() => _region = region),
          options: [
            for (final name in regions)
              NativeSelectOption(value: name, label: name),
          ],
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              Label(focusNode: _nameFocus, child: const Text('Name')),
              Input(focusNode: _nameFocus, placeholder: 'Ada Lovelace'),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _twoColumnsFrom) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [country, region],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  Expanded(child: country),
                  Expanded(child: region),
                ],
              );
            },
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _ship, child: const Text('Ship it')),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _sent,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
