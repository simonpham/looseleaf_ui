import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PopoverArrowSidesExample extends StatelessWidget {
  const PopoverArrowSidesExample({super.key});

  static const _width = 224.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final side in OverlaySide.values)
          Popover(
            content: PopoverContent(
              arrow: true,
              side: side,
              sideOffset: Spacing.d4,
              stock: StockName.stickyYellow,
              seed: 'arrow-${side.name}',
              width: _width,
              child: DefaultTextStyle.merge(
                style: theme.typography.interface(cssSize: 14),
                child: PopoverHeader(
                  children: [
                    const PopoverTitle(Text('Margin note')),
                    PopoverDescription(
                      Text(
                        'Opened on the ${side.name} side of its trigger.',
                        style: TextStyle(
                          color: theme.colors.ink.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: PopoverTrigger.builder(
              builder: (context, popover) => Button(
                variant: ButtonVariant.outline,
                onPressed: popover.toggle,
                child: Text(
                  '${side.name[0].toUpperCase()}${side.name.substring(1)}',
                ),
              ),
            ),
          ),
      ],
    );
  }
}
