import 'package:flutter/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/routing/routing.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:gallery/features/shell/ui/frames/frames.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The Looseleaf UI gallery: every component and block with its examples,
/// the Flutter twin of upstream's docs site (`src/docs/App.tsx`).
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, this.initialRoute = const HomeRoute()});

  /// The page shown first when the platform gives no URL.
  final GalleryRoute initialRoute;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late final NavigationViewModel _navigation = NavigationViewModel(
    widget.initialRoute,
  );
  final SettingsViewModel _settings = SettingsViewModel();
  late final GalleryRouterDelegate _delegate = GalleryRouterDelegate(
    navigation: _navigation,
    builder: (context) => const ShellFrame(),
  );
  late final PlatformRouteInformationProvider _routeInformation =
      PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri(path: widget.initialRoute.path),
        ),
      );

  @override
  void dispose() {
    _delegate.dispose();
    _routeInformation.dispose();
    _navigation.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: _navigation),
      ChangeNotifierProvider.value(value: _settings),
    ],
    child: ThemeFrame(
      child: Builder(
        builder: (context) => WidgetsApp.router(
          title: 'Looseleaf UI',
          color: LooseleafTheme.of(context).colors.marker,
          debugShowCheckedModeBanner: false,
          routerDelegate: _delegate,
          routeInformationParser: const GalleryRouteParser(),
          routeInformationProvider: _routeInformation,
        ),
      ),
    ),
  );
}
