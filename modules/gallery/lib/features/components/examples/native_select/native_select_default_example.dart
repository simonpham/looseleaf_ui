import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectDefaultExample extends StatefulWidget {
  const NativeSelectDefaultExample({super.key});

  @override
  State<NativeSelectDefaultExample> createState() =>
      _NativeSelectDefaultExampleState();
}

class _NativeSelectDefaultExampleState
    extends State<NativeSelectDefaultExample> {
  String? _country;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: Spacing.d176 + Spacing.d44,
    child: NativeSelect<String>(
      value: _country,
      onChanged: (country) => setState(() => _country = country),
      placeholder: 'Choose a country',
      semanticLabel: 'Country',
      options: const [
        NativeSelectOption(value: 'is', label: 'Iceland'),
        NativeSelectOption(value: 'pt', label: 'Portugal'),
        NativeSelectOption(value: 'jp', label: 'Japan'),
        NativeSelectOption(value: 'ca', label: 'Canada'),
      ],
    ),
  );
}
