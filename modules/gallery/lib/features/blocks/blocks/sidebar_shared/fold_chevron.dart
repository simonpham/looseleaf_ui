import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A chevron that turns a quarter toward the reading direction's end when
/// its [Collapsible] opens: down from "start", in either direction.
class FoldChevron extends StatelessWidget {
  const FoldChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final open = Collapsible.of(context).open;
    final turn = switch (Directionality.of(context)) {
      TextDirection.ltr => 0.25,
      TextDirection.rtl => -0.25,
    };
    return AnimatedRotation(
      turns: switch (open) {
        true => turn,
        false => 0,
      },
      duration: InkMotion.of(context, InkMotion.hover),
      child: InkIcon(
        'chevron-right',
        flip: switch (Directionality.of(context)) {
          TextDirection.rtl => IconFlip.x,
          TextDirection.ltr => IconFlip.none,
        },
      ),
    );
  }
}
