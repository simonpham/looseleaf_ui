import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AccordionFaqExample extends StatelessWidget {
  const AccordionFaqExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Accordion(
      collapsible: true,
      defaultValue: {'item-1'},
      children: [
        AccordionItem(
          value: 'item-1',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(child: Text('Is it accessible?')),
              AccordionContent(
                child: Text(
                  'Yes. It follows the WAI-ARIA accordion pattern: one tab stop per row, arrows between rows, and every panel is labeled by its trigger.',
                ),
              ),
            ],
          ),
        ),
        AccordionItem(
          value: 'item-2',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(child: Text('Is it drawn by hand?')),
              AccordionContent(
                child: Text(
                  'Every rule, brace and highlighter swipe is a pen stroke, seeded so the same page always looks the same.',
                ),
              ),
            ],
          ),
        ),
        AccordionItem(
          value: 'item-3',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccordionTrigger(child: Text('Does it respect reduced motion?')),
              AccordionContent(
                child: Text(
                  'Yes. With reduced motion the rows open at once and the brace simply appears.',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
