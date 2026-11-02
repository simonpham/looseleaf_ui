import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AccordionMultipleExample extends StatelessWidget {
  const AccordionMultipleExample({super.key});

  static const _maxWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Accordion(
      type: AccordionType.multiple,
      bracket: BracketKind.square,
      defaultValue: const {'shipping', 'returns'},
      children: [
        AccordionItem(
          value: 'shipping',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AccordionTrigger(child: Text('Shipping')),
              AccordionContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d12,
                  children: [
                    const Text(
                      'Orders leave the desk on Tuesdays and Fridays, wrapped in brown paper and tied with string.',
                    ),
                    Button(
                      variant: ButtonVariant.outline,
                      size: ButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Track a parcel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const AccordionItem(
          value: 'returns',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(child: Text('Returns')),
              AccordionContent(
                child: Text(
                  'Send it back within thirty days, unused and unlined.',
                ),
              ),
            ],
          ),
        ),
        const AccordionItem(
          value: 'notes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(child: Text('Gift notes')),
              AccordionContent(
                child: Text(
                  'We write these by hand. Tell us what to say in the order comments.',
                ),
              ),
            ],
          ),
        ),
        const AccordionItem(
          value: 'wholesale',
          disabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(
                child: Text('Wholesale (closed for the season)'),
              ),
              AccordionContent(child: Text('Back in spring.')),
            ],
          ),
        ),
      ],
    ),
  );
}
