import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelTagHangTagExample extends StatelessWidget {
  const LabelTagHangTagExample({super.key});

  @override
  Widget build(BuildContext context) => const LabelTag(
    seed: 'sale',
    tiltDegrees: -3,
    children: [
      LabelTagTitle(Text('Sale')),
      LabelTagDescription(Text('while stocks last')),
      LabelTagPrice(Text('12.00')),
    ],
  );
}
