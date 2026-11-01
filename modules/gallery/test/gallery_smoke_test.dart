import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/features/blocks/catalog/catalog.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/foundations/docs/foundation_topics.dart';
import 'package:gallery/gallery.dart';

import 'support/gallery_host.dart';

void main() {
  final routes = <GalleryRoute>[
    const HomeRoute(),
    const GettingStartedRoute(),
    const FoundationsRoute(),
    for (final topic in foundationTopics) FoundationsRoute(topic.slug),
    const ComponentsRoute(),
    for (final doc in ComponentCatalog.components) ComponentsRoute(doc.slug),
    const BlocksRoute(),
    for (final doc in BlockCatalog.blocks) BlocksRoute(doc.slug),
    const ComponentsRoute('no-such-thing'),
  ];

  for (final route in routes) {
    testWidgets('${route.path} builds', (tester) async {
      await pumpGallery(tester, route);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the phone layout builds with its drawer', (tester) async {
    await pumpGallery(
      tester,
      const ComponentsRoute('button'),
      size: const Size(390, 844),
    );
    expect(tester.takeException(), isNull);
  });
}
