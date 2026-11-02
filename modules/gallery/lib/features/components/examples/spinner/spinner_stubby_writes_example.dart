import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerStubbyWritesExample extends StatelessWidget {
  const SpinnerStubbyWritesExample({super.key});

  static const _cards = [
    Card(
      seed: 'fetching',
      children: [
        CardHeader(
          children: [
            CardTitle(Text('Fetching your notes')),
            CardDescription(Text('Stubby is finding the right page.')),
          ],
        ),
        CardContent(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.d8),
            child: Center(
              child: Spinner(
                variant: SpinnerVariant.write,
                size: Spacing.d80,
                semanticLabel: 'Fetching your notes',
              ),
            ),
          ),
        ),
      ],
    ),
    Card(
      stock: StockName.indexCard,
      seed: 'binding',
      children: [
        CardHeader(
          children: [
            CardTitle(Text('Binding the book')),
            CardDescription(
              Text('This takes a minute. Pencils are slow, and careful.'),
            ),
          ],
        ),
        CardContent(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.d8),
            child: Center(
              child: Spinner(
                variant: SpinnerVariant.write,
                size: Spacing.d112,
                semanticLabel: 'Binding the book',
              ),
            ),
          ),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 640) {
            return const Column(spacing: Spacing.d24, children: _cards);
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d24,
              children: [for (final card in _cards) Expanded(child: card)],
            ),
          );
        },
      ),
    ),
  );
}
