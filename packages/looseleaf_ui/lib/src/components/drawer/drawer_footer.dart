import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A drawer's buttons, stacked full width 8 px apart with 16 px around
/// them; in a side drawer it sits at the bottom.
///
/// Mirrors `DrawerFooter` in upstream `src/components/ui/drawer.tsx`.
class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key, required this.children});

  /// The buttons, top to bottom.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: children,
    ),
  );
}
