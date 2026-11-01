import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A chat composer on a napkin: the handwriting goes on a pencil line
/// ([PromptInputBody] holding a [PromptInputTextarea]), tools and a
/// paper-plane [PromptInputSubmit] sit in a [PromptInputFooter].
///
/// Enter sends (Shift+Enter breaks the line), the text clears and the
/// plane flies. While [status] is busy the submit is a stop button calling
/// [onStop]. [triggers] open [PromptInputSuggestions] as a word starting
/// with `@` or `/` is typed; arrows move through them, Enter or Tab picks,
/// Escape closes.
///
/// ```dart
/// PromptInput(
///   onSubmit: send,
///   children: [
///     PromptInputBody(child: PromptInputTextarea()),
///     PromptInputFooter(children: [
///       PromptInputHint(Text('Enter to send')),
///       PromptInputSubmit(),
///     ]),
///   ],
/// )
/// ```
///
/// Mirrors `PromptInput` in upstream `src/components/ui/prompt-input.tsx`.
class PromptInput extends StatefulWidget {
  const PromptInput({
    super.key,
    required this.children,
    this.onSubmit,
    this.controller,
    this.focusNode,
    this.onValueChange,
    this.status = PromptInputStatus.ready,
    this.onStop,
    this.disabled = false,
    this.allowEmpty = false,
    this.clearOnSubmit = true,
    this.lockWhileStreaming = false,
    this.submitOn = PromptInputSubmitOn.enter,
    this.triggers = const [],
    this.onTriggerChange,
    this.stock = StockName.napkin,
    this.seed,
  });

  /// Suggestions, attachments, the body and the footer, top to bottom.
  final List<Widget> children;

  /// Called with the text when it is sent.
  final ValueChanged<String>? onSubmit;

  /// Holds the text; one is made when null.
  final TextEditingController? controller;

  /// The textarea's focus; one is made when null.
  final FocusNode? focusNode;

  /// Called whenever the text changes.
  final ValueChanged<String>? onValueChange;

  final PromptInputStatus status;

  /// Called by the stop button while [status] is busy.
  final VoidCallback? onStop;

  /// No typing, no sending, a dashed line.
  final bool disabled;

  /// Lets an empty message be sent (attachments only).
  final bool allowEmpty;

  /// Clears the text after sending.
  final bool clearOnSubmit;

  /// Makes the text read-only while busy.
  final bool lockWhileStreaming;

  final PromptInputSubmitOn submitOn;

  /// The characters that open suggestions.
  final List<PromptInputTrigger> triggers;

  /// Called as the trigger word being typed changes, or goes away.
  final ValueChanged<PromptInputActiveTrigger?>? onTriggerChange;

  /// The paper it is written on.
  final StockName stock;

  /// Pins the paper's hand.
  final String? seed;

  @override
  State<PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<PromptInput> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  late PromptInputModel _model = _create();
  final LayerLink _link = LayerLink();
  String _text = '';

  PromptInputModel _create() {
    final controller =
        widget.controller ?? (_ownController ??= TextEditingController());
    final focus =
        widget.focusNode ??
        (_ownFocus ??= FocusNode(debugLabel: 'PromptInputTextarea'));
    _text = controller.text;
    return PromptInputModel(controller: controller, focusNode: focus)
      ..addListener(_onModel);
  }

  void _onModel() {
    final text = _model.value;
    if (text == _text) return;
    _text = text;
    widget.onValueChange?.call(text);
  }

  @override
  void didUpdateWidget(PromptInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final swapped =
        oldWidget.controller != widget.controller ||
        oldWidget.focusNode != widget.focusNode;
    if (!swapped) return;
    _model.dispose();
    _model = _create();
  }

  @override
  void dispose() {
    _model.dispose();
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit?.call(_model.value);
    _model.sent(clear: widget.clearOnSubmit);
  }

  @override
  Widget build(BuildContext context) {
    _model.configure(
      status: widget.status,
      disabled: widget.disabled,
      allowEmpty: widget.allowEmpty,
      lockWhileStreaming: widget.lockWhileStreaming,
      submitOn: widget.submitOn,
      triggers: widget.triggers,
      onSubmit: _submit,
      onStop: widget.onStop,
      onTriggerChange: widget.onTriggerChange,
    );
    final theme = LooseleafTheme.of(context);
    return PromptInputScope(
      model: _model,
      child: LayoutBuilder(
        builder: (context, constraints) => PromptInputAnchor(
          link: _link,
          width: constraints.maxWidth,
          child: CompositedTransformTarget(
            link: _link,
            child: Paper(
              stock: widget.stock,
              seed: widget.seed,
              padding: _padding(theme.density),
              child: DefaultTextStyle.merge(
                style: theme.typography.face(
                  KevinSansFace.hand,
                  color: theme.colors.ink,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d4,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `px-5 py-3 compact:px-4 compact:py-2.5 calm:px-3 calm:py-2`.
  static EdgeInsets _padding(LooseleafDensity density) => switch (density) {
    LooseleafDensity.comfortable => const EdgeInsets.symmetric(
      horizontal: Spacing.d20,
      vertical: Spacing.d12,
    ),
    LooseleafDensity.compact => const EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d10,
    ),
    LooseleafDensity.calm => const EdgeInsets.symmetric(
      horizontal: Spacing.d12,
      vertical: Spacing.d8,
    ),
  };
}
