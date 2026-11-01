import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_anchor.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_chip.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_chips_input.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds a custom chip for [value] with its [label].
typedef ComboboxChipBuilder = Widget Function(
  BuildContext context,
  String value,
  String label,
);

/// The field of a [Combobox.multiple]: a pencil box holding a hang-tag per
/// chosen value and, after them, the [ComboboxChipsInput]. It grows to
/// more lines as tags are added; a tap anywhere but a tag's x types.
///
/// Mirrors `ComboboxChips` in upstream `src/components/ui/combobox.tsx`.
class ComboboxChips extends StatefulWidget {
  const ComboboxChips({
    super.key,
    this.child = const ComboboxChipsInput(),
    this.tone = ChipTone.hi,
    this.autoTone = false,
    this.chipBuilder,
    this.seed,
    this.forcedStates = const {},
  });

  /// The input after the chips.
  final Widget child;

  /// Every chip's marker, unless [autoTone].
  final ChipTone tone;

  /// Gives each value its own marker, from a hash of it (upstream
  /// `tone="auto"`).
  final bool autoTone;

  /// Replaces the default [ComboboxChip].
  final ComboboxChipBuilder? chipBuilder;

  /// Pins the hand of the box.
  final String? seed;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// Upstream `toneOf`: a marker per value, the same on every render.
  static ChipTone toneOf(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0xFFFFFFFF;
    }
    return ChipTone.values[hash % ChipTone.values.length];
  }

  @override
  State<ComboboxChips> createState() => _ComboboxChipsState();
}

class _ComboboxChipsState extends State<ComboboxChips> with InkSeed {
  ComboboxController? _controller;
  bool _hovered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ComboboxScope.of(context).controller;
    if (identical(controller, _controller)) return;
    _controller?.inputFocus.removeListener(_onFocus);
    _controller = controller..fieldMode = ComboboxFieldMode.chips;
    controller.inputFocus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _controller
      ?..inputFocus.removeListener(_onFocus)
      ..fieldMode = ComboboxFieldMode.none;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    final disabled = controller.disabled;
    final enabled = !disabled;
    final invalid = controller.invalid && !disabled;
    final calm = theme.density == LooseleafDensity.calm;
    final gap = switch (calm) {
      true => Spacing.d4,
      false => Spacing.d6,
    };
    final params = ComboboxChipsParams(disabled: disabled, invalid: invalid);
    final builder = widget.chipBuilder;
    return Semantics(
      expanded: controller.open,
      child: ComboboxAnchor(
        controller: controller,
        child: MouseRegion(
          cursor: switch (disabled) {
            true => SystemMouseCursors.forbidden,
            false => SystemMouseCursors.text,
          },
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: switch (disabled) {
              true => null,
              false => controller.inputFocus.requestFocus,
            },
            child: InkSurface(
              source: RecipeInkSource(
                comboboxChipsRecipe,
                params,
                json: params.toJson(),
              ),
              seed: inkSeed(widget.seed),
              states: {
                ...widget.forcedStates,
                if (!enabled) InkState.disabled,
                if (invalid) InkState.invalid,
                if (controller.open) InkState.open,
                if (enabled && _hovered) InkState.hovered,
                if (enabled && controller.inputFocus.hasFocus) InkState.focused,
              },
              still: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ComboboxMetrics.height.resolve(theme.density),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.d8,
                    vertical: switch (calm) {
                      true => Spacing.d2,
                      false => Spacing.d4,
                    },
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final value in controller.value)
                          switch (builder) {
                            final build? => build(
                              context,
                              value,
                              controller.labelFor(value),
                            ),
                            null => ComboboxChip(
                              key: ValueKey(value),
                              value: value,
                              tone: switch (widget.autoTone) {
                                true => ComboboxChips.toneOf(value),
                                false => widget.tone,
                              },
                            ),
                          },
                        widget.child,
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
