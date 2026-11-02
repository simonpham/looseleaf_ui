import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerItemExample extends StatelessWidget {
  const SpinnerItemExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d448),
    child: LayoutBuilder(
      builder: (context, constraints) => InkItem(
        variant: ItemVariant.outline,
        children: [
          const ItemMedia(variant: ItemMediaVariant.icon, child: Spinner()),
          const ItemContent(
            children: [
              ItemTitle(Text('Downloading...')),
              ItemDescription(Text('750 MB / 1000 MB')),
            ],
          ),
          if (constraints.maxWidth >= 360)
            ItemActions(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
              ],
            ),
          const ItemFooter(
            children: [
              Expanded(
                child: Progress(value: 75, semanticLabel: 'Download progress'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
