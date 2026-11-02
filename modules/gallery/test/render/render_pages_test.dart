import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/gallery.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/gallery_host.dart';

/// Renders gallery pages to PNG for a visual check:
/// `GALLERY_RENDER_DIR=/some/dir flutter test test/render`.
/// `GALLERY_RENDER_ROUTES` (comma separated paths) picks the pages.
void main() {
  final out = Platform.environment['GALLERY_RENDER_DIR'];
  final paths =
      Platform.environment['GALLERY_RENDER_ROUTES']?.split(',') ??
      const ['/', '/components', '/components/button'];
  final phone = Platform.environment['GALLERY_RENDER_PHONE'] == '1';

  setUpAll(() async {
    await loadKevinSans();
  });

  for (final path in paths) {
    testWidgets('render $path', skip: out == null, (tester) async {
      await tester.runAsync(InkTextures.instance.load);
      final size = switch (phone) {
        true => const ui.Size(390, 1600),
        false => const ui.Size(1440, 2200),
      };
      await pumpGallery(tester, GalleryRoute.parse(path), size: size);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pump(const Duration(seconds: 1));
      final view = tester.binding.renderViews.first;
      if (view.debugLayer case final OffsetLayer layer) {
        final image = await tester.runAsync(
          () => layer.toImage(Offset.zero & view.size),
        );
        final bytes = await tester.runAsync(
          () async => image?.toByteData(format: ui.ImageByteFormat.png),
        );
        if (bytes == null || out == null) return;
        final name = switch (path) {
          '/' => 'home',
          _ => path.substring(1).replaceAll('/', '_'),
        };
        final suffix = switch (phone) {
          true => '_phone',
          false => '',
        };
        File(
          '$out/$name$suffix.png',
        ).writeAsBytesSync(bytes.buffer.asUint8List());
      }
    });
  }
}
