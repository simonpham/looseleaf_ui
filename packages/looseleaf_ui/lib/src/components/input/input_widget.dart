import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A one-line text field: a pencil box on paper around an [InputControl],
/// with blue felt for what you type.
///
/// It draws its own hover, focus ring (whenever the field has focus, as
/// text fields always match `:focus-visible`), [invalid] (red pencil and a
/// `!`), [disabled] (dashes) and [readOnly] (printed) states. It fills the
/// width it is given (`w-full`).
///
/// ```dart
/// Input(placeholder: 'you@example.com', onChanged: (value) => email = value)
/// ```
///
/// Mirrors upstream `src/components/ui/input.tsx`.
class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.disabled = false,
    this.invalid = false,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.seed,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The text; a field made without one keeps its own.
  final TextEditingController? controller;

  final FocusNode? focusNode;

  /// Graphite text shown while the field is empty.
  final String? placeholder;

  /// Dashed pencil on a pale wash, graphite text, out of the tab order.
  final bool disabled;

  /// The red-pencil box, the wavy underline and the `!` mark (upstream
  /// `aria-invalid`), with room kept for the mark at the end of the line.
  final bool invalid;

  /// Focusable and selectable, drawn as a printed field: a pale wash and
  /// one quiet pencil line, no hover.
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
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;

  /// Pins the hand: the same seed always draws the same box.
  final String? seed;

  /// The accessible name, when no visible label names the field.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> with InkSeed {
  FocusNode? _ownFocusNode;
  bool _hovered = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.focusNode ?? _ownFocusNode;
    if (old == _focusNode) return;
    old?.removeListener(_onFocus);
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final params = InputParams(
      disabled: widget.disabled,
      invalid: widget.invalid,
      readOnly: widget.readOnly,
    );
    final enabled = !widget.disabled;
    final states = {
      ...widget.forcedStates,
      if (!enabled) InkState.disabled,
      if (widget.invalid) InkState.invalid,
      if (enabled && _hovered) InkState.hovered,
      if (enabled && _focusNode.hasFocus) InkState.focused,
    };
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DefaultTextStyle.merge(
        style: InputMetrics.text(theme, disabled: widget.disabled),
        child: InkSurface(
          source: RecipeInkSource(inputRecipe, params, json: params.toJson()),
          seed: inkSeed(widget.seed),
          states: states,
          still: true,
          child: SizedBox(
            height: InputMetrics.height.resolve(theme.density),
            child: InputControl(
              controller: widget.controller,
              focusNode: _focusNode,
              placeholder: widget.placeholder,
              disabled: widget.disabled,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              textAlign: widget.textAlign,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              semanticLabel: widget.semanticLabel,
              padding: InputMetrics.padding.copyWith(
                end: switch (widget.invalid) {
                  true => InputMetrics.invalidEnd,
                  false => InputMetrics.padding.end,
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
