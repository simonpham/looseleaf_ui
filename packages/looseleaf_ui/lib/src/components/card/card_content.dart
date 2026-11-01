import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A card's body, inset 24 px from the sides.
///
/// Mirrors `CardContent` in upstream `src/components/ui/card.tsx`.
class CardContent extends StatelessWidget {
  const CardContent({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: Spacing.d24),
    required this.child,
  });

  /// The padding around the body (`px-6`).
  final EdgeInsetsGeometry padding;

  /// The body.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: child);
}
