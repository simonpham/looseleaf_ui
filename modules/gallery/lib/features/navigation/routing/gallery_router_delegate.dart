import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';

/// Shows the shell for the [NavigationViewModel]'s route and keeps the URL
/// in step with it. The shell sits in an [Overlay], so popovers, menus and
/// dialogs have one to open in.
class GalleryRouterDelegate extends RouterDelegate<GalleryRoute>
    with ChangeNotifier {
  GalleryRouterDelegate({required this.navigation, required this.builder}) {
    navigation.addListener(notifyListeners);
  }

  final NavigationViewModel navigation;
  final WidgetBuilder builder;

  late final OverlayEntry _page = OverlayEntry(
    maintainState: true,
    builder: builder,
  );

  @override
  GalleryRoute get currentConfiguration => navigation.route;

  @override
  Future<void> setNewRoutePath(GalleryRoute configuration) {
    navigation.go(configuration);
    return SynchronousFuture(null);
  }

  @override
  Future<bool> popRoute() => SynchronousFuture(false);

  /// Keeps the one [Overlay] holding [_page] when the tree above it
  /// changes, as the widget inspector's select mode wraps the app: a new
  /// one would insert [_page] while the old one still holds it.
  final _overlay = GlobalKey<OverlayState>();

  @override
  Widget build(BuildContext context) =>
      Overlay(key: _overlay, initialEntries: [_page]);

  @override
  void dispose() {
    navigation.removeListener(notifyListeners);
    _page
      ..remove()
      ..dispose();
    super.dispose();
  }
}
