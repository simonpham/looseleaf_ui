import 'package:flutter/foundation.dart';
import 'package:gallery/features/navigation/models/models.dart';

/// The page on show and whether the phone nav drawer is open.
class NavigationViewModel extends ChangeNotifier {
  NavigationViewModel([GalleryRoute initial = const HomeRoute()])
    : _route = initial;

  GalleryRoute _route;
  bool _drawerOpen = false;
  bool _navHidden = false;
  final Set<String> _openGroups = {};

  GalleryRoute get route => _route;

  /// Whether the nav drawer is open (phone layout).
  bool get drawerOpen => _drawerOpen;

  /// Whether the side nav is hidden (wide layout).
  bool get navHidden => _navHidden;

  /// Shows [route] and closes the drawer.
  void go(GalleryRoute route) {
    if (route == _route && !_drawerOpen) return;
    _route = route;
    _drawerOpen = false;
    notifyListeners();
  }

  void setDrawerOpen(bool open) {
    if (open == _drawerOpen) return;
    _drawerOpen = open;
    notifyListeners();
  }

  /// Whether the nav group [id] was opened by hand.
  bool groupOpen(String id) => _openGroups.contains(id);

  /// The nav groups opened by hand.
  Set<String> get openGroups => Set.unmodifiable(_openGroups);

  void toggleGroup(String id) {
    if (!_openGroups.remove(id)) _openGroups.add(id);
    notifyListeners();
  }

  void toggleNav() {
    _navHidden = !_navHidden;
    notifyListeners();
  }
}
