import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/popover/popover.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PopoverDemoExample extends StatelessWidget {
  static const _width = Spacing.d320;

  const PopoverDemoExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Popover(
      content: PopoverContent(
        width: _width,
        semanticLabel: 'Dimensions',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Text(
                  'Dimensions',
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Set the dimensions for the layer.',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ],
            ),
            const Column(
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
}
