import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/sidebar_shared/sidebar_shared.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The strip across the top of the page: the sidebar trigger, a
/// breadcrumb trail of [crumbs] (only the last one on phones) and any
/// [actions] at the end, with a pencil rule under it when [bordered].
///
/// Mirrors `PageHeader` in upstream
/// `src/blocks/sidebar-shared/sidebar-page.tsx`.
class SidebarPageHeader extends StatelessWidget {
  const SidebarPageHeader({
    super.key,
    required this.crumbs,
    this.bordered = false,
    this.trigger = PageTriggerSide.start,
    this.actions = const [],
    this.height,
  });

  final List<String> crumbs;
  final bool bordered;
  final PageTriggerSide trigger;

  /// Buttons at the end of the strip.
  final List<Widget> actions;

  /// Overrides the density's height (64, 56 compact, 48 calm).
  final double? height;

  /// Tailwind's `md`: from here the whole trail shows.
  static const double _mediumWidth = 768;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= _mediumWidth;
    final last = crumbs.length - 1;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
      child: Row(
        spacing: Spacing.d8,
        children: [
          if (trigger == PageTriggerSide.start) ...[
            const SidebarTrigger(),
            const Padding(
              padding: EdgeInsetsDirectional.only(end: Spacing.d8),
              child: SizedBox(
                height: Spacing.d16,
                child: Separator(orientation: SeparatorOrientation.vertical),
              ),
            ),
          ],
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Breadcrumb(
                child: BreadcrumbList(
                  children: [
                    if (wide)
                      for (final crumb in crumbs.take(last)) ...[
                        BreadcrumbItem(
                          children: [
                            BreadcrumbLink(
                              onPressed: () {},
                              child: Text(crumb),
                            ),
                          ],
                        ),
                        const BreadcrumbSeparator(),
                      ],
                    BreadcrumbItem(
                      children: [
                        Flexible(
                          child: BreadcrumbPage(
                            child: Text(
                              crumbs[last],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...actions,
          if (trigger == PageTriggerSide.end) const SidebarTrigger(),
        ],
      ),
    );
    return SizedBox(
      height:
          height ??
          switch (theme.density) {
            LooseleafDensity.comfortable => Spacing.d64,
            LooseleafDensity.compact => Spacing.d56,
            LooseleafDensity.calm => Spacing.d48,
          },
      child: Stack(
        fit: StackFit.expand,
        children: [
          row,
          if (bordered)
            const Positioned(left: 0, right: 0, bottom: 0, child: Separator()),
        ],
      ),
    );
  }
}
