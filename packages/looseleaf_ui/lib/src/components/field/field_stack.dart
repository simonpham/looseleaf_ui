import 'package:flutter/widgets.dart';

/// A column whose gaps can differ between pairs of children, for upstream's
/// negative margins (`-my-2`, `nth-last-2:-mt-1`) inside flex gaps.
class FieldStack extends StatelessWidget {
  const FieldStack({
    super.key,
    required this.children,
    required this.gap,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;

  /// The gap before child `index` (from 1), given the two children.
  final double Function(int index, Widget before, Widget after) gap;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: crossAxisAlignment,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) SizedBox(height: gap(index, children[index - 1], child)),
        child,
      ],
    ],
  );
}
