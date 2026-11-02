import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarqueeDefaultExample extends StatelessWidget {
  const MarqueeDefaultExample({super.key});

  static const _maxWidth = 672.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Marquee(
      label: 'Shop news',
      children: [
        MarqueeItem(Text('Fresh bread at seven')),
        MarqueeItem(Text('Open late on Fridays')),
        MarqueeItem(Text('Ask about the rye')),
      ],
    ),
  );
}
