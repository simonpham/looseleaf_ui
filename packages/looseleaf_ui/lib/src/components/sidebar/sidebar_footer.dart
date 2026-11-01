import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The bottom of the pad: a column of [children], 8 px apart, 8 px in.
///
/// Mirrors `SidebarFooter` in upstream `src/components/ui/sidebar.tsx`.
class SidebarFooter extends StatelessWidget {
  const SidebarFooter({super.key, required this.children});

  /// Usually a [SidebarMenu] or a [SidebarInput].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: children,
    ),
  );
}
