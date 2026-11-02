import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TooltipSidesAndNotesExample extends StatelessWidget {
  const TooltipSidesAndNotesExample({super.key});

  static const _notes = [
    (OverlaySide.top, StockName.stickyYellow, 'Yellow, on top'),
    (OverlaySide.right, StockName.stickyBlue, 'Blue, to the right'),
    (OverlaySide.bottom, StockName.stickyPink, 'Pink, below'),
    (OverlaySide.left, StockName.slip, 'A plain slip, on the left'),
  ];

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: Wrap(
      spacing: Spacing.d16,
      runSpacing: Spacing.d16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (side, stock, text) in _notes)
          Tooltip(
            content: TooltipContent(
              side: side,
              stock: stock,
              seed: side.name,
              child: Text(text),
            ),
            child: Button(
              variant: ButtonVariant.outline,
              onPressed: () {},
              child: Text(
                '${side.name[0].toUpperCase()}${side.name.substring(1)}',
              ),
            ),
          ),
      ],
    ),
  );
}
