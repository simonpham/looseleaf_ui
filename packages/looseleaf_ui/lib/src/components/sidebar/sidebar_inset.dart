import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The page beside the pad, taking the rest of the [SidebarProvider]'s row.
/// Beside a [SidebarVariant.inset] pad (not on phones) it is a flat sheet
/// of paper set 8 px in on the desk; otherwise it is clear.
///
/// Mirrors `SidebarInset` in upstream `src/components/ui/sidebar.tsx`.
class SidebarInset extends StatelessWidget {
  const SidebarInset({super.key, required this.child, this.sheet, this.seed});

  /// The page.
  final Widget child;

  /// Forces the sheet on or off; beside an inset pad only when null
  /// (upstream's `before:block`).
  final bool? sheet;

  /// Pins the sheet's tooth.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SidebarScope>();
    final data = scope?.data;
    final variant = scope?.dockedVariant;
    if (variant == null || data == null) {
      return Expanded(child: _page(sheet ?? false, collapsed: false));
    }
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: variant,
        builder: (context, docked, _) => _page(
          sheet ?? (docked == SidebarVariant.inset && !data.isMobile),
          collapsed: !data.open,
        ),
      ),
    );
  }

  Widget _page(bool sheet, {required bool collapsed}) {
    final page = Semantics(
      container: true,
      explicitChildNodes: true,
      child: child,
    );
    if (!sheet) return page;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: Spacing.d8,
        bottom: Spacing.d8,
        end: Spacing.d8,
        start: switch (collapsed) {
          true => Spacing.d8,
          false => 0,
        },
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PaperBackground(
            stock: StockName.paper,
            tilt: false,
            seed: seed ?? 'sidebar-inset',
          ),
          page,
        ],
      ),
    );
  }
}
