import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarqueeTapesExample extends StatelessWidget {
  const MarqueeTapesExample({super.key});

  static const _maxWidth = 672.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d20,
      children: [
        Marquee(
          tape: TapeKind.masking,
          speed: 45,
          label: 'Masking tape ticker',
          controls: false,
          children: [
            MarqueeItem(Text('Handle with care')),
            MarqueeItem(Text('This side up')),
          ],
        ),
        Marquee(
          tape: TapeKind.washiStripes,
          color: Accent.sky,
          direction: MarqueeDirection.end,
          label: 'Striped tape ticker',
          children: [
            MarqueeItem(Text('New arrivals')),
            MarqueeItem(Text('Restocked today')),
          ],
        ),
        Marquee(
          tape: TapeKind.washiGingham,
          color: Accent.tomato,
          speed: 90,
          label: 'Gingham ticker',
          children: [
            MarqueeItem(Text('Picnic season')),
            MarqueeItem(Text('Bring a blanket')),
          ],
        ),
      ],
    ),
  );
}
