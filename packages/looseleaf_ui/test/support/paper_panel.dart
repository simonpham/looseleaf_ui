import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// [child] on a paper panel with [Spacing.d24] around it, for goldens of
/// layouts that wrap or flex: unlike `goldenPanel`, it sizes [child] by
/// layout instead of by intrinsic dimensions.
Widget paperPanel(Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.paper,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: child,
    ),
  ),
);
