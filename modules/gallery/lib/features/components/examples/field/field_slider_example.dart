import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldSliderExample extends StatefulWidget {
  const FieldSliderExample({super.key});

  @override
  State<FieldSliderExample> createState() => _FieldSliderExampleState();
}

class _FieldSliderExampleState extends State<FieldSliderExample> {
  static const _maxWidth = 448.0;
  static const _amount = TextStyle(
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  var _range = const [200.0, 800.0];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Field(
      children: [
        const FieldTitle(Text('Price Range')),
        FieldDescription(
          Text.rich(
            TextSpan(
              text: r'Set your budget range ($',
              children: [
                TextSpan(text: '${_range.first.round()}', style: _amount),
                const TextSpan(text: ' - '),
                TextSpan(text: '${_range.last.round()}', style: _amount),
                const TextSpan(text: ').'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d8),
          child: Slider(
            values: _range,
            onChanged: (values) => setState(() => _range = values),
            max: 1000,
            step: 10,
            semanticLabel: 'Price Range',
          ),
        ),
      ],
    ),
  );
}
