import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A box to sign in: a slip of paper with a baseline and a sign-here
/// cross, drawn on with a brush that swells under pen pressure, or, with
/// [typedFallback], a field that sets the typed name in hand lettering.
///
/// The value is the signature as an image `data:` URL ([format] SVG or
/// PNG), empty while unsigned; [onChanged] hears it with the
/// [SignatureDetail] it came from. Give [value] to control it: a value
/// from outside shows as an image until the next stroke.
///
/// It is a form field: inside a [Form], [required] fails validation while
/// unsigned, shows [message] under a red baseline and moves focus to the
/// pad; resetting the form clears it. [invalid] shows the same error by
/// hand.
///
/// [child] replaces the default layout ([SignaturePadCanvas],
/// [SignaturePadTyped], then [SignaturePadClear] and
/// [SignaturePadModeToggle]).
///
/// ```dart
/// SignaturePad(
///   required: true,
///   onChanged: (value, detail) => signature = value,
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/signature-pad.tsx`.
class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    this.value,
    this.initialValue = '',
    this.onChanged,
    this.required = false,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.message = 'Please sign in the box.',
    this.mode,
    this.initialMode = SignatureMode.draw,
    this.onModeChanged,
    this.typedFallback = true,
    this.penColor = SketchColor.inkYou,
    this.pen = SignaturePen.brush,
    this.format = SignatureFormat.svg,
    this.width = 480,
    this.height = 180,
    this.seed,
    this.child,
  });

  /// The signature `data:` URL when controlled.
  final String? value;

  /// The starting value when not controlled.
  final String initialValue;

  /// Called with the new value and what it was made from.
  final void Function(String value, SignatureDetail detail)? onChanged;

  /// Fails form validation while unsigned.
  final bool required;
  final bool disabled;

  /// Shows the signature without input, buttons or the typed field.
  final bool readOnly;

  /// Shows [message] under a red baseline.
  final bool invalid;

  /// The error shown when invalid or unsigned on submit.
  final String message;

  /// The mode when controlled.
  final SignatureMode? mode;

  /// The starting mode when not controlled.
  final SignatureMode initialMode;

  final ValueChanged<SignatureMode>? onModeChanged;

  /// Offers "Type instead".
  final bool typedFallback;

  /// The ink the pen draws in.
  final SketchColor penColor;
  final SignaturePen pen;

  /// The value's image format.
  final SignatureFormat format;

  /// The pad's drawing size in units.
  final double width;
  final double height;

  /// Pins the hand of the pad's ink and the typed lettering.
  final String? seed;

  /// Your own layout of the pad's parts.
  final Widget? child;

  /// Upstream's `max-w-xl`.
  static const double maxWidth = 576;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> with InkSeed {
  late final SketchpadController _sketch = SketchpadController(
    tool: widget.pen.tool,
    color: widget.penColor,
    size: widget.pen.size,
  );
  final TextEditingController _typed = TextEditingController();
  final FocusNode _typedFocus = FocusNode(debugLabel: 'signature-typed');
  final FocusNode _canvasFocus = FocusNode(debugLabel: 'signature-canvas');
  final GlobalKey<_SignatureFieldState> _field = GlobalKey();
  late SignatureMode _ownMode = widget.initialMode;
  late String _ownValue = widget.initialValue;
  late String _published = widget.value ?? widget.initialValue;
  String _lastTyped = '';
  int _token = 0;

  SignatureMode get _mode => widget.mode ?? _ownMode;
  String get _value => widget.value ?? _ownValue;
  String get _seed => inkSeed(widget.seed);

  @override
  void initState() {
    super.initState();
    _typed.addListener(_onTyped);
  }

  @override
  void didUpdateWidget(SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pen != widget.pen) {
      _sketch
        ..selectTool(widget.pen.tool)
        ..size = widget.pen.size;
    }
    if (oldWidget.penColor != widget.penColor) _sketch.color = widget.penColor;
    final value = widget.value;
    if (value == null || value == _published) return;
    _published = value;
    _sketch.strokes = const [];
    _setTypedSilently('');
  }

  @override
  void dispose() {
    _typed
      ..removeListener(_onTyped)
      ..dispose();
    _typedFocus.dispose();
    _canvasFocus.dispose();
    _sketch.dispose();
    super.dispose();
  }

  void _setTypedSilently(String text) {
    _lastTyped = text;
    _typed.text = text;
  }

  void _onTyped() {
    final text = _typed.text;
    if (text == _lastTyped) return;
    _lastTyped = text;
    setState(() {});
    _publish(SignatureMode.type, _sketch.strokes, text);
  }

  void _onStrokes(List<SketchStroke> strokes) {
    setState(() {});
    _publish(SignatureMode.draw, strokes, _typed.text);
  }

  void _setMode(SignatureMode mode) {
    setState(() => _ownMode = mode);
    widget.onModeChanged?.call(mode);
    _publish(mode, _sketch.strokes, _typed.text);
  }

  void _clear() {
    if (_mode == SignatureMode.type) {
      _setTypedSilently('');
      setState(() {});
      _publish(SignatureMode.type, _sketch.strokes, '');
      return;
    }
    _sketch.strokes = const [];
    setState(() {});
    _publish(SignatureMode.draw, const [], _typed.text);
  }

  void _reset() {
    final empty = _sketch.strokes.isEmpty && _typed.text.isEmpty;
    if (empty && _value.isEmpty) return;
    _sketch.strokes = const [];
    _setTypedSilently('');
    setState(() {});
    _publish(_mode, const [], '');
  }

  void _publish(SignatureMode mode, List<SketchStroke> strokes, String text) {
    final detail = SignatureDetail(mode: mode, strokes: strokes, text: text);
    final mine = ++_token;
    final theme = LooseleafTheme.of(context);
    unawaited(
      SignatureExport.dataUrl(
        mode,
        strokes,
        text,
        width: widget.width,
        height: widget.height,
        seed: _seed,
        format: widget.format,
        theme: theme,
      ).then((value) {
        if (!mounted || mine != _token) return;
        _published = value;
        setState(() => _ownValue = value);
        _field.currentState?.didChange(value);
        widget.onChanged?.call(value, detail);
      }),
    );
  }

  void _focusEmptyField() {
    switch (_mode) {
      case SignatureMode.type:
        _typedFocus.requestFocus();
      case SignatureMode.draw:
        _canvasFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) => _SignatureField(
    key: _field,
    initialValue: _value,
    required: widget.required,
    message: widget.message,
    disabled: widget.disabled,
    onFormReset: _reset,
    onInvalid: _focusEmptyField,
    builder: (field) => _scoped(field),
  );

  Widget _scoped(FormFieldState<String> field) {
    final invalid = widget.invalid || field.hasError;
    final mode = _mode;
    return SignaturePadScope(
      mode: mode,
      onModeChanged: _setMode,
      typed: _typed.text,
      strokes: _sketch.strokes,
      value: _value,
      clear: _clear,
      width: widget.width,
      height: widget.height,
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      invalid: invalid,
      message: widget.message,
      typedFallback: widget.typedFallback,
      seed: _seed,
      typedController: _typed,
      typedFocusNode: _typedFocus,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SignaturePad.maxWidth),
        child: Sketchpad(
          controller: _sketch,
          onChanged: _onStrokes,
          tools: [widget.pen.tool],
          width: widget.width,
          height: widget.height,
          readOnly: widget.readOnly || mode == SignatureMode.type,
          disabled: widget.disabled,
          seed: widget.seed,
          focusNode: _canvasFocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              ...switch (widget.child) {
                final custom? => [custom],
                null => _defaultParts(),
              },
              if (invalid) SignaturePadMessage(message: widget.message),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _defaultParts() => [
    const SignaturePadCanvas(),
    if (_mode == SignatureMode.type) const SignaturePadTyped(),
    if (!widget.readOnly)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: Spacing.d8,
        children: [
          const SignaturePadClear(),
          if (widget.typedFallback) const SignaturePadModeToggle(),
        ],
      ),
  ];
}

/// The signature as a form field: validation, the error and form reset.
class _SignatureField extends FormField<String> {
  _SignatureField({
    super.key,
    required String super.initialValue,
    required bool required,
    required String message,
    required bool disabled,
    required this.onFormReset,
    required this.onInvalid,
    required super.builder,
  }) : super(
         enabled: !disabled,
         validator: (value) => switch (required && (value ?? '').isEmpty) {
           true => message,
           false => null,
         },
       );

  final VoidCallback onInvalid;
  final VoidCallback onFormReset;

  @override
  FormFieldState<String> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends FormFieldState<String> {
  _SignatureField get _field => widget as _SignatureField;

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (hasError && (value ?? '').isNotEmpty) validate();
  }

  @override
  bool validate() {
    final valid = super.validate();
    if (!valid) _field.onInvalid();
    return valid;
  }

  @override
  void reset() {
    super.reset();
    _field.onFormReset();
  }
}
