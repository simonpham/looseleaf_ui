import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonCardDemoExample extends StatelessWidget {
  const SkeletonCardDemoExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d12,
    children: [
      Skeleton(width: 250, height: 125),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Skeleton(width: 250, height: Spacing.d16),
          Skeleton(width: Spacing.d200, height: Spacing.d16),
        ],
      ),
    ],
  );
}
