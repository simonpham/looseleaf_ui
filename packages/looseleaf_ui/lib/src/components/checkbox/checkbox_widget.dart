import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn box you tick. Checking fills it with marker and writes a
/// felt tick over it, stroke by stroke; a dash means partly checked.
///
/// [value] is tri-state: `true` checked, `false` unchecked, `null`
/// indeterminate. Tapping it or pressing Space calls [onChanged] with the
/// next value: `true` from unchecked or indeterminate, `false` from checked.
/// A [label] sits after the box and is part of it: tapping or hovering the
/// label works like the box, and screen readers read it as the name.
///
/// ```dart
/// Checkbox(
///   value: accepted,
///   onChanged: (value) => setState(() => accepted = value),
///   label: const Text('Accept the terms and conditions'),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/checkbox.tsx`; the label follows
/// `src/components/ui/label.tsx`.
class Checkbox extends StatefulWidget {
  const Checkbox({
    super.key,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.invalid = false,
    this.label,
    this.size = Spacing.d16,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// Checked, unchecked, or `null` for indeterminate.
  final bool? value;

  /// Called with the next value on tap and Space. A null callback does not
  /// disable the checkbox; [disabled] does.
  final ValueChanged<bool>? onChanged;

  /// A dashed pencil box on a pale wash, a graphite tick when on, a pencil
  /// label; no input, out of the tab order.
  final bool disabled;

  /// Draws the box in red pencil (upstream `aria-invalid`).
  final bool invalid;

  /// The label after the box, usually a [Text].
  final Widget? label;

  /// The box's side; upstream draws and tests 16, 20 and 28.
  final double size;

  /// Pins the hand: the same seed always draws the same box and tick.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, like upstream's `data-hover`,
  /// `data-pressed` and `data-focus-visible`: for state grids and goldens.
  final Set<InkState> forcedStates;

  /// The accessible name when there is no [label].
  final String? semanticLabel;

  @override
  State<Checkbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<Checkbox> with InkSeed {
  bool _touched = false;

  void _toggle() {
    setState(() => _touched = true);
    widget.onChanged?.call(widget.value != true);
  }

  @override
  Widget build(BuildContext context) {
    final params = CheckboxParams(
      disabled: widget.disabled,
      invalid: widget.invalid,
    );
    final source = RecipeInkSource(
      checkboxRecipe,
      params,
      json: params.toJson(),
    );
    final value = widget.value;
    return InkInteraction(
      semantics: SemanticsProperties(
        checked: value ?? false,
        mixed: value == null,
        enabled: !widget.disabled,
        label: widget.semanticLabel,
      ),
      enabled: !widget.disabled,
      onActivate: _toggle,
      activation: InkActivation.toggle,
      states: {
        ...widget.forcedStates,
        if (value == true) InkState.checked,
        if (value == null) InkState.indeterminate,
        if (widget.invalid) InkState.invalid,
      },
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: MouseCursor.defer,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      hitSlop: const EdgeInsets.all(Spacing.d6),
      builder: (context, states) => _body(context, source, states),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final box = InkSurface(
      source: source,
      seed: inkSeed(widget.seed),
      states: states,
      drawOn: _touched,
      child: SizedBox.square(dimension: widget.size),
    );
    final label = widget.label;
    if (label == null) return box;
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: [
        box,
        Flexible(
          child: InkContent(
            style: theme.typography.label(
              color: switch (widget.disabled) {
                true => theme.colors.pencilText,
                false => theme.colors.ink,
              },
            ),
            child: label,
          ),
        ),
      ],
    );
  }
}
