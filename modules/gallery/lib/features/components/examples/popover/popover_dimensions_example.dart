import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/popover/popover.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PopoverDimensionsExample extends StatelessWidget {
  static const _width = Spacing.d320;

  const PopoverDimensionsExample({super.key});

  @override
  Widget build(BuildContext context) => Popover(
    content: const PopoverContent(
      width: _width,
      pin: true,
      seed: 'dimensions',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          PopoverHeader(
            children: [
              PopoverTitle(Text('Dimensions')),
              PopoverDescription(Text('Set the dimensions for the layer.')),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              PopoverDimensionField(label: 'Width', value: '100%'),
              PopoverDimensionField(label: 'Max. width', value: '300px'),
              PopoverDimensionField(label: 'Height', value: '25px'),
              PopoverDimensionField(label: 'Max. height', value: 'none'),
            ],
          ),
        ],
      ),
    ),
    child: PopoverTrigger.builder(
      builder: (context, popover) => Button(
        variant: ButtonVariant.outline,
        onPressed: popover.toggle,
        child: const Text('Open popover'),
      ),
    ),
  );
}
