import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SheetBindingsExample extends StatelessWidget {
  const SheetBindingsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final binding in SheetBinding.values)
          Sheet(
            content: SheetContent(
              binding: binding,
              stock: StockName.pad,
              rules: RuleName.ruled,
              seed: 'binding-${binding.name}',
              children: [
                SheetHeader(
                  children: [
                    const SheetTitle(Text('Field notes')),
                    SheetDescription(
                      Text('binding: “${binding.name}” on ruled pad paper.'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.d24,
                  ),
                  child: DefaultTextStyle.merge(
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 16,
                      cssLineHeight: 28 / 16,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rain from six.'),
                        Text('Tea, two cups, then a third.'),
                        Text('Started the long letter to Ada.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            child: SheetTrigger.builder(
              builder: (context, sheet) => Button(
                variant: ButtonVariant.outline,
                onPressed: sheet.show,
                child: Text(binding.name),
              ),
            ),
          ),
      ],
    );
  }
}
