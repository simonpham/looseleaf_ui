import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sheet's buttons, stacked full width 8 px apart with 16 px around
/// them. In a side sheet it sits at the bottom of the page.
///
/// Mirrors `SheetFooter` in upstream `src/components/ui/sheet.tsx`.
class SheetFooter extends StatelessWidget {
  const SheetFooter({super.key, required this.children});

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
