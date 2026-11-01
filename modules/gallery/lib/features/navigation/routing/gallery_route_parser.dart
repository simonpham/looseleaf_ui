import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';

/// Turns URLs into [GalleryRoute]s and back.
class GalleryRouteParser extends RouteInformationParser<GalleryRoute> {
  const GalleryRouteParser();

  @override
  Future<GalleryRoute> parseRouteInformation(
    RouteInformation routeInformation,
  ) => SynchronousFuture(GalleryRoute.parse(routeInformation.uri.path));

  @override
  RouteInformation restoreRouteInformation(GalleryRoute configuration) =>
      RouteInformation(uri: Uri(path: configuration.path));
}
