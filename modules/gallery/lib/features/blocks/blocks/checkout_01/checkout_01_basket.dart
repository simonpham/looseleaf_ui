import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Your basket": each product with a quantity stepper, then the promo code.
class Checkout01Basket extends StatelessWidget {
  const Checkout01Basket({
    super.key,
    required this.qty,
    required this.onQty,
    required this.code,
    required this.onCode,
  });

  final List<int> qty;
  final void Function(int index, int value) onQty;
  final String? code;
  final ValueChanged<String?> onCode;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Paper(
      tiltDegrees: 0.3,
      seed: 'basket',
      padding: const EdgeInsets.all(Spacing.d20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Your basket',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 30,
                cssLineHeight: 1,
                fontWeight: FontWeight.w600,
                color: theme.colors.ink,
              ),
            ),
          ),
          Semantics(
            label: 'Basket',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                for (final (index, product) in checkoutProducts.indexed)
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: theme.typography
                                  .interface(color: theme.colors.ink)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${product.note} · €${money(product.cents)}',
                              style: theme.typography.interface(
                                cssSize: 14,
                                color: theme.colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stepper(
                        value: qty[index].toDouble(),
                        onChanged: (value) =>
                            onQty(index, (value ?? 0).round()),
                        min: 0,
                        max: 9,
                        semanticLabel: product.name,
                        decrementLabel: 'One less: ${product.name}',
                        incrementLabel: 'One more: ${product.name}',
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Checkout01Promo(code: code, onCode: onCode),
        ],
      ),
    );
  }
}
