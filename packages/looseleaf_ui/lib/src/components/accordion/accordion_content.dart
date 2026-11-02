import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/accordion/accordion_scope.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The text an [AccordionItem] opens to: small hand text that unfolds over
/// the sheet duration, beside the accordion's margin brace. Once the user
/// has opened a row, the brace is written on and the words soak in.
///
/// Mirrors `AccordionContent` in upstream `src/components/ui/accordion.tsx`.
class AccordionContent extends StatelessWidget {
  const AccordionContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: Spacing.d16),
  });

  final Widget child;

  /// The room round the words (upstream `pb-4`).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final accordion = AccordionScope.maybeOf(context);
    final open = AccordionItemScope.maybeOf(context)?.open ?? false;
    final touched = accordion?.touched ?? false;
    final theme = LooseleafTheme.of(context);
    final body = CollapsibleSoak(play: touched, child: child);
    return Semantics(
      container: true,
      child: CollapsibleFold(
        open: open,
        child: Padding(
          padding: padding,
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              cssLineHeight: 20 / 14,
            ),
            child: switch (accordion?.bracket) {
              null => body,
              final kind => CollapsibleBracket(
                kind: kind,
                animate: touched,
                child: body,
              ),
            },
          ),
        ),
      ),
    );
  }
}
