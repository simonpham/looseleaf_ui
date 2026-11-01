import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/gallery.dart';

/// Loads the bundled Kevin Sans faces and IBM Plex Mono so text renders in the real font.
Future<void> loadKevinSans() async {
  final loader = FontLoader('packages/looseleaf_ui/KevinSans');
  for (final face in ['Regular', 'Bold']) {
    final bytes = File(
      '../../packages/looseleaf_ui/assets/fonts/KevinSans-$face.ttf',
    ).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
  final mono = File(
    '../../packages/looseleaf_ui/assets/fonts/IBMPlexMono-Regular.ttf',
  ).readAsBytesSync();
  await (FontLoader(
    'packages/looseleaf_ui/IBMPlexMono',
  )..addFont(Future.value(ByteData.sublistView(mono)))).load();
}

/// Pumps the gallery at [route] in a window of [size] and lets it settle.
Future<void> pumpGallery(
  WidgetTester tester,
  GalleryRoute route, {
  Size size = const Size(1440, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GalleryApp(key: UniqueKey(), initialRoute: route));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 3));
}
