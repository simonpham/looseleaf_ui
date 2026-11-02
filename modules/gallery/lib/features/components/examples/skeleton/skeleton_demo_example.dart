import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonDemoExample extends StatelessWidget {
  const SkeletonDemoExample({super.key});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d16,
    children: [
      const Skeleton(width: Spacing.d48, height: Spacing.d48, circle: true),
      Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: const Skeleton(height: Spacing.d16),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Spacing.d200),
              child: const Skeleton(height: Spacing.d16),
            ),
          ],
        ),
      ),
    ],
  );
}
