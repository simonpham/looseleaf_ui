import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupSingleChoiceExample extends StatefulWidget {
  const ToggleGroupSingleChoiceExample({super.key});

  @override
  State<ToggleGroupSingleChoiceExample> createState() =>
      _ToggleGroupSingleChoiceExampleState();
}

class _ToggleGroupSingleChoiceExampleState
    extends State<ToggleGroupSingleChoiceExample> {
  static const _sampleWidth = Spacing.d288;

  var _align = 'center';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        ToggleGroup<String>(
          variant: ToggleVariant.outline,
          value: {_align},
          onChanged: (value) {
            if (value.firstOrNull case final align?) {
              setState(() => _align = align);
            }
          },
          semanticLabel: 'Text alignment',
          children: const [
            ToggleGroupItem(value: 'left', child: Text('Left')),
            ToggleGroupItem(value: 'center', child: Text('Center')),
            ToggleGroupItem(value: 'right', child: Text('Right')),
          ],
        ),
        SizedBox(
          width: _sampleWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Separator(variant: SeparatorVariant.dashed),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.d8),
                child: Text(
                  'Aligned $_align, the way the page would be.',
                  textAlign: switch (_align) {
                    'left' => TextAlign.left,
                    'right' => TextAlign.right,
                    _ => TextAlign.center,
                  },
                  style: theme.typography.interface(cssSize: 16),
                ),
              ),
              const Separator(variant: SeparatorVariant.dashed),
            ],
          ),
        ),
      ],
    );
  }
}
