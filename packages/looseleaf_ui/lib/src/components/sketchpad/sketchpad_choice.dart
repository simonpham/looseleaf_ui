import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// One choice of a sketchpad picker (a tool, a color, a width): a radio
/// in an [InkRovingFocus] group, drawn by [source], checked when
/// [checked]. Arrowing onto it picks it, as in a Radix radio group.
///
/// The shared body of [SketchpadTool], [SketchpadColor] and
/// [SketchpadSize] in upstream `src/components/ui/sketchpad.tsx`.
class SketchpadChoice extends StatefulWidget {
  const SketchpadChoice({
    super.key,
    required this.source,
    required this.checked,
    required this.onSelected,
    required this.semanticLabel,
    required this.child,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  final InkSource source;
  final bool checked;
  final VoidCallback onSelected;
  final String semanticLabel;

  /// The choice's box and content.
  final Widget child;
  final bool disabled;
  final String? seed;
  final FocusNode? focusNode;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<SketchpadChoice> createState() => _SketchpadChoiceState();
}

class _SketchpadChoiceState extends State<SketchpadChoice> with InkSeed {
  FocusNode? _ownFocusNode;
  late InkRovingEntry _entry = InkRovingEntry(_focusNode);
  InkRovingFocusState? _roving;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final roving = InkRovingFocus.maybeOf(context);
    if (identical(roving, _roving)) return;
    _roving?.unregister(_entry);
    _roving = roving;
    roving?.register(_entry);
  }

  @override
  void didUpdateWidget(SketchpadChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(_entry.focusNode, _focusNode)) return;
    _roving?.unregister(_entry);
    _entry = InkRovingEntry(_focusNode);
    _roving?.register(_entry);
  }

  @override
  void dispose() {
    _roving?.unregister(_entry);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.disabled;
    final entry = _entry;
    if (entry.active != widget.checked || entry.enabled == disabled) {
      entry
        ..active = widget.checked
        ..enabled = !disabled;
      _roving?.markChanged();
    }
    entry.onArrive = switch (disabled) {
      true => null,
      false => widget.onSelected,
    };
    return Semantics(
      container: true,
      checked: widget.checked,
      inMutuallyExclusiveGroup: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: widget.onSelected,
        activation: InkActivation.toggle,
        states: {...widget.forcedStates, if (widget.checked) InkState.checked},
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        builder: (context, states) => InkSurface(
          source: widget.source,
          seed: inkSeed(widget.seed),
          states: states,
          child: ExcludeSemantics(child: widget.child),
        ),
      ),
    );
  }
}
