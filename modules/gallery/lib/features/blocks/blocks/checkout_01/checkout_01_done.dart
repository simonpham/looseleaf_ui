import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// After paying: Stubby celebrating, a thank you, the paid receipt with a
/// PAID stamp, and a way back to the shop.
class Checkout01Done extends StatefulWidget {
  const Checkout01Done({
    super.key,
    required this.order,
    required this.onKeepShopping,
  });

  final PlacedOrder order;
  final VoidCallback onKeepShopping;

  @override
  State<Checkout01Done> createState() => _Checkout01DoneState();
}

class _Checkout01DoneState extends State<Checkout01Done> {
  final _heading = FocusNode(skipTraversal: true);

  static const double _maxWidth = 768;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _heading.requestFocus();
    });
  }

  @override
  void dispose() {
    _heading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final order = widget.order;
    final wide = MediaQuery.sizeOf(context).width >= 640;
    final firstName = order.name.trim().split(RegExp(r'\s+')).first;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: switch (wide) {
              true => Spacing.d32,
              false => Spacing.d16,
            },
            vertical: Spacing.d48,
          ),
          child: Column(
            spacing: Spacing.d24,
            children: [
              const Mascot(pose: 'celebrate', size: 132, seed: 'checkout-done'),
              Column(
                spacing: Spacing.d8,
                children: [
                  Focus(
                    focusNode: _heading,
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Thank you, $firstName',
                        textAlign: TextAlign.center,
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 48,
                          cssLineHeight: 1,
                          fontWeight: FontWeight.w700,
                          color: theme.colors.ink,
                        ),
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Order '),
                        TextSpan(
                          text: order.number,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colors.ink,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' is paid. The receipt is on its way to ${order.email}.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 18,
                      cssLineHeight: 28 / 18,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ],
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Checkout01OrderReceipt(
                    qty: order.qty,
                    totals: order.totals,
                    code: order.code,
                    orderNumber: order.number,
                    seed: 'checkout-paid',
                    semanticLabel: 'Receipt of your order',
                    full: false,
                  ),
                  PositionedDirectional(
                    end: switch (wide) {
                      true => -Spacing.d48,
                      false => -Spacing.d24,
                    },
                    top: -Spacing.d16,
                    child: const Stamp(name: 'stamp-paid', seed: 'paid'),
                  ),
                ],
              ),
              Button(
                variant: ButtonVariant.outline,
                onPressed: widget.onKeepShopping,
                child: const Text('Keep shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
