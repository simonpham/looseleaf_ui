import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/catalog/catalog.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/foundations/docs/foundation_topics.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:gallery/features/shell/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

/// The documentation nav: Start, Foundations, Components by category
/// (collapsible) and Blocks, the current page lit.
///
/// Mirrors `SideNav` and `buildNav` in upstream `src/docs/shell/SideNav.tsx`
/// and `src/docs/core/nav.ts`.
class SideNavFrame extends StatelessWidget {
  const SideNavFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final route = context.select<NavigationViewModel, GalleryRoute>(
      (model) => model.route,
    );
    final openGroups = context.select<NavigationViewModel, Set<String>>(
      (model) => model.openGroups,
    );
    final topic = switch (route) {
      FoundationsRoute(:final topic) => topic,
      _ => null,
    };
    final component = switch (route) {
      ComponentsRoute(:final slug) => slug,
      _ => null,
    };
    final block = switch (route) {
      BlocksRoute(:final slug) => slug,
      _ => null,
    };
    void go(GalleryRoute target) => navigation.go(target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavSection(
          label: 'Start',
          children: [
            NavItem(
              label: 'Getting started',
              active: route is GettingStartedRoute,
              onPressed: () => go(const GettingStartedRoute()),
            ),
          ],
        ),
        NavSection(
          label: 'Foundations',
          active: route == const FoundationsRoute(),
          onPressed: () => go(const FoundationsRoute()),
          children: [
            for (final item in foundationTopics)
              NavItem(
                label: item.title,
                active: topic == item.slug,
                onPressed: () => go(FoundationsRoute(item.slug)),
              ),
          ],
        ),
        NavSection(
          label: 'Components',
          count: ComponentCatalog.components.length,
          active: route == const ComponentsRoute(),
          onPressed: () => go(const ComponentsRoute()),
          children: [
            for (final (category, docs) in ComponentCatalog.groups)
              NavGroup(
                label: category.label,
                count: docs.length,
                open:
                    openGroups.contains(category.name) ||
                    docs.any((doc) => doc.slug == component),
                onToggle: () => navigation.toggleGroup(category.name),
                children: [
                  for (final doc in docs)
                    NavItem(
                      label: doc.title,
                      nested: true,
                      active: component == doc.slug,
                      onPressed: () => go(ComponentsRoute(doc.slug)),
                    ),
                ],
              ),
          ],
        ),
        NavSection(
          label: 'Blocks',
          count: BlockCatalog.blocks.length,
          active: route == const BlocksRoute(),
          onPressed: () => go(const BlocksRoute()),
          children: [
            for (final doc in BlockCatalog.blocks)
              NavItem(
                label: doc.title,
                active: block == doc.slug,
                onPressed: () => go(BlocksRoute(doc.slug)),
              ),
          ],
        ),
      ],
    );
  }
}
