import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/stamp_button/stamp_impression.dart';
import 'package:looseleaf_ui/src/components/stamp_button/stamp_surface.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A rubber stamp tool: a kraft knob over an inked die with the label on
/// it. Pressing it (tap, Enter or Space) strikes an impression on the
/// nearest [StampSurface] at [place]; outside a surface it stamps on itself.
///
/// [stamp] names a preset (`stamp-approved`, `stamp-void`, …); [text],
/// [shape], [ink] and the rest override it. The tool takes the color of
/// the pad it leaves. Striking the same [impressionId] again replaces the
/// last impression, so Approve twice is still one APPROVED.
///
/// ```dart
/// StampButton(
///   stamp: 'stamp-approved',
///   place: const Offset(0.66, 0.5),
///   child: const Text('Approve'),
/// )
/// ```
///
/// Mirrors `StampButton` in upstream `src/components/ui/stamp-button.tsx`.
class StampButton extends StatelessWidget {
  const StampButton({
    super.key,
    this.child,
    this.stamp,
    this.text,
    this.shape,
    this.ink,
    this.sub,
    this.ring,
    this.w,
    this.h,
    this.size,
    this.ghost,
    this.dashed,
    this.impressionId,
    this.place = const Offset(0.72, 0.6),
    this.onPressed,
    this.onStamp,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The label; the stamp's words in title case when null.
  final Widget? child;

  /// A stamp preset's name in [stickers].
  final String? stamp;

  /// The impression's words over the preset's.
  final String? text;
  final StampShape? shape;

  /// The pad ink: the tool's color and the impression's; the preset's,
  /// else red.
  final StampButtonInk? ink;
  final String? sub;
  final String? ring;
  final double? w;
  final double? h;
  final double? size;
  final bool? ghost;
  final bool? dashed;

  /// The impression's slot; the preset, else the text.
  final String? impressionId;

  /// Where the impression lands, as fractions of the surface.
  final Offset place;

  /// Called on each press, before the strike.
  final VoidCallback? onPressed;

  /// Called with each impression struck.
  final ValueChanged<StampImpression>? onStamp;

  /// A dashed pencil die; no input, out of the tab order.
  final bool disabled;

  /// Pins the hand that draws the tool.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when the label is not text.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  StampGen? get _preset => switch (stickers[stamp]) {
    final StampGen gen => gen,
    _ => null,
  };

  /// The stamp's words as the default label says them: `stamp-approved`
  /// becomes "Approved".
  String get spoken {
    final words = (text ?? _preset?.text ?? stamp ?? '')
        .replaceFirst(RegExp('^stamp-'), '')
        .replaceAll('-', ' ');
    if (words.isEmpty) return words;
    return words[0].toUpperCase() + words.substring(1).toLowerCase();
  }

  /// The ink the tool is drawn in.
  StampButtonInk get tone =>
      ink ??
      switch (_preset?.opts.ink) {
        StampPadInk.inkYou => StampButtonInk.inkYou,
        StampPadInk.green => StampButtonInk.green,
        StampPadInk.ink => StampButtonInk.ink,
        _ => StampButtonInk.red,
      };

  @override
  Widget build(BuildContext context) {
    final tool = _StampTool(button: this);
    if (StampSurface.maybeOf(context) != null) return tool;
    return StampSurface(child: tool);
  }
}

class _StampTool extends StatefulWidget {
  const _StampTool({required this.button});

  final StampButton button;

  @override
  State<_StampTool> createState() => _StampToolState();
}

class _StampToolState extends State<_StampTool> with InkSeed {
  static const double _dieHeight = 38;
  static const double _letterSpacing = 0.4;

  void _press() {
    final button = widget.button;
    button.onPressed?.call();
    final surface = StampSurface.maybeOf(context);
    if (surface == null) return;
    final impression = surface.strike(
      StampImpression(
        id: button.impressionId ?? button.stamp ?? button.text ?? 'stamp',
        x: button.place.dx,
        y: button.place.dy,
        name: button.stamp,
        text: button.text,
        shape: button.shape,
        ink: switch (button.ink) {
          null => null,
          StampButtonInk.red => StampPadInk.red,
          StampButtonInk.inkYou => StampPadInk.inkYou,
          StampButtonInk.green => StampPadInk.green,
          StampButtonInk.ink => StampPadInk.ink,
        },
        sub: button.sub,
        ring: button.ring,
        w: button.w,
        h: button.h,
        size: button.size,
        ghost: button.ghost,
        dashed: button.dashed,
      ),
      say: button.spoken,
    );
    button.onStamp?.call(impression);
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.button;
    final params = StampButtonParams(
      ink: button.tone,
      disabled: button.disabled,
    );
    final source = RecipeInkSource(
      stampButtonRecipe,
      params,
      json: params.toJson(),
    );
    return Semantics(
      container: true,
      button: true,
      enabled: !button.disabled,
      label: button.semanticLabel,
      child: InkInteraction(
        enabled: !button.disabled,
        onActivate: _press,
        states: button.forcedStates,
        focusNode: button.focusNode,
        autofocus: button.autofocus,
        disabledMouseCursor: SystemMouseCursors.forbidden,
        builder: (context, states) => _body(context, source, states),
      ),
    );
  }

  Widget _body(BuildContext context, InkSource source, Set<InkState> states) {
    final button = widget.button;
    final theme = LooseleafTheme.of(context);
    final lift = switch ((
      states.contains(InkState.pressed),
      states.contains(InkState.hovered),
    )) {
      (true, _) => InkMotion.pressSink,
      (false, true) => -1.0,
      _ => 0.0,
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(end: lift),
      duration: InkMotion.of(context, InkMotion.press),
      curve: InkMotion.easeOut,
      builder: (context, offset, child) =>
          Transform.translate(offset: Offset(0, offset), child: child),
      child: InkContent(
        style: theme.typography
            .face(
              KevinSansFace.type,
              cssSize: 16,
              cssLineHeight: 1.5,
              fontWeight: FontWeight.w700,
              color: switch (button.disabled) {
                true => theme.colors.pencilText,
                false => theme.colors.ink,
              },
            )
            .copyWith(letterSpacing: _letterSpacing),
        iconSize: Spacing.d16,
        wrap: false,
        child: InkSurface(
          source: source,
          seed: inkSeed(button.seed),
          states: states,
          sinkSelf: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: Spacing.d112),
            child: SizedBox(
              height: stampKnob + _dieHeight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: stampKnob,
                  left: Spacing.d24,
                  right: Spacing.d24,
                  bottom: Spacing.d8,
                ),
                child: Center(
                  widthFactor: 1,
                  child: button.child ?? Text(button.spoken),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
