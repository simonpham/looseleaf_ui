import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/textarea/textarea_control.dart';
import 'package:looseleaf_ui/src/components/textarea/textarea_metrics.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds a [Textarea]'s counter from the text's [length] and the
/// [maxLength], if any.
typedef TextareaCountBuilder =
    Widget Function(
      BuildContext context,
      int length,
      int? maxLength,
    );

/// A multiline text field: a pencil box that grows with what you write,
/// optionally ruled like notebook paper, with a drawn resize grip and an
/// optional character counter.
///
/// Enter adds a line. It draws the same hover, focus, [invalid],
/// [disabled] and [readOnly] states as [Input], and fills the width it is
/// given.
///
/// ```dart
/// Textarea(
///   placeholder: 'Tell us what happened…',
///   maxLength: 280,
///   showCount: true,
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/textarea.tsx`.
class Textarea extends StatefulWidget {
  const Textarea({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.disabled = false,
    this.invalid = false,
    this.readOnly = false,
    this.ruled = false,
    this.autoGrow = true,
    this.resizable = true,
    this.showCount = false,
    this.countBuilder,
    this.maxLength,
    this.rows,
    this.minHeight,
    this.autofocus = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.onChanged,
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

  /// The red-pencil box and the `!` mark (upstream `aria-invalid`).
  final bool invalid;

  /// Focusable and selectable, drawn as a printed field.
  final bool readOnly;

  /// Draws notebook rules, 28 px apart, and sets the text on them.
  final bool ruled;

  /// Grows with the text (`field-sizing-content`); false keeps the height
  /// and scrolls. Ruled fields always grow.
  final bool autoGrow;

  /// Draws a resize grip in the end corner; dragging it sets the height
  /// (upstream `resize-y`, off with `resize-none`).
  final bool resizable;

  /// Shows `length/maxLength` in the end corner; screen readers hear
  /// "12 characters of 280".
  final bool showCount;

  /// Builds a custom counter; implies [showCount].
  final TextareaCountBuilder? countBuilder;

  /// The most characters the field takes.
  final int? maxLength;

  /// The visible lines the field starts with (upstream `rows`): its
  /// smallest height fits this many lines of text plus its padding.
  final int? rows;

  /// The smallest height, replacing the 64 px default (96 ruled), like
  /// upstream's `min-h-*` classes.
  final double? minHeight;

  final bool autofocus;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Pins the hand: the same seed always draws the same box.
  final String? seed;

  /// The accessible name, when no visible label names the field.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Textarea> createState() => _TextareaState();
}

class _TextareaState extends State<Textarea> with InkSeed {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _hovered = false;
  double? _height;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(Textarea oldWidget) {
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
    _ownController?.dispose();
    super.dispose();
  }

  double get _minHeight {
    final base =
        widget.minHeight ??
        switch (widget.ruled) {
          true => TextareaMetrics.ruledMinHeight,
          false => TextareaMetrics.minHeight,
        };
    final rows = widget.rows;
    if (rows == null) return base;
    final line = switch (widget.ruled) {
      true => TextareaMetrics.ruledLineHeight,
      false => TextareaMetrics.lineHeight,
    };
    return math.max(base, rows * line + _padding.vertical);
  }

  void _onResize(DragUpdateDetails details) {
    final current = _height ?? context.size?.height ?? _minHeight;
    setState(() => _height = math.max(_minHeight, current + details.delta.dy));
  }

  bool get _counted => widget.showCount || widget.countBuilder != null;

  EdgeInsetsDirectional get _padding {
    final base = switch (widget.ruled) {
      true => TextareaMetrics.padding.copyWith(
        top: TextareaMetrics.ruleTop,
        bottom: TextareaMetrics.ruleTop,
      ),
      false => TextareaMetrics.padding,
    };
    return base.copyWith(
      bottom: switch (_counted && !widget.ruled) {
        true => TextareaMetrics.countBottom,
        false => base.bottom,
      },
      end: switch (widget.invalid) {
        true => Spacing.d36,
        false => base.end,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final textarea = widget;
    final params = TextareaParams(
      disabled: textarea.disabled,
      invalid: textarea.invalid,
      readOnly: textarea.readOnly,
      ruled: textarea.ruled,
      lineHeight: TextareaMetrics.ruledLineHeight,
      ruleTop: TextareaMetrics.ruleTop,
      grip: textarea.resizable,
    );
    final enabled = !textarea.disabled;
    final grow = textarea.autoGrow || textarea.ruled;
    final height = _height;
    final formatters = [
      ...?textarea.inputFormatters,
      if (textarea.maxLength case final max?)
        LengthLimitingTextInputFormatter(max),
    ];
    final control = TextareaControl(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: textarea.placeholder,
      disabled: textarea.disabled,
      readOnly: textarea.readOnly,
      autofocus: textarea.autofocus,
      autoGrow: grow,
      keyboardType: textarea.keyboardType,
      textCapitalization: textarea.textCapitalization,
      inputFormatters: formatters,
      padding: _padding,
      onChanged: textarea.onChanged,
      semanticLabel: textarea.semanticLabel,
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: DefaultTextStyle.merge(
        style: TextareaMetrics.text(
          theme,
          lineHeight: switch (textarea.ruled) {
            true => TextareaMetrics.ruledLineHeight,
            false => TextareaMetrics.lineHeight,
          },
          disabled: textarea.disabled,
        ),
        child: InkSurface(
          source: RecipeInkSource(
            textareaRecipe,
            params,
            json: params.toJson(),
          ),
          seed: inkSeed(textarea.seed),
          states: {
            ...textarea.forcedStates,
            if (!enabled) InkState.disabled,
            if (textarea.invalid) InkState.invalid,
            if (enabled && _hovered) InkState.hovered,
            if (enabled && _focusNode.hasFocus) InkState.focused,
          },
          still: true,
          child: ConstrainedBox(
            constraints: switch ((grow, height)) {
              (false, final fixed?) => BoxConstraints.tightFor(height: fixed),
              (false, null) => BoxConstraints.tightFor(height: _minHeight),
              (true, final min?) => BoxConstraints(minHeight: min),
              (true, null) => BoxConstraints(minHeight: _minHeight),
            },
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                switch (grow) {
                  true => control,
                  false => Positioned.fill(child: control),
                },
                if (_counted) _count(theme),
                if (textarea.resizable && enabled)
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeUpDown,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: _onResize,
                        child: const SizedBox.square(
                          dimension: TextareaMetrics.grip,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _count(LooseleafThemeData theme) {
    final max = widget.maxLength;
    return PositionedDirectional(
      end: TextareaMetrics.countInset.end,
      bottom: TextareaMetrics.countInset.bottom,
      child: IgnorePointer(
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) {
            final length = value.text.characters.length;
            final described = switch (max) {
              final limit? => '$length characters of $limit',
              null => '$length characters',
            };
            return Semantics(
              label: described,
              child: ExcludeSemantics(
                child: DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 14,
                    cssLineHeight: 20 / 14,
                    color: theme.colors.inkMuted,
                  ),
                  child:
                      widget.countBuilder?.call(context, length, max) ??
                      Text(switch (max) {
                        final limit? => '$length/$limit',
                        null => '$length',
                      }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
