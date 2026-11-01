import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A nested list under a row: indented [SidebarMenuSubItem]s with a pencil
/// line drawn down its start edge. Hidden when collapsed to icons.
///
/// Mirrors `SidebarMenuSub` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuSub extends StatefulWidget {
  const SidebarMenuSub({super.key, required this.children, this.seed});

  /// The sub-rows.
  final List<Widget> children;

  /// Pins the line.
  final String? seed;

  @override
  State<SidebarMenuSub> createState() => _SidebarMenuSubState();
}

class _SidebarMenuSubState extends State<SidebarMenuSub> with InkSeed {
  static final InkSource _rule = RecipeInkSource(
    sidebarRuleRecipe,
    const NoParams(),
  );

  @override
  Widget build(BuildContext context) {
    if (SidebarPanelScope.iconsOf(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d14),
      child: InkSurface(
        source: _rule,
        seed: inkSeed(widget.seed),
        still: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d10,
            vertical: Spacing.d2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d4,
            children: widget.children,
          ),
        ),
      ),
    );
  }
}
