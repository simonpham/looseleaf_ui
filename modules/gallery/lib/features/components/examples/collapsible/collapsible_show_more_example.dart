import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _books = [
  'The Design of Everyday Things',
  'A Pattern Language',
  'Letters to a Young Poet',
  'Steal Like an Artist',
  'How to Do Nothing',
  'Bird by Bird',
  'The Elements of Typographic Style',
];

class CollapsibleShowMoreExample extends StatefulWidget {
  const CollapsibleShowMoreExample({super.key});

  @override
  State<CollapsibleShowMoreExample> createState() =>
      _CollapsibleShowMoreExampleState();
}

class _CollapsibleShowMoreExampleState
    extends State<CollapsibleShowMoreExample> {
  static const _maxWidth = 384.0;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final item = theme.typography.interface(cssSize: 14);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'reading-list',
        children: [
          CardHeader(
            children: [
              const CardTitle(Text('Reading list')),
              CardDescription(
                Text(
                  '${_books.length} books, in the order I meant to read them.',
                ),
              ),
            ],
          ),
          CardContent(
            child: Collapsible(
              open: _open,
              onOpenChange: (open) => setState(() => _open = open),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d6,
                    children: [
                      for (final book in _books.take(3))
                        Text(book, style: item),
                    ],
                  ),
                  CollapsibleContent(
                    child: Padding(
                      padding: const EdgeInsets.only(top: Spacing.d6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d6,
                        children: [
                          for (final book in _books.skip(3))
                            Text(book, style: item),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d12),
                    child: Builder(
                      builder: (context) => Button(
                        variant: ButtonVariant.link,
                        size: ButtonSize.sm,
                        onPressed: Collapsible.of(context).toggle,
                        trailing: const CollapsibleIndicator(),
                        child: Text(switch (_open) {
                          true => 'Show fewer',
                          false => 'Show ${_books.length - 3} more',
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
