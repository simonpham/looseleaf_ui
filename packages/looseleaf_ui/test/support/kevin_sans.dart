import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled fonts, the Kevin Sans faces and IBM Plex Mono, so
/// widget text and code render in the real fonts instead of the test font.
Future<void> loadKevinSans() async {
  final hand = FontLoader('packages/looseleaf_ui/KevinSans');
  for (final face in ['Regular', 'Bold']) {
    hand.addFont(_font('KevinSans-$face.ttf'));
  }
  final mono = FontLoader('packages/looseleaf_ui/IBMPlexMono')
    ..addFont(_font('IBMPlexMono-Regular.ttf'));
  await Future.wait([hand.load(), mono.load()]);
}

Future<ByteData> _font(String file) => Future.value(
  ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
);
