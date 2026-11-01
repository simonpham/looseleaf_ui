import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A heading in a menu, in the typewriter face and muted ink, like the
/// kicker of a form. [inset] lines it up with ticked rows.
///
/// Mirrors `MENU_LABEL` in upstream `src/lib/menu-styles.ts`.
class InkMenuLabel extends StatelessWidget {
  const InkMenuLabel({super.key, required this.child, this.inset = false});

  /// The heading.
  final Widget child;

  /// Lines the text up with ticked rows.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final vertical = InkMenuMetrics.labelPadding.of(context);
    return Semantics(
      container: true,
      header: true,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: switch (inset) {
            true => InkMenuMetrics.inset,
            false => InkMenuMetrics.rowInline,
          },
          end: InkMenuMetrics.rowInline,
          top: vertical,
          bottom: vertical,
        ),
        child: DefaultTextStyle.merge(
          style: InkMenuMetrics.label(theme),
          child: child,
        ),
      ),
    );
  }
}
