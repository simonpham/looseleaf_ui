import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:looseleaf_ui/src/surface/ink_motion.dart';
import 'package:looseleaf_ui/src/surface/ink_state.dart';
import 'package:looseleaf_ui/src/surface/ink_tween.dart';

/// The animated values of an ink surface, driven by its [InkState]s the way
/// the layer rules of `src/styles/looseleaf.css` drive an ink `<svg>`.
class InkSurfaceMotion {
  InkSurfaceMotion(this._vsync)
    : tilt = InkTween(_vsync, 0),
      partShift = InkTween(_vsync, 0),
      sink = InkTween(_vsync, 0),
      swipe = InkTween(_vsync, 1),
      reveal = InkTween(_vsync, 1);

  final TickerProvider _vsync;
  final Map<InkState, InkTween> _layers = {};
  final Map<InkState, InkTween> _pops = {};
  final Map<InkState, InkTween> _hides = {};
  Set<InkState> _previous = const {};

  /// The frame's rotation in radians (the hover tilt).
  final InkTween tilt;

  /// The `fill` part misregistration multiplier.
  final InkTween partShift;

  /// How far the rest layer has sunk (0 → 1 when pressed).
  final InkTween sink;

  /// How far `swipe` parts have wiped in (see [InkStateEffects.swipe]).
  final InkTween swipe;

  /// How far `reveal` parts have drawn on (see [InkStateEffects.reveal]).
  final InkTween reveal;

  Listenable get listenable => Listenable.merge([
    tilt.animation,
    partShift.animation,
    sink.animation,
    swipe.animation,
    reveal.animation,
    for (final tween in [..._layers.values, ..._pops.values, ..._hides.values])
      tween.animation,
  ]);

  /// The opacity of the layer [state] shows.
  double layerOpacity(InkState state) => _layers[state]?.value ?? 0;

  /// How far a `checked` / `indeterminate` layer has popped in (0 → 1).
  double pop(InkState state) => _pops[state]?.value ?? 0;

  /// State token to the opacity of elements hidden on it.
  Map<String, double> get hidden => {
    for (final MapEntry(key: state, value: tween) in _hides.entries)
      if (tween.value < 1) state.layer: tween.value,
  };

  /// Animates to [states]. [hasHover] says whether the frame has a hover
  /// layer (only then does it tilt); [still] disables the tilt;
  /// [animate] false jumps. [swipeOnHover] wipes `swipe` parts in as hover
  /// starts; [drawOn] draws `reveal` parts on as `checked` or
  /// `indeterminate` turns on, over [drawOnDuration]. Returns true when new tweens were created, so
  /// the caller re-reads [listenable].
  bool update(
    Set<InkState> states, {
    required bool hasHover,
    required bool still,
    required bool animate,
    bool swipeOnHover = false,
    bool drawOn = false,
    Duration drawOnDuration = InkMotion.sheet,
  }) {
    final created = _ensure(states);
    Duration time(Duration duration) => switch (animate) {
      true => duration,
      false => Duration.zero,
    };
    final disabled = states.contains(InkState.disabled);
    final pressed = states.contains(InkState.pressed) && !disabled;
    final hovered = states.contains(InkState.hovered) && !disabled;
    for (final MapEntry(key: state, value: tween) in _layers.entries) {
      final on = switch (state) {
        InkState.hovered => hovered && !pressed,
        InkState.pressed => pressed,
        _ => states.contains(state),
      };
      final showTime = switch (state) {
        InkState.pressed => InkMotion.press,
        _ => InkMotion.fade,
      };
      tween.to(
        _unit(on),
        time(switch (on) {
          true => showTime,
          false => InkMotion.press,
        }),
        InkMotion.easeOut,
      );
    }
    for (final MapEntry(key: state, value: tween) in _pops.entries) {
      final on = states.contains(state);
      tween.to(
        _unit(on),
        time(switch (on) {
          true => InkMotion.pop,
          false => InkMotion.press,
        }),
        switch (on) {
          true => InkMotion.popCurve,
          false => InkMotion.easeOut,
        },
      );
    }
    for (final MapEntry(key: state, value: tween) in _hides.entries) {
      final on = switch (state) {
        InkState.hovered => hovered,
        InkState.pressed => pressed,
        _ => states.contains(state),
      };
      tween.to(
        _unit(!on),
        time(switch (on) {
          true => InkMotion.press,
          false => InkMotion.fade,
        }),
        InkMotion.easeOut,
      );
    }
    final tilted = hovered && !pressed && hasHover && !still;
    tilt.to(
      switch (tilted) {
        true => InkMotion.hoverTilt,
        false => 0,
      },
      time(switch (pressed) {
        true => InkMotion.press,
        false => InkMotion.hover,
      }),
      switch (pressed) {
        true => InkMotion.easeOut,
        false => InkMotion.settle,
      },
    );
    final shift = switch ((pressed, hovered && hasHover)) {
      (true, _) => InkMotion.pressMisregister,
      (false, true) => InkMotion.hoverMisregister,
      _ => 0.0,
    };
    final pressTime = time(switch (pressed) {
      true => InkMotion.press,
      false => InkMotion.hover,
    });
    final pressCurve = switch (pressed) {
      true => InkMotion.easeOut,
      false => InkMotion.settle,
    };
    partShift.to(shift, pressTime, pressCurve);
    sink.to(_unit(pressed), pressTime, pressCurve);
    _playParts(
      states,
      hovered: hovered,
      swipeOnHover: swipeOnHover && animate,
      drawOn: drawOn && animate,
      drawOnDuration: drawOnDuration,
    );
    return created;
  }

  void _playParts(
    Set<InkState> states, {
    required bool hovered,
    required bool swipeOnHover,
    required bool drawOn,
    required Duration drawOnDuration,
  }) {
    final wasHovered = _hoveredIn(_previous);
    final wasMarked = _markOf(_previous);
    _previous = {...states};
    if (!hovered) swipe.to(1, Duration.zero, InkMotion.easeOut);
    if (hovered && !wasHovered && swipeOnHover) {
      swipe.replay(0, 1, InkMotion.sheet, InkMotion.easeOut);
    }
    final marked = _markOf(states);
    if (marked == null || !drawOn) {
      reveal.to(1, Duration.zero, InkMotion.easeOut);
      return;
    }
    if (marked == wasMarked) return;
    reveal.replay(0, 1, drawOnDuration, InkMotion.easeOut);
  }

  static bool _hoveredIn(Set<InkState> states) =>
      states.contains(InkState.hovered) && !states.contains(InkState.disabled);

  static InkState? _markOf(Set<InkState> states) {
    if (states.contains(InkState.checked)) return InkState.checked;
    if (states.contains(InkState.indeterminate)) return InkState.indeterminate;
    return null;
  }

  bool _ensure(Set<InkState> states) {
    var created = false;
    for (final state in InkState.values) {
      if (_layers.containsKey(state)) continue;
      if (!states.contains(state)) continue;
      _layers[state] = InkTween(_vsync, 0);
      _hides[state] = InkTween(_vsync, 1);
      if (state == InkState.checked || state == InkState.indeterminate) {
        _pops[state] = InkTween(_vsync, 0);
      }
      created = true;
    }
    return created;
  }

  static double _unit(bool on) => switch (on) {
    true => 1,
    false => 0,
  };

  void dispose() {
    for (final tween in [
      ..._layers.values,
      ..._pops.values,
      ..._hides.values,
    ]) {
      tween.dispose();
    }
    tilt.dispose();
    partShift.dispose();
    sink.dispose();
    swipe.dispose();
    reveal.dispose();
  }
}
