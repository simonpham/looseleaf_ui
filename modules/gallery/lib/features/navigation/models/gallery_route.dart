/// A page of the gallery, upstream `Route` (`src/docs/core/router-core.ts`).
sealed class GalleryRoute {
  const GalleryRoute();

  /// The route at [path]; [NotFoundRoute] when nothing matches.
  factory GalleryRoute.parse(String path) {
    final segments = [
      for (final segment in path.split('/'))
        if (segment.isNotEmpty) segment,
    ];
    return switch (segments) {
      [] => const HomeRoute(),
      ['getting-started'] => const GettingStartedRoute(),
      ['foundations'] => const FoundationsRoute(),
      ['foundations', final topic] => FoundationsRoute(topic),
      ['components'] => const ComponentsRoute(),
      ['components', final slug] => ComponentsRoute(slug),
      ['blocks'] => const BlocksRoute(),
      ['blocks', final slug] => BlocksRoute(slug),
      _ => NotFoundRoute(path),
    };
  }

  /// The URL path of this route.
  String get path;

  @override
  bool operator ==(Object other) =>
      other is GalleryRoute &&
      other.runtimeType == runtimeType &&
      other.path == path;

  @override
  int get hashCode => path.hashCode;
}

class HomeRoute extends GalleryRoute {
  const HomeRoute();

  @override
  String get path => '/';
}

class GettingStartedRoute extends GalleryRoute {
  const GettingStartedRoute();

  @override
  String get path => '/getting-started';
}

/// The foundations index, or one [topic] of it.
class FoundationsRoute extends GalleryRoute {
  const FoundationsRoute([this.topic]);

  final String? topic;

  @override
  String get path => _join('/foundations', topic);
}

/// The components index, or the page of component [slug].
class ComponentsRoute extends GalleryRoute {
  const ComponentsRoute([this.slug]);

  final String? slug;

  @override
  String get path => _join('/components', slug);
}

/// The blocks index, or the page of block [slug].
class BlocksRoute extends GalleryRoute {
  const BlocksRoute([this.slug]);

  final String? slug;

  @override
  String get path => _join('/blocks', slug);
}

class NotFoundRoute extends GalleryRoute {
  const NotFoundRoute(this.path);

  @override
  final String path;
}

String _join(String base, String? leaf) => switch (leaf) {
  null => base,
  final name => '$base/$name',
};
