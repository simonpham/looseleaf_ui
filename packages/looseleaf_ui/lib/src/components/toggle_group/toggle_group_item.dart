import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle.dart';
import 'package:looseleaf_ui/src/components/toggle_group/toggle_group_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One toggle of a [ToggleGroup]. In a joined group it draws only the seam
/// before it and its pressed fill; otherwise it is a whole [Toggle].
///
/// In a [ToggleGroupType.single] group it reads as a radio choice, in a
/// [ToggleGroupType.multiple] group as a toggle button.
///
/// Mirrors `ToggleGroupItem` in upstream
/// `src/components/ui/toggle-group.tsx`.
class ToggleGroupItem<T> extends StatefulWidget {
  const ToggleGroupItem({
    super.key,
    required this.value,
    required this.child,
    this.leading,
    this.variant,
    this.disabled = false,
    this.invalid,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The value this item adds to the group's when pressed on.
  final T value;

  /// The content: an icon or a word.
  final Widget child;

  /// An icon before a word [child].
  final Widget? leading;

  /// Overrides the group's variant; an outline item in a plain joined
  /// group stands apart as its own box.
  final ToggleVariant? variant;

  final bool disabled;

  /// Red pencil; null follows the group.
  final bool? invalid;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name, for icon items.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<ToggleGroupItem<T>> createState() => _ToggleGroupItemState<T>();
}

class _ToggleGroupItemState<T> extends State<ToggleGroupItem<T>> with InkSeed {
  FocusNode? _ownFocusNode;
  late InkRovingEntry _entry = InkRovingEntry(_focusNode);
  InkRovingFocusState? _roving;

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
  void didUpdateWidget(ToggleGroupItem<T> oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final group = ToggleGroupScope.maybeOf<T>(context);
    final item = widget;
    final groupVariant = group?.variant ?? ToggleVariant.primary;
    final variant = item.variant ?? groupVariant;
    final disabled = item.disabled || (group?.disabled ?? false);
    final invalid = item.invalid ?? group?.invalid ?? false;
    final on = group?.value.contains(item.value) ?? false;
    final joined =
        (group?.joined ?? false) &&
        (variant != ToggleVariant.outline ||
            groupVariant == ToggleVariant.outline);
    final entry = _entry;
    if (entry.active != on || entry.enabled == disabled) {
      entry
        ..active = on
        ..enabled = !disabled;
      _roving?.markChanged();
    }
    final single = group?.type != ToggleGroupType.multiple;
    final params = ToggleParams(
      variant: variant,
      disabled: disabled,
      tone: group?.tone,
      joined: joined,
      vertical: group?.vertical ?? false,
      invalid: invalid,
    );
    return Semantics(
      container: true,
      button: !single,
      toggled: switch (single) {
        true => null,
        false => on,
      },
      checked: switch (single) {
        true => on,
        false => null,
      },
      inMutuallyExclusiveGroup: single,
      enabled: !disabled,
      label: item.semanticLabel,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: () => group?.onChanged?.call(group.pressing(item.value)),
        states: {
          ...item.forcedStates,
          if (on) InkState.checked,
          if (invalid) InkState.invalid,
        },
        focusNode: _focusNode,
        autofocus: item.autofocus,
        builder: (context, states) => ToggleSurface(
          params: params,
          seed: inkSeed(item.seed),
          states: states,
          size: group?.size ?? ToggleSize.regular,
          padding: Spacing.d12,
          minWidth: 0,
          hiddenPart: switch (joined && (group?.first ?? false)) {
            true => 'seam',
            false => null,
          },
          leading: item.leading,
          child: item.child,
        ),
      ),
    );
  }
}
