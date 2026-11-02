import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FlipCardCustomTriggerExample extends StatelessWidget {
  const FlipCardCustomTriggerExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return FlipCard(
      trigger: false,
      width: Spacing.d288,
      height: 208,
      children: [
        FlipCardFront(
          spacing: Spacing.d12,
          textSize: 30,
          children: [
            const Text('Studio pass'),
            Button(
              size: ButtonSize.sm,
              onPressed: () {},
              child: const Text('Book a desk'),
            ),
          ],
        ),
        FlipCardBack(
          spacing: Spacing.d8,
          textSize: 20,
          children: [
            const Text('Mon to Fri, 9 to 5'),
            Text(
              'bring your own kettle',
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.pencilText,
              ),
            ),
          ],
        ),
        PositionedDirectional(
          end: Spacing.d8,
          bottom: Spacing.d4,
          child: FlipCardTrigger(
            overlay: false,
            builder: (context, toggle) => Button(
              variant: ButtonVariant.link,
              size: ButtonSize.sm,
              onPressed: toggle,
              child: const Text('Details'),
            ),
          ),
        ),
      ],
    );
  }
}
