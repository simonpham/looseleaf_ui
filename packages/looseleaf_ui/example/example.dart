import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(InkTextures.instance.load());
  runApp(
    LooseleafTheme(
      data: const LooseleafThemeData(),
      child: WidgetsApp(
        color: const Color(0xFFE0703C),
        builder: (context, _) => Desk(
          child: Center(
            child: Button(onPressed: () {}, child: const Text('Save changes')),
          ),
        ),
      ),
    ),
  );
}
