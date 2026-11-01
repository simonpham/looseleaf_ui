import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/notebook/notebook_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The button over a notebook's dog-ear: 34 px, always in the bottom
/// right corner as the fold is, above the page. Tap, Enter or Space turns
/// to the page [to] (after [onPressed]). Its [semanticLabel] is its name:
/// say where it goes ("Next: Tuesday"). Put it among a `Notebook`'s
/// children, next to the pages; pair it with the notebook's `curl`.
///
/// Mirrors `NotebookTurn` in upstream `src/components/ui/notebook.tsx`.
class NotebookTurn extends StatelessWidget {
  const NotebookTurn({
    super.key,
    this.to,
    this.onPressed,
    this.semanticLabel = 'Turn the page',
    this.child,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The corner's side.
  static const double size = 34;

  /// The page to turn to.
  final String? to;

  /// Called before turning.
  final VoidCallback? onPressed;

  /// The accessible name.
  final String semanticLabel;

  /// Your own content over the corner (upstream `asChild`); invisible when
  /// null, the fold being the drawing.
  final Widget? child;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input: for goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final scope = NotebookScope.maybeOf(context);
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel,
      child: InkInteraction(
        onActivate: () {
          onPressed?.call();
          if (to case final page?) scope?.onTurn(page);
        },
        states: forcedStates,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, states) => DecoratedBox(
          decoration: BoxDecoration(
            border: switch (states.contains(InkState.focused)) {
              true => Border.all(
                color: colors.focus,
                width: Spacing.d2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              false => null,
            },
          ),
          child: SizedBox.square(
            dimension: size,
            child: ExcludeSemantics(child: child),
          ),
        ),
      ),
    );
  }
}
