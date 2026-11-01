import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible.dart';

/// The part of a [Collapsible] that opens and shuts: it unfolds over the
/// sheet duration and is not built while shut.
///
/// With a [bracket], a margin brace is written down its side and the text
/// soaks in when the user opens it.
///
/// Mirrors `CollapsibleContent` in upstream
/// `src/components/ui/collapsible.tsx`.
class CollapsibleContent extends StatelessWidget {
  const CollapsibleContent({super.key, required this.child, this.bracket});

  final Widget child;

  /// The margin bracket's shape; null draws none.
  final BracketKind? bracket;

  @override
  Widget build(BuildContext context) {
    final scope = Collapsible.of(context);
    return CollapsibleFold(
      open: scope.open,
      child: switch (bracket) {
        null => child,
        final kind => CollapsibleBracket(
          kind: kind,
          animate: scope.touched,
          child: CollapsibleSoak(play: true, child: child),
        ),
      },
    );
  }
}
