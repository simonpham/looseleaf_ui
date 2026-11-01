import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// [child] on paper inside a [WidgetsApp], so focus, the app's shortcuts
/// and the Looseleaf theme are all in place.
Widget componentHost(
  Widget child, {
  LooseleafThemeData theme = const LooseleafThemeData(),
}) => LooseleafTheme(
  data: theme,
  child: WidgetsApp(
    color: theme.colors.paper,
    debugShowCheckedModeBanner: false,
    builder: (context, _) => ColoredBox(
      color: theme.colors.paper,
      child: DefaultTextStyle(
        style: theme.typography.interface(color: theme.colors.ink),
        child: Center(child: child),
      ),
    ),
  ),
);

/// [child] on a paper panel with [Spacing.d24] around it, for goldens.
Widget goldenPanel(Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.paper,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: IntrinsicWidth(child: IntrinsicHeight(child: child)),
    ),
  ),
);
