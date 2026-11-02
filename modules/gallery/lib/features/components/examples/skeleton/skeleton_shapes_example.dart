import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonShapesExample extends StatelessWidget {
  const SkeletonShapesExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 448),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        Row(
          spacing: Spacing.d16,
          children: [
            Skeleton(width: Spacing.d48, height: Spacing.d48, circle: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Skeleton(width: 250, height: Spacing.d16),
                Skeleton(width: 200, height: Spacing.d16),
              ],
            ),
          ],
        ),
        Skeleton(height: 144),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            Skeleton(height: Spacing.d12),
            FractionallySizedBox(
              widthFactor: 0.92,
              child: Skeleton(height: Spacing.d12),
            ),
            FractionallySizedBox(
              widthFactor: 0.64,
              child: Skeleton(height: Spacing.d12),
            ),
          ],
        ),
        Row(
          spacing: Spacing.d12,
          children: [
            Skeleton(width: Spacing.d96, height: Spacing.d36),
            Skeleton(width: Spacing.d80, height: Spacing.d36),
            Skeleton(width: Spacing.d36, height: Spacing.d36, circle: true),
          ],
        ),
      ],
    ),
  );
}
