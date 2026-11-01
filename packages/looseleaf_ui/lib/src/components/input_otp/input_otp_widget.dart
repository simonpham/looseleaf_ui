import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_metrics.dart';
import 'package:looseleaf_ui/src/components/input_otp/input_otp_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A one-time-code field: one hidden text field drawn as a row of boxes,
/// [InputOTPSlot]s in [InputOTPGroup]s with [InputOTPSeparator]s between.
///
/// Typing fills the boxes left to right, Backspace empties them, a paste
/// fills them all (spaces and dashes dropped). [pattern] filters what can
/// be typed; [onComplete] runs once [maxLength] characters are in. Tapping
/// anywhere on the row focuses it. Screen readers read one text field.
///
/// ```dart
/// InputOTP(
///   maxLength: 6,
///   pattern: InputOTPPattern.digits,
///   onComplete: verify,
///   children: const [
///     InputOTPGroup(children: [
///       InputOTPSlot(index: 0),
///       InputOTPSlot(index: 1),
///       InputOTPSlot(index: 2),
///     ]),
///     InputOTPSeparator(),
///     InputOTPGroup(children: [
///       InputOTPSlot(index: 3),
///       InputOTPSlot(index: 4),
///       InputOTPSlot(index: 5),
///     ]),
///   ],
/// )
/// ```
///
/// Mirrors `InputOTP` in upstream `src/components/ui/input-otp.tsx`.
class InputOTP extends StatefulWidget {
  const InputOTP({
    super.key,
    required this.maxLength,
    required this.children,
    this.controller,
    this.focusNode,
    this.pattern,
    this.placeholder = '',
    this.disabled = false,
    this.invalid = false,
    this.autofocus = false,
    this.onChanged,
    this.onComplete,
    this.semanticLabel,
  });

  /// How many characters the code has.
  final int maxLength;

  /// The groups, slots and separators.
  final List<Widget> children;

  /// The code; the field keeps its own when null.
  final TextEditingController? controller;

  final FocusNode? focusNode;

  /// What can be typed or pasted; anything when null.
  final InputOTPPattern? pattern;

  /// One graphite character per empty slot, like upstream `placeholder`.
  final String placeholder;

  /// Graphite boxes on a pale wash, no input.
  final bool disabled;

  /// Red-pencil boxes (upstream `invalid` / `aria-invalid`).
  final bool invalid;

  final bool autofocus;

  /// Called with the code on each change.
  final ValueChanged<String>? onChanged;

  /// Called with the code once it is [maxLength] long.
  final ValueChanged<String>? onComplete;

  /// The accessible name.
  final String? semanticLabel;

  @override
  State<InputOTP> createState() => _InputOTPState();
}

class _InputOTPState extends State<InputOTP> {
  static final RegExp _separators = RegExp('[\\s‐-―-]+');

  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _touched = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onChange);
    _controller.addListener(_onChange);
    _syncFocusable();
  }

  @override
  void didUpdateWidget(InputOTP oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldNode = oldWidget.focusNode ?? _ownFocusNode;
    if (oldNode != _focusNode) {
      oldNode?.removeListener(_onChange);
      _focusNode.addListener(_onChange);
    }
    final oldController = oldWidget.controller ?? _ownController;
    if (oldController != _controller) {
      oldController?.removeListener(_onChange);
      _controller.addListener(_onChange);
    }
    _syncFocusable();
  }

  void _syncFocusable() {
    _focusNode.canRequestFocus = !widget.disabled;
    if (widget.disabled && _focusNode.hasFocus) _focusNode.unfocus();
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onChange);
    _controller.removeListener(_onChange);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _changed(String value) {
    setState(() => _touched = true);
    widget.onChanged?.call(value);
    if (value.length == widget.maxLength) widget.onComplete?.call(value);
  }

  void _focus() {
    if (widget.disabled) return;
    _focusNode.requestFocus();
    final end = _controller.text.length;
    _controller.selection = TextSelection.collapsed(offset: end);
  }

  int? get _active {
    if (!_focusNode.hasFocus) return null;
    final offset = _controller.selection.baseOffset;
    final at = switch (offset < 0) {
      true => _controller.text.length,
      false => offset,
    };
    return at.clamp(0, widget.maxLength - 1);
  }

  List<TextInputFormatter> get _formatters => [
    TextInputFormatter.withFunction((oldValue, newValue) {
      final stripped = newValue.text.replaceAll(_separators, '');
      if (stripped == newValue.text) return newValue;
      return TextEditingValue(
        text: stripped,
        selection: TextSelection.collapsed(offset: stripped.length),
      );
    }),
    if (widget.pattern case final pattern?)
      FilteringTextInputFormatter.allow(RegExp(pattern.source)),
    LengthLimitingTextInputFormatter(widget.maxLength),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final otp = widget;
    final clear = theme.colors.ink.withValues(alpha: 0);
    final hidden = TextStyle(color: clear, fontSize: theme.typography.bodySize);
    final editable = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: otp.disabled,
      autofocus: otp.autofocus,
      style: hidden,
      cursorColor: clear,
      backgroundCursorColor: clear,
      showCursor: false,
      enableInteractiveSelection: false,
      rendererIgnoresPointer: true,
      keyboardType: switch (otp.pattern) {
        InputOTPPattern.digits => TextInputType.number,
        _ => TextInputType.text,
      },
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: _formatters,
      onChanged: _changed,
    );
    return Semantics(
      label: otp.semanticLabel,
      enabled: !otp.disabled,
      child: MouseRegion(
        cursor: switch (otp.disabled) {
          true => SystemMouseCursors.forbidden,
          false => SystemMouseCursors.text,
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: _focus,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRect(child: Opacity(opacity: 0, child: editable)),
              ),
              InputOTPScope(
                text: _controller.text,
                active: _active,
                focused: _focusNode.hasFocus,
                invalid: otp.invalid,
                disabled: otp.disabled,
                touched: _touched,
                placeholder: otp.placeholder,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: InputOTPMetrics.gap,
                  children: otp.children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
