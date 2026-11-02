import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonDemoExample extends StatelessWidget {
  const SkeletonDemoExample({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d16,
    children: [
      Skeleton(width: Spacing.d48, height: Spacing.d48, circle: true),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Skeleton(width: 250, height: Spacing.d16),
          Skeleton(width: 200, height: Spacing.d16),
        ],
      ),
    ],
  );
}
