import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SliderDemoExample extends StatefulWidget {
  const SliderDemoExample({super.key});

  @override
  State<SliderDemoExample> createState() => _SliderDemoExampleState();
}

class _SliderDemoExampleState extends State<SliderDemoExample> {
  List<double> _volume = [50];

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: 0.6,
    child: Slider(
      values: _volume,
      onChanged: (values) => setState(() => _volume = values),
      semanticLabel: 'Volume',
    ),
  );
}
