import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/gallery.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(InkTextures.instance.load());
  runApp(const GalleryApp());
}
