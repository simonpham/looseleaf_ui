import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/radio_group/radio_group_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One choice of an [InkRadioGroup]: an inked ring that, when checked, gets a
/// marker dot with a spiral drawn on around it.
///
/// A [label] sits after the ring and is part of it: tapping or hovering
/// the label works like the ring, and screen readers read it as the name.
/// The ring lines up with the label's first line, so a label with a line
/// of help under it (or a [description]) keeps the ring beside its title.
///
/// Mirrors `RadioGroupItem` in upstream `src/components/ui/radio-group.tsx`.
class InkRadioGroupItem<T> extends StatefulWidget {
  const InkRadioGroupItem({
    super.key,
    required this.value,
    this.label,
    this.description,
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

  /// A line of help under the [label], in regular muted `text-sm` (the
  /// docs' `<p className="text-sm text-ink-muted">` beside the `Label`).
  final Widget? description;

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
  State<InkRadioGroupItem<T>> createState() => _RadioGroupItemState<T>();
}

class _RadioGroupItemState<T> extends State<InkRadioGroupItem<T>> with InkSeed {
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
  void didUpdateWidget(InkRadioGroupItem<T> oldWidget) {
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
    final description = widget.description;
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.label(
      color: switch (disabled) {
        true => theme.colors.pencilText,
        false => theme.colors.ink,
      },
    );
    final lineHeight = MediaQuery.textScalerOf(
      context,
    ).scale((style.fontSize ?? 0) * (style.height ?? 1));
    final band = math.max(widget.size, lineHeight);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        SizedBox(
          height: band,
          child: Center(child: ring),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(top: (band - lineHeight) / 2),
            child: switch (description) {
              null => InkContent(style: style, child: label),
              final help => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d4,
                children: [
                  InkContent(style: style, child: label),
                  InkContent(
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                      cssLineHeight: 20 / 14,
                      color: theme.colors.inkMuted,
                    ),
                    child: help,
                  ),
                ],
              ),
            },
          ),
        ),
      ],
    );
  }
}
