import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class QuoteDefaultExample extends StatelessWidget {
  const QuoteDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Quote(
      children: [
        QuoteText(
          child: Text(
            'The best time to write it down was when it happened; the second '
            'best is now, before the coffee gets cold.',
          ),
        ),
        QuoteAttribution(child: Text('Ada, in the margin of a book')),
      ],
    ),
  );
}
