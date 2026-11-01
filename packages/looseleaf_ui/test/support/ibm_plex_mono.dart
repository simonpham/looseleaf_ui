import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled IBM Plex Mono so code renders in the real font instead
/// of the test font.
Future<void> loadIbmPlexMono() async {
  final bytes = File('assets/fonts/IBMPlexMono-Regular.ttf').readAsBytesSync();
  final loader = FontLoader('packages/looseleaf_ui/IBMPlexMono')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
