import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RibbonDefaultExample extends StatelessWidget {
  const RibbonDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d20,
    children: [
      Ribbon(size: RibbonSize.lg, child: Text('New arrivals')),
      Ribbon(tone: RibbonTone.sky, child: Text('Staff pick')),
      Ribbon(
        size: RibbonSize.sm,
        tone: RibbonTone.grass,
        child: Text('In stock'),
      ),
    ],
  );
}
