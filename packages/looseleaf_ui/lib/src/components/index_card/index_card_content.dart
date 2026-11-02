import 'package:flutter/widgets.dart';

/// An index card's body: it starts under the header and grows to fill the
/// card when it is a direct child of an `IndexCard`, so an
/// [IndexCardFooter] after it sits at the foot; anywhere else it is a plain
/// column. Text keeps the card's 17 px on a 30 px line, on the blue rules.
///
/// Mirrors `IndexCardContent` in upstream `src/components/ui/index-card.tsx`.
class IndexCardContent extends StatelessWidget {
  const IndexCardContent({super.key, required this.children});

  /// The lines of the body, stacked without gaps.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
