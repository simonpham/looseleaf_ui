import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:gallery/features/shell/ui/frames/frames.dart';
import 'package:gallery/features/shell/ui/widgets/widgets.dart';
import 'package:gallery/gallery.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

import 'support/gallery_host.dart';

void main() {
  setUpAll(loadKevinSans);

  testWidgets('the widget inspector turns on and off over the gallery', (
    tester,
  ) async {
    await pumpGallery(tester, const HomeRoute());
    final inspector =
        WidgetsBinding.instance.debugShowWidgetInspectorOverrideNotifier;
    addTearDown(() => inspector.value = false);
    inspector.value = true;
    await tester.pump();
    inspector.value = false;
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(ShellFrame), findsOneWidget);
  });

  testWidgets('the side nav opens a component page', (tester) async {
    await pumpGallery(tester, const GettingStartedRoute());
    await tester.tap(find.text('Components').first);
    await tester.pump(const Duration(seconds: 1));
    final context = tester.element(find.byType(LooseleafTheme).first);
    expect(
      context.read<NavigationViewModel>().route,
      const ComponentsRoute(),
    );
  });

  testWidgets('the phone menu opens the drawer and a link closes it', (
    tester,
  ) async {
    await pumpGallery(
      tester,
      const HomeRoute(),
      size: const Size(390, 844),
    );
    final context = tester.element(find.byType(LooseleafTheme).first);
    final navigation = context.read<NavigationViewModel>();
    await tester.tap(find.bySemanticsLabel('Menu').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(navigation.drawerOpen, isTrue);
    await tester.tap(
      find.descendant(
        of: find.byType(NavDrawer),
        matching: find.text('Getting started'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(navigation.drawerOpen, isFalse);
    expect(navigation.route, const GettingStartedRoute());
  });

  testWidgets('display settings change the theme', (tester) async {
    await pumpGallery(tester, const GettingStartedRoute());
    await tester.tap(find.bySemanticsLabel('Display settings').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Calm'));
    await tester.pump(const Duration(seconds: 1));
    final context = tester.element(find.byType(LooseleafTheme).first);
    expect(context.read<SettingsViewModel>().density, LooseleafDensity.calm);
    expect(
      LooseleafTheme.of(
        tester.element(find.text('Getting started').last),
      ).density,
      LooseleafDensity.calm,
    );
  });

  test('routes parse their own paths', () {
    for (final route in const <GalleryRoute>[
      HomeRoute(),
      GettingStartedRoute(),
      FoundationsRoute('color'),
      ComponentsRoute('button'),
      BlocksRoute(),
    ]) {
      expect(GalleryRoute.parse(route.path), route);
    }
    expect(GalleryRoute.parse('/nope/x'), isA<NotFoundRoute>());
  });
}
