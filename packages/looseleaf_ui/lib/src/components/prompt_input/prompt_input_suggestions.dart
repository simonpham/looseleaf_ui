import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The choices for the trigger word being typed, on a flat slip just above
/// the composer. It shows while a trigger is typed ([trigger] limits it to
/// one character), or as [open] says. The composer knows no data: read
/// `PromptInputModel.of(context).trigger` and build the matching
/// [PromptInputSuggestion]s.
///
/// Mirrors `PromptInputSuggestions` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputSuggestions extends StatefulWidget {
  const PromptInputSuggestions({
    super.key,
    required this.children,
    this.trigger,
    this.open,
    this.semanticLabel = 'Suggestions',
  });

  /// The [PromptInputSuggestion]s.
  final List<Widget> children;

  /// Only for this trigger character.
  final String? trigger;

  /// Shows or hides the list whatever is typed.
  final bool? open;

  /// The list's accessible name.
  final String semanticLabel;

  @override
  State<PromptInputSuggestions> createState() => _PromptInputSuggestionsState();
}

class _PromptInputSuggestionsState extends State<PromptInputSuggestions> {
  final OverlayPortalController _portal = OverlayPortalController();
  PromptInputModel? _model;

  /// `max-h-60`.
  static const double _maxHeight = 240;

  /// `inset-x-2`.
  static const double _inset = Spacing.d8;

  /// `mb-3`.
  static const double _gap = Spacing.d12;

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  void dispose() {
    _model?.clearOptions(this);
    super.dispose();
  }

  bool _shows(PromptInputModel model) {
    if (widget.open case final open?) return open;
    final active = model.trigger;
    if (active == null) return false;
    return widget.trigger == null || active.char == widget.trigger;
  }

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    _model = model;
    final show = _shows(model);
    if (show) {
      model.setOptions(this, [
        for (final child in widget.children)
          switch (child) {
            PromptInputSuggestion(:final onSelect, :final disabled) => (
              onSelect: onSelect,
              disabled: disabled,
            ),
            _ => (onSelect: null, disabled: true),
          },
      ]);
    }
    if (!show) model.clearOptions(this);
    final anchor = PromptInputAnchor.of(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        if (!show) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: anchor.link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.bottomLeft,
            offset: const Offset(_inset, -_gap),
            child: TextFieldTapRegion(
              child: SizedBox(
                width: anchor.width - 2 * _inset,
                child: _list(model),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _list(PromptInputModel model) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: widget.semanticLabel,
    child: Paper(
      stock: StockName.slip,
      tilt: false,
      padding: const EdgeInsets.all(Spacing.d6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, child) in widget.children.indexed)
                PromptInputSuggestionIndex(index: index, child: child),
            ],
          ),
        ),
      ),
    ),
  );
}
