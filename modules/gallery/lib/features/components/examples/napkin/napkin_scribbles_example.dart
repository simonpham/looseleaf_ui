import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NapkinScribblesExample extends StatelessWidget {
  const NapkinScribblesExample({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
    clipBehavior: Clip.none,
    children: [
      Napkin(
        fold: NapkinFold.half,
        stain: true,
        seed: 'idea',
        tiltDegrees: -1.5,
        width: Spacing.d320,
        minHeight: Spacing.d256,
        children: [
          NapkinTitle(Text('The idea')),
          NapkinContent(
            Text('a shop where everything is made of paper, even the till'),
          ),
          NapkinFooter(Text('(tell nobody)')),
        ],
      ),
      PositionedDirectional(
        end: Spacing.d24,
        top: Spacing.d12,
        child: Doodle('star', size: 56),
      ),
      Positioned(
        right: -Spacing.d16,
        bottom: -Spacing.d16,
        child: Sticker('done', size: 64, rotate: 10),
      ),
    ],
  );
}
