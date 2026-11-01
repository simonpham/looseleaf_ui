import 'package:flutter/widgets.dart';
import 'package:gallery/features/shell/ui/widgets/nav_count.dart';
import 'package:gallery/features/shell/ui/widgets/nav_item.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A collapsible group of nav links with a chevron and a count.
///
/// Mirrors `NavGroup` in upstream `src/docs/kit/Nav.tsx`.
class NavGroup extends StatelessWidget {
  const NavGroup({
    super.key,
    required this.label,
    required this.count,
    required this.open,
    required this.onToggle,
    required this.children,
  });

  final String label;
  final int count;
  final bool open;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        expanded: open,
        child: NavItem(
          label: label,
          active: false,
          onPressed: onToggle,
          leading: AnimatedRotation(
            turns: switch (open) {
              true => 0,
              false => -0.25,
            },
            duration: InkMotion.of(context, InkMotion.hover),
            child: const InkIcon('chevron-down', size: Spacing.d14),
          ),
          trailing: NavCount(count),
        ),
      ),
      AnimatedSize(
        duration: InkMotion.of(context, InkMotion.fade),
        curve: InkMotion.easeOut,
        alignment: AlignmentDirectional.topStart,
        child: switch (open) {
          true => Padding(
            padding: const EdgeInsetsDirectional.only(start: Spacing.d16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          false => const SizedBox(width: double.infinity),
        },
      ),
    ],
  );
}
