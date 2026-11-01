import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The scrolling middle of the pad, taking the height the header and
/// footer leave: a column of [children] 8 px apart. It does not scroll
/// when collapsed to icons. Put it straight in a [Sidebar]'s children.
///
/// Mirrors `SidebarContent` in upstream `src/components/ui/sidebar.tsx`.
class SidebarContent extends StatelessWidget {
  const SidebarContent({super.key, required this.children, this.controller});

  /// Usually [SidebarGroup]s.
  final List<Widget> children;

  /// Controls the scroll position.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final icons = SidebarPanelScope.iconsOf(context);
    return Expanded(
      child: ClipRect(
        child: SingleChildScrollView(
          controller: controller,
          physics: switch (icons) {
            true => const NeverScrollableScrollPhysics(),
            false => null,
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: children,
          ),
        ),
      ),
    );
  }
}
