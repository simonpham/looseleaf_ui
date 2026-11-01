import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/catalog/catalog.dart';
import 'package:gallery/features/blocks/ui/pages/pages.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/ui/pages/pages.dart';
import 'package:gallery/features/foundations/docs/foundation_topics.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:gallery/features/foundations/ui/pages/pages.dart';
import 'package:gallery/features/getting_started/ui/pages/pages.dart';
import 'package:gallery/features/home/ui/pages/pages.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:gallery/features/not_found/ui/pages/pages.dart';
import 'package:provider/provider.dart';

/// The page for the current route.
///
/// Mirrors `Outlet` in upstream `src/docs/shell/Outlet.tsx`.
class OutletFrame extends StatelessWidget {
  const OutletFrame({super.key});

  /// The page [route] shows.
  static Widget pageFor(GalleryRoute route) => switch (route) {
    HomeRoute() => const HomePage(),
    GettingStartedRoute() => const GettingStartedPage(),
    FoundationsRoute(topic: null) => const FoundationsPage(),
    FoundationsRoute(:final topic?) => switch (_topic(topic)) {
      final found? => FoundationsPage(topic: found),
      null => NotFoundPage(what: 'topic', missing: topic),
    },
    ComponentsRoute(slug: null) => const ComponentsIndexPage(),
    ComponentsRoute(:final slug?) => switch (ComponentCatalog.bySlug(slug)) {
      final doc? => ComponentPage(key: ValueKey(slug), doc: doc),
      null => NotFoundPage(what: 'component', missing: slug),
    },
    BlocksRoute(slug: null) => const BlocksPage(),
    BlocksRoute(:final slug?) => switch (BlockCatalog.bySlug(slug)) {
      (final doc, final block)? => BlockPage(doc: doc, block: block),
      null => NotFoundPage(what: 'block', missing: slug),
    },
    NotFoundRoute(:final path) => NotFoundPage(missing: path),
  };

  static FoundationTopic? _topic(String slug) {
    for (final topic in foundationTopics) {
      if (topic.slug == slug) return topic;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => pageFor(
    context.select<NavigationViewModel, GalleryRoute>((model) => model.route),
  );
}
