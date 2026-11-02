import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AccordionProductDetailsExample extends StatelessWidget {
  const AccordionProductDetailsExample({super.key});

  static const _maxWidth = Spacing.d448;
  static const _items = [
    (
      value: 'item-1',
      title: 'Product information',
      paragraphs: [
        'The Field Notebook is stitched by hand and lies flat on any desk. Its pages take fountain pen, felt tip and a careless highlighter without bleeding through.',
        'Key features include a lay-flat spine, a ribbon that is always long enough, and an elastic that has never once snapped.',
      ],
    ),
    (
      value: 'item-2',
      title: 'Shipping details',
      paragraphs: [
        'We post worldwide with trusted couriers. Standard delivery takes 3-5 working days; express arrives in 1-2.',
        'Every parcel is wrapped in brown paper and insured. You get a tracking link the moment it leaves the desk.',
      ],
    ),
    (
      value: 'item-3',
      title: 'Return policy',
      paragraphs: [
        'Send it back within 30 days if it is not right. If you are not completely happy, return it in its original condition.',
        'Return postage is on us, and the refund is with you within 48 hours of the parcel arriving back.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Accordion(
      collapsible: true,
      defaultValue: const {'item-1'},
      children: [
        for (final item in _items)
          AccordionItem(
            value: item.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccordionTrigger(child: Text(item.title)),
                AccordionContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d16,
                    children: [
                      for (final paragraph in item.paragraphs) Text(paragraph),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
