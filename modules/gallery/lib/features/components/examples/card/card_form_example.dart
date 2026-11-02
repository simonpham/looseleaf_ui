import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

class CardFormExample extends StatelessWidget {
  const CardFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final label = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      fontWeight: FontWeight.w700,
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            stock: StockName.check,
            seed: 'guest',
            children: [
              const CardHeader(
                divider: true,
                rule: CardRuleStyle.dashed,
                children: [
                  CardTitle(Text('Sign the guest book')),
                  CardDescription(Text('Name, and one line for the wall.')),
                ],
              ),
              CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d4,
                      children: [
                        Text('Name', style: label),
                        const Input(placeholder: 'Ada', semanticLabel: 'Name'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d4,
                      children: [
                        Text('A line for the wall', style: label),
                        const Input(
                          placeholder: 'Lovely evening.',
                          semanticLabel: 'A line for the wall',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CardFooter(
                divider: true,
                rule: CardRuleStyle.dashed,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No. 0042',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                  Button(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Sign'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
