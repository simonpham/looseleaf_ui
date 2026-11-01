import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A call to action on an index-card ticket: "Ready when you are." with
/// Stubby celebrating on the stub and a party popper sticker.
///
/// Mirrors upstream `src/blocks/cta-01/page.tsx`.
class Cta01Block extends StatelessWidget {
  const Cta01Block({super.key});

  static const double _maxWidth = 896;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 576;
    return Padding(
      padding: switch (wide) {
        true => const EdgeInsets.symmetric(
          horizontal: Spacing.d32,
          vertical: Spacing.d80,
        ),
        false => const EdgeInsets.symmetric(
          horizontal: Spacing.d16,
          vertical: Spacing.d56,
        ),
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Ticket(
                stock: StockName.indexCard,
                stubWidth: Spacing.d112,
                maxWidth: double.infinity,
                seed: 'cta-ticket',
                children: [
                  TicketBody(
                    children: [
                      const TicketDescription(Text('Admit one team')),
                      const Lettering(
                        'Ready when you are.',
                        size: LetteringSize.md,
                        wobble: 0.4,
                        seed: 'cta-title',
                        textAlign: TextAlign.start,
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 512),
                        child: Text(
                          'Start a notebook in under a minute. It is free for teams of five, and there is no card to enter.',
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 18,
                            cssLineHeight: 28 / 18,
                            color: theme.colors.inkSoft,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: Spacing.d8),
                        child: Wrap(
                          spacing: Spacing.d12,
                          runSpacing: Spacing.d12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Button(
                              size: ButtonSize.lg,
                              onPressed: () {},
                              trailing: InkIcon(
                                'arrow-right',
                                flip: switch (Directionality.of(context)) {
                                  TextDirection.rtl => IconFlip.x,
                                  TextDirection.ltr => IconFlip.none,
                                },
                              ),
                              child: const Text('Start writing'),
                            ),
                            Button(
                              size: ButtonSize.lg,
                              variant: ButtonVariant.ghost,
                              onPressed: () {},
                              child: const Text('or talk to a human'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const TicketStub(
                    children: [
                      Mascot(pose: 'celebrate', size: 84),
                      TicketNumber(Text('No. 0001')),
                    ],
                  ),
                ],
              ),
              if (wide)
                const PositionedDirectional(
                  start: -Spacing.d20,
                  top: -Spacing.d36,
                  child: IgnorePointer(
                    child: Sticker('party-popper', size: 76, rotate: -14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
