import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonCardExample extends StatelessWidget {
  const SkeletonCardExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 672),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          for (final i in const [0, 1]) _ProfileSkeleton(seed: 'sk-$i'),
        ];
        if (constraints.maxWidth < 640) {
          return Column(spacing: Spacing.d24, children: cards);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d24,
          children: [for (final card in cards) Expanded(child: card)],
        );
      },
    ),
  );
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) => Card(
    seed: seed,
    children: const [
      CardHeader(
        children: [
          Row(
            spacing: Spacing.d12,
            children: [
              Skeleton(width: Spacing.d48, height: Spacing.d48, circle: true),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Skeleton(height: Spacing.d16),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Skeleton(height: Spacing.d12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      CardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d8,
          children: [
            Skeleton(height: Spacing.d12),
            Skeleton(height: Spacing.d12),
            FractionallySizedBox(
              widthFactor: 2 / 3,
              child: Skeleton(height: Spacing.d12),
            ),
          ],
        ),
      ),
    ],
  );
}
