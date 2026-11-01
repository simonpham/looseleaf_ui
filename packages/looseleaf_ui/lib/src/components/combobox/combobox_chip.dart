import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A chosen value in [ComboboxChips]: a marker hang-tag with a punched
/// hole, its label and an x that takes it back ("Remove <label>").
///
/// Mirrors `ComboboxChip` in upstream `src/components/ui/combobox.tsx`.
class ComboboxChip extends StatelessWidget {
  const ComboboxChip({
    super.key,
    required this.value,
    this.child,
    this.tone = ChipTone.hi,
    this.showRemove = true,
    this.seed,
    this.removeLabel,
  });

  /// The value the chip stands for.
  final String value;

  /// The label; the value's label when null.
  final Widget? child;

  /// The tag's marker.
  final ChipTone tone;

  /// Shows the x.
  final bool showRemove;

  /// Pins the hand; `chip|<value>` when null, so a tag keeps its shape.
  final String? seed;

  /// The x's accessible name; "Remove <label>" when null.
  final String? removeLabel;

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    final disabled = controller.disabled;
    final params = ComboboxChipParams(tone: tone, disabled: disabled);
    final label = controller.labelFor(value);
    return InkContent(
      style: ComboboxMetrics.small(
        theme,
        fontWeight: FontWeight.w700,
        color: switch (disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.ink,
        },
      ),
      wrap: false,
      child: InkSurface(
        source: RecipeInkSource(
          comboboxChipRecipe,
          params,
          json: params.toJson(),
        ),
        seed: seed ?? 'chip|$value',
        states: {if (disabled) InkState.disabled},
        still: true,
        child: SizedBox(
          height: ComboboxMetrics.chipHeight(theme.density),
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: ComboboxMetrics.chipStart(theme.density),
              end: Spacing.d2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d2,
              children: [
                Flexible(
                  child: child ?? Text(label, overflow: TextOverflow.ellipsis),
                ),
                if (showRemove)
                  _Remove(
                    label: removeLabel ?? 'Remove $label',
                    disabled: disabled || controller.readOnly,
                    onRemove: () {
                      controller.remove(value);
                      controller.inputFocus.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Remove extends StatelessWidget {
  const _Remove({
    required this.label,
    required this.disabled,
    required this.onRemove,
  });

  final String label;
  final bool disabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      container: true,
      button: true,
      label: label,
      enabled: !disabled,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: onRemove,
        mouseCursor: SystemMouseCursors.basic,
        builder: (context, states) {
          final reached =
              states.contains(InkState.hovered) ||
              states.contains(InkState.focused);
          final focused = states.contains(InkState.focused);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: switch (reached) {
                true => colors.hiSelect,
                false => null,
              },
              borderRadius: ComboboxMetrics.swipe,
              border: switch (focused) {
                true => Border.all(color: colors.focus, width: Spacing.d2),
                false => null,
              },
            ),
            child: SizedBox.square(
              dimension: Spacing.d24,
              child: Center(
                child: InkIcon(
                  'x',
                  size: Spacing.d12,
                  color: switch ((disabled, reached)) {
                    (true, _) => colors.pencilText,
                    (false, true) => colors.ink,
                    (false, false) => colors.inkSoft,
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
