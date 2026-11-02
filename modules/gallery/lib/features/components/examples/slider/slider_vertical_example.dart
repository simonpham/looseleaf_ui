import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SliderVerticalExample extends StatefulWidget {
  const SliderVerticalExample({super.key});

  @override
  State<SliderVerticalExample> createState() => _SliderVerticalExampleState();
}

class _SliderVerticalExampleState extends State<SliderVerticalExample> {
  static const _height = 224.0;
  static const _bands = ['60', '230', '910', '3k', '14k'];

  final _levels = <double>[40, 65, 50, 80, 30];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      height: _height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d32,
        children: [
          for (final (index, hz) in _bands.indexed)
            Column(
              spacing: Spacing.d12,
              children: [
                Expanded(
                  child: Slider(
                    direction: Axis.vertical,
                    values: [_levels[index]],
                    onChanged: (values) =>
                        setState(() => _levels[index] = values.first),
                    disabled: index == _bands.length - 1,
                    tickCount: 4,
                    semanticLabel: '$hz Hz',
                  ),
                ),
                Text(
                  hz,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
