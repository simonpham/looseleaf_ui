import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The field that opens a [Select]: the input's pencil box with a tick
/// before its chevron cell, the [child] (a [SelectValue]) in blue felt,
/// and a chevron that turns over while the list is open.
///
/// It is as wide as its value plus the cell, or fills a width it is given
/// (upstream's `w-[190px]`). Tap, Enter, Space or the up and down arrows
/// open the list; letters choose by typeahead while it is closed.
///
/// Mirrors `SelectTrigger` in upstream `src/components/ui/select.tsx`.
class SelectTrigger extends StatefulWidget {
  const SelectTrigger({
    super.key,
    this.child = const SelectValue(),
    this.size = SelectSize.regular,
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The content; a [SelectValue] by default.
  final Widget child;

  /// 36 px or 32 px tall (28 px calm).
  final SelectSize size;

  /// Disables the trigger alone; the root's `disabled` disables all.
  final bool disabled;

  /// The red pencil box, a wavy underline and a bang (`aria-invalid`).
  final bool invalid;

  /// Pins the hand.
  final String? seed;

  final bool autofocus;

  /// The accessible name (upstream `aria-label`).
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<SelectTrigger> createState() => _SelectTriggerState();
}

class _SelectTriggerState extends State<SelectTrigger> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final select = Select.of(context);
    final theme = LooseleafTheme.of(context);
    final disabled = select.disabled || widget.disabled;
    final invalid = widget.invalid && !disabled;
    final params = SelectParams(disabled: disabled, invalid: invalid);
    final open = select.open;
    final chosen = select.chosen;
    return TapRegion(
      groupId: select.groupId,
      child: Semantics(
        container: true,
        button: true,
        expanded: open,
        enabled: !disabled,
        label: widget.semanticLabel,
        value: chosen?.label,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (_, event) => switch (disabled) {
            true => KeyEventResult.ignored,
            false => select.onTriggerKey(event),
          },
          child: InkInteraction(
            enabled: !disabled,
            onActivate: select.toggle,
            states: {
              ...widget.forcedStates,
              if (open) InkState.open,
              if (invalid) InkState.invalid,
            },
            focusNode: select.triggerFocus,
            autofocus: widget.autofocus,
            mouseCursor: SystemMouseCursors.basic,
            disabledMouseCursor: SystemMouseCursors.forbidden,
            builder: (context, states) => InkContent(
              style: SelectMetrics.text(
                theme,
                cssSize: widget.size.cssFontSize(theme.density),
                color: switch (disabled) {
                  true => theme.colors.pencilText,
                  false => theme.colors.inputInk,
                },
              ),
              iconSize: Spacing.d16,
              wrap: false,
              child: InkSurface(
                source: RecipeInkSource(
                  selectRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                states: states,
                still: true,
                child: SizedBox(
                  height: widget.size.height.resolve(theme.density),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: SelectMetrics.triggerStart,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: SelectMetrics.triggerGap,
                      children: [
                        Flexible(
                          child: ExcludeSemantics(
                            child: _Disabled(
                              disabled: disabled,
                              child: widget.child,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SelectMetrics.cell,
                          child: Center(
                            child: AnimatedRotation(
                              turns: switch (open) {
                                true => 0.5,
                                false => 0,
                              },
                              duration: InkMotion.of(context, InkMotion.pop),
                              curve: InkMotion.popCurve,
                              child: InkIcon(
                                'chevron-down',
                                size: SelectMetrics.chevron,
                                color: switch (disabled) {
                                  true => theme.colors.pencilText,
                                  false => theme.colors.inkSoft,
                                },
                              ),
                            ),
                          ),
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
}

class _Disabled extends InheritedWidget {
  const _Disabled({required this.disabled, required super.child});

  final bool disabled;

  @override
  bool updateShouldNotify(_Disabled oldWidget) =>
      oldWidget.disabled != disabled;
}

/// Whether the [SelectTrigger] around [context] is disabled.
bool selectTriggerDisabled(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_Disabled>()?.disabled ?? false;
