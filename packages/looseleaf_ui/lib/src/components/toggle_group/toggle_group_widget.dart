import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle.dart';
import 'package:looseleaf_ui/src/components/toggle_group/toggle_group_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A row (or column) of [ToggleGroupItem]s: one on at a time
/// ([ToggleGroupType.single]) or any number ([ToggleGroupType.multiple]).
///
/// With the default [spacing] of 0 the items join into one strip divided by
/// pencil seams; outline or disabled strips get a drawn frame. The group is
/// one Tab stop; the arrow keys move between items and Space or Enter
/// presses.
///
/// ```dart
/// ToggleGroup<String>(
///   value: {align},
///   onChanged: (value) => setState(() => align = value.firstOrNull),
///   children: const [
///     ToggleGroupItem(value: 'left', child: Text('Left')),
///     ToggleGroupItem(value: 'center', child: Text('Center')),
///   ],
/// )
/// ```
///
/// Mirrors `ToggleGroup` in upstream `src/components/ui/toggle-group.tsx`.
class ToggleGroup<T> extends StatefulWidget {
  const ToggleGroup({
    super.key,
    required this.value,
    required this.children,
    this.onChanged,
    this.type = ToggleGroupType.single,
    this.variant = ToggleVariant.primary,
    this.size = ToggleSize.regular,
    this.spacing = 0,
    this.tone,
    this.direction = Axis.horizontal,
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.semanticLabel,
  });

  /// The values pressed on; at most one for [ToggleGroupType.single].
  final Set<T> value;

  /// Called with the next set of values.
  final ValueChanged<Set<T>>? onChanged;

  /// The items, usually [ToggleGroupItem]s of [T].
  final List<Widget> children;

  final ToggleGroupType type;
  final ToggleVariant variant;
  final ToggleSize size;

  /// The gap between items in pixels; 0 joins them.
  final double spacing;

  /// The fill of pressed items.
  final ToggleTone? tone;

  /// A row, or a column of full-width items (`orientation`).
  final Axis direction;

  /// Disables every item.
  final bool disabled;

  /// Red pencil on every item that does not say otherwise.
  final bool invalid;

  /// Pins the hand of the group frame.
  final String? seed;

  /// The group's accessible name.
  final String? semanticLabel;

  @override
  State<ToggleGroup<T>> createState() => _ToggleGroupState<T>();
}

class _ToggleGroupState<T> extends State<ToggleGroup<T>> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final group = widget;
    final vertical = group.direction == Axis.vertical;
    final joined = group.spacing == 0;
    final invalid = group.invalid && !group.disabled;
    final params = ToggleGroupParams(
      joined:
          joined && (group.variant == ToggleVariant.outline || group.disabled),
      disabled: group.disabled,
      invalid: invalid,
    );
    final items = [
      for (final (index, child) in group.children.indexed)
        ToggleGroupScope<T>(
          value: group.value,
          onChanged: group.onChanged,
          type: group.type,
          variant: group.variant,
          size: group.size,
          spacing: group.spacing,
          tone: group.tone,
          vertical: vertical,
          disabled: group.disabled,
          invalid: invalid,
          first: index == 0,
          child: child,
        ),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: group.semanticLabel,
      child: InkRovingFocus(
        axis: group.direction,
        child: InkSurface(
          source: RecipeInkSource(
            toggleGroupRecipe,
            params,
            json: params.toJson(),
          ),
          seed: inkSeed(group.seed),
          states: {if (group.disabled) InkState.disabled},
          child: switch (vertical) {
            true => IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: group.spacing,
                children: items,
              ),
            ),
            false => Row(
              mainAxisSize: MainAxisSize.min,
              spacing: group.spacing,
              children: items,
            ),
          },
        ),
      ),
    );
  }
}
