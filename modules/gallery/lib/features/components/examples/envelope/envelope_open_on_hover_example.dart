import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EnvelopeOpenOnHoverExample extends StatelessWidget {
  const EnvelopeOpenOnHoverExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d48),
      child: Envelope(
        openOnHover: true,
        stock: StockName.paper,
        stamp: Accent.grape,
        seed: 'hover',
        tiltDegrees: 1,
        children: [
          const EnvelopeFront(
            children: [
              EnvelopeAddress(children: [Text('A curious reader')]),
              EnvelopeTrigger(),
            ],
          ),
          EnvelopeLetter(
            stock: StockName.indexCard,
            rules: RuleName.indexCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peek',
                  style: theme.typography
                      .title(cssSize: 24)
                      .copyWith(height: 1),
                ),
                Text(
                  'Hover me, or press the envelope.',
                  style: theme.typography.interface(cssSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
