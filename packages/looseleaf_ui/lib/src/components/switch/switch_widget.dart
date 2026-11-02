import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/switch/switch_metrics.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pencil pill with a paper thumb: on fills it with marker and pops the
/// thumb to the end.
///
/// Tapping it or pressing Space calls [onChanged] with the opposite of
/// [value]; Enter is left to the form. A [label] sits after the track and
/// is part of it: tapping or hovering it works like the track. The thumb
/// moves to the reading end, so it flips under RTL.
///
/// ```dart
/// Switch(
///   value: airplane,
///   onChanged: (value) => setState(() => airplane = value),
///   label: const Text('Airplane mode'),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/switch.tsx`.
class Switch extends StatefulWidget {
  const Switch({
    super.key,
    required this.value,
    this.onChanged,
    this.size = SwitchSize.regular,
    this.disabled = false,
    this.invalid = false,
    this.label,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// On or off.
  final bool value;

  /// Called with the next value on tap and Space. A null callback does not
  /// disable the switch; [disabled] does.
  final ValueChanged<bool>? onChanged;

  final SwitchSize size;

  /// A dashed pencil pill, no input, out of the tab order.
  final bool disabled;

  /// Draws the track in red pencil (upstream `aria-invalid`).
  final bool invalid;

  /// The label after the track, usually a [Text].
  final Widget? label;

  /// Pins the hand: the same seed always draws the same track and thumb.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when there is no [label].
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Switch> createState() => _SwitchState();
}

class _SwitchState extends State<Switch> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final config = widget;
    final params = SwitchParams(
      disabled: config.disabled,
      invalid: config.invalid,
    );
    return InkInteraction(
      semantics: SemanticsProperties(
        toggled: config.value,
        enabled: !config.disabled,
        label: config.semanticLabel,
      ),
      enabled: !config.disabled,
      onActivate: () => config.onChanged?.call(!config.value),
      activation: InkActivation.toggle,
      states: {
        ...config.forcedStates,
        if (config.value) InkState.checked,
        if (config.invalid) InkState.invalid,
      },
      focusNode: config.focusNode,
      autofocus: config.autofocus,
      mouseCursor: MouseCursor.defer,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      hitSlop: const EdgeInsets.all(Spacing.d4),
      builder: (context, states) => _body(
        context,
        RecipeInkSource(switchRecipe, params, json: params.toJson()),
        states,
      ),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final config = widget;
    final theme = LooseleafTheme.of(context);
    final size = config.size.at(theme.density);
    final seed = inkSeed(config.seed);
    final thumbParams = SwitchThumbParams(disabled: config.disabled);
    final track = InkSurface(
      source: source,
      seed: seed,
      states: states,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              end: switch (config.value) {
                true => size.onInset,
                false => size.offInset,
              },
            ),
            duration: InkMotion.of(context, InkMotion.pop),
            curve: InkMotion.popCurve,
            builder: (context, inset, child) => Padding(
              padding: EdgeInsetsDirectional.only(start: inset),
              child: child,
            ),
            child: InkSurface(
              source: RecipeInkSource(
                switchThumbRecipe,
                thumbParams,
                json: thumbParams.toJson(),
              ),
              seed: '$seed|thumb',
              still: true,
              child: SizedBox.square(dimension: size.thumb),
            ),
          ),
        ),
      ),
    );
    final label = config.label;
    if (label == null) return track;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        track,
        Flexible(
          child: InkContent(
            style: theme.typography.label(
              color: switch (config.disabled) {
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
