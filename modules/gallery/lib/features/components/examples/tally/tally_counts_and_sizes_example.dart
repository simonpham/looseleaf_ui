import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TallyCountsAndSizesExample extends StatefulWidget {
  const TallyCountsAndSizesExample({super.key});

  @override
  State<TallyCountsAndSizesExample> createState() =>
      _TallyCountsAndSizesExampleState();
}

class _TallyCountsAndSizesExampleState
    extends State<TallyCountsAndSizesExample> {
  int _count = 13;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d16,
        children: [
          Button(
            size: ButtonSize.iconSm,
            variant: ButtonVariant.outline,
            semanticLabel: 'One fewer',
            onPressed: () => setState(() => _count = math.max(0, _count - 1)),
            child: const InkIcon('minus'),
          ),
          Tally(count: _count, size: TallySize.lg),
          Button(
            size: ButtonSize.iconSm,
            semanticLabel: 'One more',
            onPressed: () => setState(() => _count = math.min(99, _count + 1)),
            child: const InkIcon('plus'),
          ),
        ],
      ),
      const Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.d24,
        runSpacing: Spacing.d12,
        children: [
          Tally(count: 9, size: TallySize.sm),
          Tally(count: 9, tone: MarkPen.blue),
          Tally(count: 9, tone: MarkPen.red, size: TallySize.lg),
          Tally(count: 9, tone: MarkPen.pencil, weight: MarkWeight.fine),
        ],
      ),
    ],
  );
}
