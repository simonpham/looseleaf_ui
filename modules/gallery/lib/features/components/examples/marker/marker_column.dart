import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The column the shadcn marker demos sit in: at most 384 px wide, with
/// [gap] between its [children] and 16 px above and below.
class MarkerColumn extends StatelessWidget {
  const MarkerColumn({
    super.key,
    this.gap = Spacing.d32,
    required this.children,
  });

  static const _maxWidth = Spacing.d384;

  final double gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: children,
        ),
      ),
    ),
  );
}
