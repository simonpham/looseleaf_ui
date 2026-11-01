import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled Kevin Sans faces so widget text renders in the real
/// font instead of the test font.
Future<void> loadKevinSans() async {
  final loader = FontLoader('packages/looseleaf_ui/KevinSans');
  for (final face in ['Regular', 'Bold']) {
    final bytes = File('assets/fonts/KevinSans-$face.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
