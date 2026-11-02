import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/radio_group/radio_group_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One choice of a [RadioGroup]: an inked ring that, when checked, gets a
/// marker dot with a spiral drawn on around it.
///
/// A [label] sits after the ring and is part of it: tapping or hovering
/// the label works like the ring, and screen readers read it as the name.
///
/// Mirrors `RadioGroupItem` in upstream `src/components/ui/radio-group.tsx`.
class RadioGroupItem<T> extends StatefulWidget {
  const RadioGroupItem({
    super.key,
    required this.value,
    this.label,
    this.disabled = false,
    this.invalid,
    this.size = Spacing.d16,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The value the group takes when this item is checked.
  final T value;

  /// The label after the ring, usually a [Text].
  final Widget? label;

  /// A dashed ring, no input, skipped by the arrows.
  final bool disabled;

  /// Red pencil; null follows the group's `invalid`.
  final bool? invalid;

  /// The ring's side (`size-4`).
  final double size;

  /// Pins the hand: the same seed always draws the same ring and dot.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when there is no [label].
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<RadioGroupItem<T>> createState() => _RadioGroupItemState<T>();
}

class _RadioGroupItemState<T> extends State<RadioGroupItem<T>> with InkSeed {
  FocusNode? _ownFocusNode;
  late InkRovingEntry _entry = InkRovingEntry(_focusNode);
  InkRovingFocusState? _roving;
  bool _touched = false;

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
  void didUpdateWidget(RadioGroupItem<T> oldWidget) {
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

  void _check(RadioGroupScope<T>? group) {
    setState(() => _touched = true);
    group?.onChanged?.call(widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final group = RadioGroupScope.maybeOf<T>(context);
    final disabled = widget.disabled || (group?.disabled ?? false);
    final invalid = widget.invalid ?? group?.invalid ?? false;
    final checked = group?.value == widget.value;
    final entry = _entry;
    if (entry.active != checked || entry.enabled == disabled) {
      entry
        ..active = checked
        ..enabled = !disabled;
      _roving?.markChanged();
    }
    entry.onArrive = switch (disabled) {
      true => null,
      false => () => _check(group),
    };
    final params = RadioParams(disabled: disabled, invalid: invalid);
    final source = RecipeInkSource(radioRecipe, params, json: params.toJson());
    return InkInteraction(
      semantics: SemanticsProperties(
        checked: checked,
        inMutuallyExclusiveGroup: true,
        enabled: !disabled,
        label: widget.semanticLabel,
      ),
      enabled: !disabled,
      onActivate: () => _check(group),
      activation: InkActivation.toggle,
      states: {
        ...widget.forcedStates,
        if (checked) InkState.checked,
        if (invalid) InkState.invalid,
      },
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      mouseCursor: MouseCursor.defer,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      hitSlop: const EdgeInsets.all(Spacing.d8),
      builder: (context, states) =>
          _body(context, source, states, disabled: disabled),
    );
  }

  Widget _body(
    BuildContext context,
    InkSource source,
    Set<InkState> states, {
    required bool disabled,
  }) {
    final ring = InkSurface(
      source: source,
      seed: inkSeed(widget.seed),
      states: states,
      drawOn: _touched,
      child: SizedBox.square(dimension: widget.size),
    );
    final label = widget.label;
    if (label == null) return ring;
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        ring,
        Flexible(
          child: InkContent(
            style: theme.typography.label(
              color: switch (disabled) {
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
