import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The page beside the pad: always a sheet of paper. Beside a floating or
/// inset pad it is set in from the desk's edges on wider screens; beside a
/// docked one it runs edge to edge.
///
/// Mirrors `PageSheet` in upstream
/// `src/blocks/sidebar-shared/sidebar-page.tsx`.
class SidebarPageSheet extends StatelessWidget {
  const SidebarPageSheet({
    super.key,
    required this.children,
    this.variant = SidebarVariant.sidebar,
    this.seed = 'sidebar-page',
  });

  /// The header and the body, top to bottom.
  final List<Widget> children;

  /// The variant of the pad beside it.
  final SidebarVariant variant;

  /// Pins the paper's tooth.
  final String seed;

  @override
  Widget build(BuildContext context) {
    final isMobile = SidebarProvider.maybeOf(context)?.isMobile ?? false;
    final page = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    if (!isMobile && variant != SidebarVariant.sidebar) {
      return SidebarInset(sheet: true, seed: seed, child: page);
    }
    return SidebarInset(
      sheet: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PaperBackground(
            stock: StockName.paper,
            tilt: false,
            seed: seed,
          ),
          page,
        ],
      ),
    );
  }
}
