import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The strip across the whole window: the sidebar trigger, the trail
/// (from small screens up) and a search box, on paper with a pencil rule
/// under it.
///
/// Mirrors upstream `src/blocks/sidebar-16/components/sidebar-16-site-header.tsx`.
class Sidebar16SiteHeader extends StatelessWidget {
  const Sidebar16SiteHeader({super.key});

  /// `--header-height`.
  static const double height = Spacing.d56;

  /// Tailwind's `sm`.
  static const double _smallWidth = 640;

  static const double _searchWidth = 224;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= _smallWidth;
    const search = SearchForm(bar: true, placeholder: 'Type to search...');
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const PaperBackground(
            stock: StockName.paper,
            shadow: PaperShadow.hair,
            tilt: false,
            seed: 'sidebar-16-header',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: Row(
              spacing: Spacing.d8,
              children: [
                const SidebarTrigger(),
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: Spacing.d8),
                  child: SizedBox(
                    height: Spacing.d16,
                    child: Separator(
                      orientation: SeparatorOrientation.vertical,
                    ),
                  ),
                ),
                if (wide) ...[
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Breadcrumb(
                        child: BreadcrumbList(
                          children: [
                            BreadcrumbItem(
                              children: [
                                BreadcrumbLink(
                                  onPressed: () {},
                                  child: Text(docsTrail.first),
                                ),
                              ],
                            ),
                            const BreadcrumbSeparator(),
                            BreadcrumbItem(
                              children: [
                                BreadcrumbPage(child: Text(docsTrail.last)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _searchWidth, child: search),
                ],
                if (!wide) const Expanded(child: search),
              ],
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: Separator()),
        ],
      ),
    );
  }
}
