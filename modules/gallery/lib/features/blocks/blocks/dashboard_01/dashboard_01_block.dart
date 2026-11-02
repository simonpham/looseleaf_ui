import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The classic admin page: an inset sidebar, four numbers, an area chart
/// you can re-cut by date and a table of sections you can select, hide
/// columns from, page through and edit.
///
/// Mirrors upstream `src/blocks/dashboard-01/page.tsx`.
class Dashboard01Block extends StatelessWidget {
  const Dashboard01Block({super.key});

  static const double _height = 780;
  static const double _sidebarWidth = 288;

  /// Upstream's `md` and `lg` windows, less the sidebar.
  static const double _wideFrom = 480;
  static const double _roomyFrom = 720;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: SidebarProvider(
      width: _sidebarWidth,
      children: [
        const Dashboard01AppSidebar(),
        SidebarPageSheet(
          variant: SidebarVariant.inset,
          seed: 'dashboard-01-sheet',
          children: [
            const Dashboard01SiteHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final roomy = width >= _roomyFrom;
                  final gap = switch (width >= _wideFrom) {
                    true => Spacing.d24,
                    false => Spacing.d16,
                  };
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: gap),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: gap,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: switch (roomy) {
                              true => Spacing.d24,
                              false => Spacing.d16,
                            },
                          ),
                          child: const Dashboard01SectionCards(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: switch (roomy) {
                              true => Spacing.d24,
                              false => Spacing.d16,
                            },
                          ),
                          child: const Dashboard01VisitorsChart(),
                        ),
                        const Dashboard01DataTable(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
