import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SheetNavigationExample extends StatelessWidget {
  const SheetNavigationExample({super.key});

  static const _links = [
    'Notebooks',
    'Drawings',
    'Recipes',
    'Garden log',
    'Reading list',
    'Field notes',
    'Letters',
    'Postcards',
    'Receipts',
    'Archive',
    'Bin',
  ];

  @override
  Widget build(BuildContext context) => Sheet(
    content: SheetContent(
      side: OverlaySide.left,
      binding: SheetBinding.holes,
      stock: StockName.pad,
      seed: 'nav',
      children: [
        const SheetHeader(
          children: [
            SheetTitle(Text('Looseleaf')),
            SheetDescription(
              Text('Everything you have written, in one binder.'),
            ),
          ],
        ),
        Expanded(
          child: Semantics(
            label: 'Main',
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.d16,
                vertical: Spacing.d12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d4,
                children: [
                  for (final label in _links)
                    SheetClose(
                      builder: (context, close) => Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Button(
                          variant: ButtonVariant.ghost,
                          onPressed: close,
                          child: Text(label),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    child: SheetTrigger.builder(
      builder: (context, sheet) => Button(
        variant: ButtonVariant.outline,
        size: ButtonSize.icon,
        semanticLabel: 'Open menu',
        onPressed: sheet.show,
        child: const InkIcon('menu'),
      ),
    ),
  );
}
