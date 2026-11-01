import 'package:flutter/widgets.dart';

/// Builds [builder] with its hover and keyboard-focus state, and calls
/// [onPressed] on a tap, Enter or Space. Used by links, tiles and nav rows.
class DocPressable extends StatefulWidget {
  const DocPressable({
    super.key,
    required this.onPressed,
    required this.builder,
    this.semanticLabel,
    this.selected = false,
  });

  final VoidCallback onPressed;
  final Widget Function(BuildContext context, bool highlighted) builder;
  final String? semanticLabel;

  /// Whether this is the current page, announced to screen readers.
  final bool selected;

  @override
  State<DocPressable> createState() => _DocPressableState();
}

class _DocPressableState extends State<DocPressable> {
  bool _hovered = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) {
        widget.onPressed();
        return null;
      },
    ),
  };

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    selected: widget.selected,
    label: widget.semanticLabel,
    child: FocusableActionDetector(
      actions: _actions,
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (hovered) => setState(() => _hovered = hovered),
      onShowFocusHighlight: (focused) => setState(() => _focused = focused),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: widget.builder(context, _hovered || _focused),
      ),
    ),
  );
}
