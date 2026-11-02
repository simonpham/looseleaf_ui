import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-3xl`.
const _maxWidth = 768.0;

/// Below this width the two columns stack (`md:grid-cols-2`).
const _twoColumns = 640.0;

class RibbonOnACardExample extends StatelessWidget {
  const RibbonOnACardExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _twoColumns) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d32,
            children: [_ProductCard(), _Section()],
          );
        }
        return const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d32,
          children: [
            Expanded(child: _ProductCard()),
            Expanded(child: _Section()),
          ],
        );
      },
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            children: [
              const CardHeader(
                children: [
                  CardTitle(Text('Twelve felt tips')),
                  CardDescription(Text('Assorted, water based, no bleed.')),
                ],
              ),
              CardContent(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r'$ 14.00',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Ribbon(
                      variant: RibbonVariant.swallow,
                      tone: RibbonTone.lemon,
                      size: RibbonSize.sm,
                      onPressed: () {},
                      child: const Text('See details'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const PositionedDirectional(
            top: -Spacing.d12,
            start: -Spacing.d12,
            child: Ribbon(
              variant: RibbonVariant.flag,
              tone: RibbonTone.tangerine,
              size: RibbonSize.sm,
              child: Text('New'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section();

  /// `max-w-xs`.
  static const _textMaxWidth = Spacing.d320;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d12,
    children: [
      const Ribbon(
        size: RibbonSize.lg,
        tone: RibbonTone.teal,
        child: Text('Spring stationery'),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _textMaxWidth),
        child: const Text(
          'Notebooks, washi tape and the good pencils, in the shop until '
          'the end of April.',
        ),
      ),
      Ribbon(
        tone: RibbonTone.sky,
        onPressed: () {},
        child: const Text('Shop the collection'),
      ),
    ],
  );
}
