import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SliderRangeAndTicksExample extends StatefulWidget {
  const SliderRangeAndTicksExample({super.key});

  @override
  State<SliderRangeAndTicksExample> createState() =>
      _SliderRangeAndTicksExampleState();
}

class _SliderRangeAndTicksExampleState
    extends State<SliderRangeAndTicksExample> {
  static const _maxWidth = Spacing.d448;

  List<double> _price = [200, 650];
  List<double> _highlighter = [3];
  List<double> _felt = [40];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final [low, high] = _price;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d32,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Label(child: Text('Price')),
                  Text(
                    '\$${low.round()} to \$${high.round()}',
                    style: theme.typography
                        .face(
                          KevinSansFace.script,
                          cssSize: 24,
                          cssLineHeight: 1,
                          color: theme.colors.inkYou,
                        )
                        .copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
              Slider(
                values: _price,
                onChanged: (values) => setState(() => _price = values),
                max: 1000,
                step: 50,
                ticks: true,
                semanticLabel: 'Price',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              const Label(child: Text('Highlighter')),
              Slider(
                values: _highlighter,
                onChanged: (values) => setState(() => _highlighter = values),
                max: 5,
                ticks: true,
                tone: SliderTone.hi,
                semanticLabel: 'Highlighter',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              const Label(child: Text('Felt tip')),
              Slider(
                values: _felt,
                onChanged: (values) => setState(() => _felt = values),
                tickCount: 4,
                tone: SliderTone.blue,
                semanticLabel: 'Felt tip',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
