import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SealVerifiedInTheUiExample extends StatelessWidget {
  const SealVerifiedInTheUiExample({super.key});

  static const double _twoColumnsFrom = Spacing.d96 * 5;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const cards = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [_ProfileCard(), _ProductCard()],
      );
      if (constraints.maxWidth < _twoColumnsFrom) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: [cards, _CertificateCard()],
        );
      }
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          Expanded(child: cards),
          Expanded(child: _CertificateCard()),
        ],
      );
    },
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      gap: Spacing.d12,
      padding: const EdgeInsets.all(Spacing.d16),
      children: [
        Row(
          spacing: Spacing.d12,
          children: [
            const Avatar(children: [AvatarFallback(name: 'Maya Chen')]),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: Spacing.d6,
                    children: [
                      Text(
                        'Maya Chen',
                        style: theme.typography
                            .interface(cssSize: 18)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Seal(
                        mark: SealMark.check,
                        tone: PaintKey.sky,
                        size: Spacing.d20,
                        semanticLabel: 'Verified',
                        shadow: false,
                      ),
                    ],
                  ),
                  Text(
                    'Illustrator, Lisbon',
                    style: theme.typography.interface(
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) => const Stack(
    clipBehavior: Clip.none,
    children: [
      Card(
        children: [
          CardHeader(
            children: [
              CardTitle(Text('Twelve felt tips')),
              CardDescription(Text('Assorted, water based, no bleed.')),
            ],
          ),
          CardContent(child: Text(r'$ 14.00')),
        ],
      ),
      PositionedDirectional(
        top: -Spacing.d20,
        end: -Spacing.d12,
        child: Seal(
          variant: SealVariant.rosette,
          text: 'Best',
          tone: PaintKey.lemon,
          ribbon: PaintKey.tomato,
          size: Spacing.d68 + Spacing.d4,
          tilt: 8,
        ),
      ),
    ],
  );
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      gap: Spacing.d8,
      padding: const EdgeInsets.all(Spacing.d24),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Certificate of',
          style: theme.typography.stamp(
            cssSize: 12,
            color: theme.colors.pencilText,
          ),
        ),
        Text(
          'Good Handwriting',
          textAlign: TextAlign.center,
          style: theme.typography.face(KevinSansFace.script, cssSize: 36),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Spacing.d256),
          child: Text(
            'Awarded to Maya Chen for lettering that stays on the line, mostly.',
            textAlign: TextAlign.center,
            style: theme.typography.interface(color: theme.colors.inkMuted),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: Spacing.d12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Spacing.d16,
            children: [
              Seal(
                variant: SealVariant.ring,
                text: 'Signed',
                tone: PaintKey.sky,
                ring: 'Official seal',
                size: Spacing.d112,
                semanticLabel: 'Official seal',
              ),
              Seal(
                variant: SealVariant.wax,
                text: 'M',
                tone: PaintKey.red,
                size: Spacing.d80 + Spacing.d4,
                tilt: -6,
                semanticLabel: 'Wax seal',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
