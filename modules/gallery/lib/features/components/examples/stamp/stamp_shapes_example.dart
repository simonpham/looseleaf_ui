import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StampShapesExample extends StatelessWidget {
  const StampShapesExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Stamp(
        text: 'Received',
        sub: 'Mar 14 2026',
        ink: StampPadInk.inkYou,
        h: 72,
      ),
      Stamp(
        text: 'Members',
        shape: StampShape.round,
        ring: 'MEMBERS - EST 2026 -',
        ink: StampPadInk.inkYou,
        size: 96,
      ),
      Stamp(
        text: 'New',
        shape: StampShape.burst,
        sub: 'issue',
        ink: StampPadInk.ink,
        size: 96,
      ),
      Stamp(
        text: 'Void',
        shape: StampShape.voided,
        ink: StampPadInk.red,
        w: 160,
        h: 64,
      ),
    ],
  );
}
