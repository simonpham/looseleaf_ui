import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SheetSidesExample extends StatelessWidget {
  const SheetSidesExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d12,
    runSpacing: Spacing.d12,
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final side in OverlaySide.values)
        Sheet(
          content: SheetContent(
            side: side,
            seed: 'side-${side.name}',
            children: [
              SheetHeader(
                children: [
                  SheetTitle(Text('From the ${side.name}')),
                  SheetDescription(
                    Text(
                      'A page slides in from the ${side.name} edge of the screen. Click outside, press Escape or tap the x to put it away.',
                    ),
                  ),
                ],
              ),
              SheetFooter(
                children: [
                  SheetClose(
                    builder: (context, close) => Button(
                      variant: ButtonVariant.outline,
                      onPressed: close,
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          child: SheetTrigger.builder(
            builder: (context, sheet) => Button(
              variant: ButtonVariant.outline,
              onPressed: sheet.show,
              child: Text(
                '${side.name[0].toUpperCase()}${side.name.substring(1)}',
              ),
            ),
          ),
        ),
    ],
  );
}
