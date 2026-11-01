import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pencil rule across the pad, 8 px in from its sides.
///
/// Mirrors `SidebarSeparator` in upstream `src/components/ui/sidebar.tsx`.
class SidebarSeparator extends StatelessWidget {
  const SidebarSeparator({super.key, this.seed});

  /// Pins the rule.
  final String? seed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
    child: Separator(seed: seed),
  );
}
