import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A section of the pad, 8 px in: usually a [SidebarGroupLabel] and a
/// [SidebarGroupContent], with an optional [action] at the end of the label
/// row.
///
/// Mirrors `SidebarGroup` in upstream `src/components/ui/sidebar.tsx`.
class SidebarGroup extends StatelessWidget {
  const SidebarGroup({super.key, required this.children, this.action});

  /// The label and the content.
  final List<Widget> children;

  /// A [SidebarGroupAction], 12 px from the group's top and end.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final column = Padding(
      padding: const EdgeInsets.all(Spacing.d8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    final action = this.action;
    if (action == null) return column;
    return Stack(
      children: [
        column,
        PositionedDirectional(
          top: Spacing.d12,
          end: Spacing.d12,
          child: action,
        ),
      ],
    );
  }
}
