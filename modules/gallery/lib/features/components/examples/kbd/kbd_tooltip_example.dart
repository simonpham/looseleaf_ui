import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class KbdTooltipExample extends StatelessWidget {
  const KbdTooltipExample({super.key});

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: ButtonGroup(
      children: [
        Tooltip(
          content: const TooltipContent(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d4,
              children: [
                Text('Save Changes'),
                Kbd(child: Text('S')),
              ],
            ),
          ),
          child: Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () {},
            child: const Text('Save'),
          ),
        ),
        Tooltip(
          content: const TooltipContent(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d4,
              children: [
                Text('Print Document'),
                KbdGroup(
                  children: [
                    Kbd(child: Text('Ctrl')),
                    Kbd(child: Text('P')),
                  ],
                ),
              ],
            ),
          ),
          child: Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () {},
            child: const Text('Print'),
          ),
        ),
      ],
    ),
  );
}
