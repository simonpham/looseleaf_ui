import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible_widget.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';

/// Toggles the nearest [Collapsible]: tap, Enter or Space. A plain button
/// around [child], which it leaves unstyled; to use a [Button] instead,
/// call `Collapsible.of(context).toggle` from its `onPressed`.
///
/// Mirrors `CollapsibleTrigger` in upstream
/// `src/components/ui/collapsible.tsx`.
class CollapsibleTrigger extends StatelessWidget {
  const CollapsibleTrigger({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when [child] is not text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = Collapsible.of(context);
    return Semantics(
      container: true,
      button: true,
      expanded: scope.open,
      enabled: !scope.disabled,
      label: semanticLabel,
      child: InkInteraction(
        enabled: !scope.disabled,
        onActivate: scope.toggle,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, _) => child,
      ),
    );
  }
}
