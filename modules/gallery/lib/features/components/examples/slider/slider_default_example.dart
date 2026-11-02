import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SliderDefaultExample extends StatefulWidget {
  const SliderDefaultExample({super.key});

  @override
  State<SliderDefaultExample> createState() => _SliderDefaultExampleState();
}

class _SliderDefaultExampleState extends State<SliderDefaultExample> {
  static const _maxWidth = 384.0;

  List<double> _volume = [60];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Label(child: Text('Pencil pressure')),
              Text(
                '${_volume.first.round()}',
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
            values: _volume,
            onChanged: (values) => setState(() => _volume = values),
            semanticLabel: 'Pencil pressure',
          ),
        ],
      ),
    );
  }
}
