import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input_metrics.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The bare text control: Flutter's [EditableText] with Looseleaf's
/// typography, blue felt caret and highlighter selection, a graphite
/// [placeholder], and no drawing.
///
/// [Input] draws its box around one; composites that draw the box
/// themselves (an input group, a search bar, a combobox) use it directly.
/// The text style comes from the ambient [DefaultTextStyle], so the frame
/// decides the size and color.
///
/// Mirrors `InputControl` in upstream `src/components/ui/input.tsx`.
class InputControl extends StatefulWidget {
  const InputControl({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.disabled = false,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.padding = InputMetrics.padding,
    this.alignment = AlignmentDirectional.centerStart,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.semanticLabel,
  });

  /// The text; a control made without one keeps its own.
  final TextEditingController? controller;

  final FocusNode? focusNode;

  /// Graphite text shown while the field is empty.
  final String? placeholder;

  /// Graphite text, no editing, out of the tab order.
  final bool disabled;

  /// Focusable and selectable, not editable.
  final bool readOnly;

  /// Hides the text, for passwords.
  final bool obscureText;

  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  /// Lines shown at most; null grows without limit.
  final int? maxLines;

  /// Lines shown at least.
  final int? minLines;

  /// The inset around the text (upstream `px-3 py-1`).
  final EdgeInsetsGeometry padding;

  /// Where the text and the placeholder sit in the box.
  final AlignmentGeometry alignment;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  /// The accessible name, when no visible label names the field.
  final String? semanticLabel;

  @override
  State<InputControl> createState() => _InputControlState();
}

class _InputControlState extends State<InputControl>
    implements TextSelectionGestureDetectorBuilderDelegate {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => !widget.disabled;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _syncFocusable();
  }

  @override
  void didUpdateWidget(InputControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusable();
  }

  void _syncFocusable() {
    _focusNode.canRequestFocus = !widget.disabled;
    if (widget.disabled && _focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final style = DefaultTextStyle.of(context).style;
    final multiline = widget.maxLines != 1;
    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly || widget.disabled,
      obscureText: widget.obscureText,
      obscuringCharacter: '•',
      autofocus: widget.autofocus,
      style: style,
      strutStyle: StrutStyle.fromTextStyle(style, forceStrutHeight: true),
      textAlign: widget.textAlign,
      cursorColor: colors.caret,
      backgroundCursorColor: colors.pencilMark,
      selectionColor: colors.hiSelect,
      selectionControls: emptyTextSelectionControls,
      enableInteractiveSelection: !widget.disabled,
      rendererIgnoresPointer: true,
      keyboardType:
          widget.keyboardType ??
          switch (multiline) {
            true => TextInputType.multiline,
            false => TextInputType.text,
          },
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );
    final placeholder = widget.placeholder;
    return Semantics(
      label: widget.semanticLabel,
      hint: placeholder,
      enabled: !widget.disabled,
      child: IgnorePointer(
        ignoring: widget.disabled,
        child: MouseRegion(
          cursor: switch (widget.disabled) {
            true => SystemMouseCursors.forbidden,
            false => SystemMouseCursors.text,
          },
          child: _gestures.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: widget.padding,
              child: Stack(
                alignment: widget.alignment,
                children: [
                  if (placeholder != null)
                    ExcludeSemantics(
                      child: ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, value, _) => Visibility(
                          visible: value.text.isEmpty,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Text(
                            placeholder,
                            style: style.copyWith(color: colors.placeholder),
                            textAlign: widget.textAlign,
                            maxLines: widget.maxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  editable,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
