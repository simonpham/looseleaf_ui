import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The zone above an index card's red rule: 49 px high, its [children]
/// spread apart 12 px at least, sitting on the line.
///
/// Mirrors `IndexCardHeader` in upstream `src/components/ui/index-card.tsx`.
class IndexCardHeader extends StatelessWidget {
  const IndexCardHeader({super.key, required this.children});

  /// Usually an [IndexCardTitle], then anything to its end.
  final List<Widget> children;

  /// Upstream's `h-[49px]`: the first line box of the grid.
  static const double height = 49;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.d6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: Spacing.d12,
          children: [
            for (final (index, child) in children.indexed)
              switch (index) {
                0 => Flexible(child: child),
                _ => child,
              },
          ],
        ),
      ),
    );
  }
}
