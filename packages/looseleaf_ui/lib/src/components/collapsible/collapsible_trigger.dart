import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible_scope.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible_widget.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';

/// Toggles the nearest [Collapsible]: tap, Enter or Space, announced as a
/// button that is expanded or collapsed.
///
/// With a plain [child], the trigger is that button and leaves [child]
/// unstyled. With [CollapsibleTrigger.builder], hand the collapsible to your
/// own control (a `Button`'s `onPressed: collapsible.toggle`), like
/// upstream's `asChild`: the control reports `expanded` on its own node.
///
/// ```dart
/// CollapsibleTrigger.builder(
///   builder: (context, collapsible) => Button(
///     variant: ButtonVariant.ghost,
///     onPressed: collapsible.toggle,
///     child: const Text('Toggle'),
///   ),
/// )
/// ```
///
/// Mirrors `CollapsibleTrigger` in upstream
/// `src/components/ui/collapsible.tsx`.
class CollapsibleTrigger extends StatelessWidget {
  /// A trigger that toggles on tap, Enter and Space around [child].
  const CollapsibleTrigger({
    super.key,
    required Widget this.child,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : builder = null;

  /// A trigger built around your own control.
  const CollapsibleTrigger.builder({super.key, required this.builder})
    : child = null,
      focusNode = null,
      autofocus = false,
      semanticLabel = null;

  /// The plain trigger's content.
  final Widget? child;

  /// Builds the trigger with the collapsible's state and `toggle`.
  final Widget Function(BuildContext context, CollapsibleScope collapsible)?
  builder;

  /// The plain trigger's focus node.
  final FocusNode? focusNode;

  /// Whether the plain trigger takes focus first.
  final bool autofocus;

  /// The accessible name when [child] is not text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = Collapsible.of(context);
    if (builder case final build?) {
      return InkTriggerSemantics(
        expanded: scope.open,
        child: Builder(builder: (context) => build(context, scope)),
      );
    }
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
        builder: (context, _) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}
