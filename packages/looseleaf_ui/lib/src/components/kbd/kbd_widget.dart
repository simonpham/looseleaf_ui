import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A keyboard key: a pencil keycap with a shaded thickness behind its
/// label. While a pointer is down on it, or while [pressed], the thickness
/// goes and the cap sinks onto its base.
///
/// Decorative: not focusable, no role; screen readers read the label.
///
/// ```dart
/// const Kbd(child: Text('Esc'))
/// ```
///
/// Mirrors `Kbd` in upstream `src/components/ui/kbd.tsx`.
class Kbd extends StatefulWidget {
  const Kbd({
    super.key,
    required this.child,
    this.pressed = false,
    this.seed,
  });

  /// The key's label, usually a [Text]; icons inside are 14 px.
  final Widget child;

  /// Draws the key as held down (upstream `data-pressed`).
  final bool pressed;

  /// Pins the hand: the same seed always draws the same keycap.
  final String? seed;

  @override
  State<Kbd> createState() => _KbdState();
}

class _KbdState extends State<Kbd> with InkSeed {
  static final _source = RecipeInkSource(
    kbdRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  /// `active:translate-y-[1.6px]`.
  static const double _pressTravel = 1.6;

  /// `h-6 calm:h-5`.
  static const _height = ByDensity(
    comfortable: Spacing.d24,
    compact: Spacing.d24,
    calm: Spacing.d20,
  );

  bool _pointerDown = false;

  void _setPointerDown(bool down) {
    if (_pointerDown == down) return;
    setState(() => _pointerDown = down);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final pressed = widget.pressed || _pointerDown;
    final depth = switch (calm) {
      true => 0.0,
      false => keyDepth,
    };
    return Listener(
      onPointerDown: (_) => _setPointerDown(true),
      onPointerUp: (_) => _setPointerDown(false),
      onPointerCancel: (_) => _setPointerDown(false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          end: switch (pressed) {
            true => _pressTravel,
            false => 0,
          },
        ),
        duration: InkMotion.of(context, InkMotion.press),
        curve: InkMotion.easeOut,
        builder: (context, sink, child) =>
            Transform.translate(offset: Offset(0, sink), child: child),
        child: InkContent(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 14,
            cssLineHeight: 1,
            color: theme.colors.inkMuted,
          ),
          iconSize: Spacing.d14,
          wrap: false,
          child: InkSurface(
            source: _source,
            seed: inkSeed(widget.seed),
            states: {if (pressed) InkState.pressed},
            sinkSelf: true,
            still: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: Spacing.d24),
              child: SizedBox(
                height: _height.of(context),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: Spacing.d4,
                    right: Spacing.d4 + depth,
                    bottom: depth,
                  ),
                  child: Center(widthFactor: 1, child: widget.child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
