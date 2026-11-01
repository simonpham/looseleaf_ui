import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import 'component_host.dart';

/// [componentHost] with an [Overlay] around [child], as a navigator gives
/// a real app: text fields and popups need one.
Widget overlayHost(
  Widget child, {
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => componentHost(
  Overlay(
    initialEntries: [
      OverlayEntry(builder: (context) => Center(child: child)),
    ],
  ),
  theme: theme,
);
