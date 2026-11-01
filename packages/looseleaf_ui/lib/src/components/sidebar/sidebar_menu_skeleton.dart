import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/skeleton/skeleton.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A loading row of pencil hatch, with a square for the icon when
/// [showIcon]. Its width (50 to 90 % of the row) comes from the seed, so a
/// rebuild keeps it.
///
/// Mirrors `SidebarMenuSkeleton` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuSkeleton extends StatefulWidget {
  const SidebarMenuSkeleton({super.key, this.showIcon = false, this.seed});

  /// A square for the icon.
  final bool showIcon;

  /// Pins the width and the hatch.
  final String? seed;

  /// The text's share of the row for [seed]: `50 + hashSeed(seed) % 41` %.
  static double widthFactor(String seed) => (50 + hashSeed(seed) % 41) / 100;

  @override
  State<SidebarMenuSkeleton> createState() => _SidebarMenuSkeletonState();
}

class _SidebarMenuSkeletonState extends State<SidebarMenuSkeleton>
    with InkSeed {
  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final factor = SidebarMenuSkeleton.widthFactor(seed);
    final iconShare = switch (widget.showIcon) {
      true => Spacing.d16 + Spacing.d8,
      false => 0.0,
    };
    return SizedBox(
      height: Spacing.d32,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
        child: Row(
          spacing: Spacing.d8,
          children: [
            if (widget.showIcon)
              Skeleton(
                width: Spacing.d16,
                height: Spacing.d16,
                seed: '$seed|icon',
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Skeleton(
                    width: math.min(
                      constraints.maxWidth,
                      (constraints.maxWidth + iconShare) * factor,
                    ),
                    height: Spacing.d16,
                    seed: '$seed|text',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
