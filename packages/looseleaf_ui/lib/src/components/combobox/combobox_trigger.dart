import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_anchor.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_value.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The button that opens a [Combobox]'s popup: a select-like pencil box
/// with the [ComboboxValue] and an up-down chevron in its end cell.
///
/// Tap, Enter, Space or the up and down arrows open it; when the popup
/// closes, focus comes back here. It fills the width it is given.
///
/// Mirrors `ComboboxTrigger` in upstream `src/components/ui/combobox.tsx`.
class ComboboxTrigger extends StatefulWidget {
  const ComboboxTrigger({
    super.key,
    this.child = const ComboboxValue(),
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The content; a [ComboboxValue] by default.
  final Widget child;

  /// Disables the trigger alone; the root's `disabled` disables all parts.
  final bool disabled;

  /// Red pencil, on top of the root's `invalid`.
  final bool invalid;

  /// Pins the hand.
  final String? seed;

  final bool autofocus;

  /// The accessible name (upstream `aria-label`).
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<ComboboxTrigger> createState() => _ComboboxTriggerState();
}

class _ComboboxTriggerState extends State<ComboboxTrigger> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    final disabled = controller.disabled || widget.disabled;
    final invalid = (controller.invalid || widget.invalid) && !disabled;
    final params = SelectParams(disabled: disabled, invalid: invalid);
    final open = controller.open;
    return Semantics(
      container: true,
      button: true,
      expanded: open,
      enabled: !disabled,
      readOnly: controller.readOnly,
      label: widget.semanticLabel,
      child: ComboboxAnchor(
        controller: controller,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (_, event) => _onKey(event, disabled: disabled),
          child: InkInteraction(
            enabled: !disabled,
            onActivate: () => controller.setOpen(!open),
            states: {
              ...widget.forcedStates,
              if (open) InkState.open,
              if (invalid) InkState.invalid,
            },
            focusNode: controller.triggerFocus,
            autofocus: widget.autofocus,
            mouseCursor: SystemMouseCursors.basic,
            disabledMouseCursor: SystemMouseCursors.forbidden,
            builder: (context, states) => InkContent(
              style: ComboboxMetrics.text(
                theme,
                color: switch (disabled) {
                  true => theme.colors.pencilText,
                  false => theme.colors.inputInk,
                },
              ),
              wrap: false,
              child: InkSurface(
                source: RecipeInkSource(
                  comboboxTriggerRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                states: states,
                still: true,
                child: SizedBox(
                  height: ComboboxMetrics.height.resolve(theme.density),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: Spacing.d12,
                      end: Spacing.d8,
                    ),
                    child: Row(
                      spacing: Spacing.d8,
                      children: [
                        Expanded(child: widget.child),
                        InkIcon(
                          'chevrons-up-down',
                          size: Spacing.d16,
                          color: switch (disabled) {
                            true => theme.colors.pencilText,
                            false => theme.colors.inkSoft,
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKey(KeyEvent event, {required bool disabled}) {
    if (event is KeyUpEvent || disabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.arrowDown &&
        key != LogicalKeyboardKey.arrowUp) {
      return KeyEventResult.ignored;
    }
    ComboboxScope.of(context).controller.setOpen(true);
    return KeyEventResult.handled;
  }
}
