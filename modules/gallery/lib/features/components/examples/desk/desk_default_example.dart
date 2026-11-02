import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DeskDefaultExample extends StatelessWidget {
  const DeskDefaultExample({super.key});

  static const _wide = 640.0;
  static const _minHeight = 288.0;
  static const _cardWidth = 320.0;
  static const _noteSide = 160.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final card = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _cardWidth),
      child: const Card(
        seed: 'a',
        children: [
          CardHeader(
            children: [
              CardTitle(Text('On the desk')),
              CardDescription(Text('A card, casting a card-sized shadow.')),
            ],
          ),
          CardContent(
            child: Text(
              'The blotter is a shade darker than the paper so cream glows against it.',
            ),
          ),
        ],
      ),
    );
    final note = SizedBox.square(
      dimension: _noteSide,
      child: Paper(
        stock: StockName.stickyYellow,
        seed: 'b',
        padding: const EdgeInsets.all(Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            Text(
              'call mum',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('before six', style: theme.typography.interface(cssSize: 14)),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => Desk(
        seed: 'bare',
        padding: const EdgeInsets.all(Spacing.d40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Center(
            child: switch (constraints.maxWidth >= _wide) {
              true => Row(
                spacing: Spacing.d24,
                children: [
                  Expanded(child: Center(child: card)),
                  Expanded(child: Center(child: note)),
                ],
              ),
              false => Column(
                spacing: Spacing.d24,
                children: [card, note],
              ),
            },
          ),
        ),
      ),
    );
  }
}
