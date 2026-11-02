import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TearOffCouponBookExample extends StatefulWidget {
  const TearOffCouponBookExample({super.key});

  @override
  State<TearOffCouponBookExample> createState() =>
      _TearOffCouponBookExampleState();
}

class _TearOffCouponBookExampleState extends State<TearOffCouponBookExample> {
  static const _bodyWidth = Spacing.d288;
  static const _stubWidth = 112.0;

  bool _torn = false;
  int _redeemed = 0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        TearOff(
          torn: _torn,
          onTornChange: (torn) => setState(() => _torn = torn),
          onTear: () => setState(() => _redeemed++),
          tornMessage: 'Coupon redeemed.',
          children: [
            TearOffBody(
              width: _bodyWidth,
              child: Confetti(
                active: _torn,
                options: const ConfettiOptions(count: 40, spread: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Text('Bakery of the month', style: title),
                    Text(
                      'One croissant, warm, any day.',
                      style: theme.typography.interface(cssSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            TearOffStub(
              width: _stubWidth,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 0,
              padding: const EdgeInsets.fromLTRB(
                Spacing.d16,
                Spacing.d14,
                Spacing.d16,
                Spacing.d8,
              ),
              children: [
                Text('free', style: title),
                Text(
                  'tear here',
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 14,
                    cssLineHeight: 30 / 14,
                    color: theme.colors.pencilText,
                  ),
                ),
              ],
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d12,
          runSpacing: Spacing.d8,
          children: [
            Text(
              'Redeemed $_redeemed time${switch (_redeemed) {
                1 => '',
                _ => 's',
              }}',
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => setState(() => _torn = false),
              child: const Text('New coupon'),
            ),
          ],
        ),
      ],
    );
  }
}
