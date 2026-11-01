import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';

/// Shows the shell for the [NavigationViewModel]'s route and keeps the URL
/// in step with it.
class GalleryRouterDelegate extends RouterDelegate<GalleryRoute>
    with ChangeNotifier {
  GalleryRouterDelegate({required this.navigation, required this.builder}) {
    navigation.addListener(notifyListeners);
  }

  final NavigationViewModel navigation;
  final WidgetBuilder builder;

  @override
  GalleryRoute get currentConfiguration => navigation.route;

  @override
  Future<void> setNewRoutePath(GalleryRoute configuration) {
    navigation.go(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  @override
  Widget build(BuildContext context) => Builder(builder: builder);

  @override
  void dispose() {
    navigation.removeListener(notifyListeners);
    super.dispose();
  }
}
