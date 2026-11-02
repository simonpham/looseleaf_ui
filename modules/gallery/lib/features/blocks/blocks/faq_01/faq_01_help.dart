import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Still stuck?": an index card with a tangerine flag, Stubby thinking and
/// a link to write to a real person.
///
/// Mirrors upstream `src/blocks/faq-01/components/faq-01-help.tsx`.
class Faq01Help extends StatelessWidget {
  const Faq01Help({super.key});

  @override
  Widget build(BuildContext context) => IndexCard(
    flag: Accent.tangerine,
    seed: 'faq-help',
    minHeight: Spacing.d40,
    maxWidth: double.infinity,
    children: [
      IndexCardHeader(
        children: [
          IndexCardTitle(
            Semantics(header: true, child: const Text('Still stuck?')),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.only(end: Spacing.d28),
            child: Mascot(pose: 'think', size: 44),
          ),
        ],
      ),
      const IndexCardContent(
        children: [Text('A real person answers, usually before lunch.')],
      ),
      IndexCardFooter(
        children: [
          Button(
            variant: ButtonVariant.link,
            size: ButtonSize.sm,
            onPressed: () {},
            leading: const InkIcon('mail'),
            child: const Text('Write to us'),
          ),
        ],
      ),
    ],
  );
}
