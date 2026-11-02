import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SliderBrushSettingsExample extends StatefulWidget {
  const SliderBrushSettingsExample({super.key});

  @override
  State<SliderBrushSettingsExample> createState() =>
      _SliderBrushSettingsExampleState();
}

class _SliderBrushSettingsExampleState
    extends State<SliderBrushSettingsExample> {
  static const _maxWidth = Spacing.d384;
  static const _initial = {'size': 12.0, 'opacity': 85.0, 'hardness': 40.0};
  static const _rows = [
    (key: 'size', label: 'Size', unit: 'px', min: 1.0, max: 48.0),
    (key: 'opacity', label: 'Opacity', unit: '%', min: 0.0, max: 100.0),
    (key: 'hardness', label: 'Hardness', unit: '%', min: 0.0, max: 100.0),
  ];

  var _values = Map.of(_initial);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d20,
        children: [
          for (final row in _rows)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Label(child: Text(row.label)),
                    Text(
                      '${_value(row.key).round()}${row.unit}',
                      style: theme.typography
                          .interface(cssSize: 14, color: theme.colors.inkMuted)
                          .copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ],
                ),
                Slider(
                  semanticLabel: row.label,
                  valueText: (value, _) => switch (row.unit) {
                    '%' => '${value.round()} percent',
                    _ => '${value.round()} pixels',
                  },
                  min: row.min,
                  max: row.max,
                  values: [_value(row.key)],
                  onChanged: (values) =>
                      setState(() => _values[row.key] = values.first),
                  tone: switch (row.key) {
                    'hardness' => SliderTone.blue,
                    _ => SliderTone.marker,
                  },
                ),
              ],
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => setState(() => _values = Map.of(_initial)),
              child: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  double _value(String key) => _values[key] ?? 0;
}
