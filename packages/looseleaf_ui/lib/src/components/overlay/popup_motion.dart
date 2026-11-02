import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// How a popup comes and goes.
enum PopupMotionStyle {
  /// Fades in, grows from 95 % and slides 8 px off its anchor; fades and
  /// shrinks out (popovers, menus, tooltips: `animate-in fade-in-0
  /// zoom-in-95 slide-in-from-*-2`), over `--ll-dur-pop`.
  pop,

  /// Drops onto the desk with a little turn and settle (`ll-sheet-drop`,
  /// dialogs), over `--ll-dur-sheet`; fades and shrinks out over
  /// `--ll-dur-fade`.
  sheetDrop,

  /// Fades in and out (`fade-in-0`), over `--ll-dur-sheet`; scrims.
  fade,

  /// Fades in rising 64 px; fades out sinking 32 px and shrinking to 95 %
  /// (a dialog on a phone: `slide-in-from-bottom-16`,
  /// `slide-out-to-bottom-8 zoom-out-95`), over `--ll-dur-fade`.
  rise,

  /// Appears and goes at once.
  none;

  /// How long the entrance takes.
  Duration get enter => switch (this) {
    PopupMotionStyle.pop => InkMotion.pop,
    PopupMotionStyle.sheetDrop || PopupMotionStyle.fade => InkMotion.sheet,
    PopupMotionStyle.rise => InkMotion.fade,
    PopupMotionStyle.none => Duration.zero,
  };

  /// How long the exit takes.
  Duration get exit => switch (this) {
    PopupMotionStyle.pop => InkMotion.pop,
    PopupMotionStyle.sheetDrop || PopupMotionStyle.rise => InkMotion.fade,
    PopupMotionStyle.fade => InkMotion.sheet,
    PopupMotionStyle.none => Duration.zero,
  };
}

/// Animates [child] in and out with [style] as [animation] runs forward
/// (entering) or in reverse (leaving). A popup on [side] of its anchor
/// slides in from the anchor and grows from the anchor's side (Radix's
/// `transform-origin`), lined up by [align].
///
/// Mirrors the `animate-in` / `animate-out` classes of upstream overlays and
/// the `ll-sheet-drop` keyframes of `src/styles/looseleaf.css`.
class PopupMotion extends StatelessWidget {
  const PopupMotion({
    super.key,
    required this.animation,
    required this.child,
    this.style = PopupMotionStyle.pop,
    this.side,
    this.align = OverlayAlign.center,
  });

  /// `--ll-ease-dialog`.
  static const Curve dialogCurve = Cubic(0.2, 0.85, 0.25, 1.08);

  /// CSS `ease`, the default timing of `animate-in`.
  static const Curve ease = Cubic(0.25, 0.1, 0.25, 1);

  /// The slide of `slide-in-from-*-2`, in px.
  static const double slide = 8;

  /// The rise of `slide-in-from-bottom-16`, in px.
  static const double rise = 64;

  /// The fall of `slide-out-to-bottom-8`, in px.
  static const double fall = 32;

  /// 0 hidden, 1 shown.
  final Animation<double> animation;

  /// The popup.
  final Widget child;

  /// How it moves.
  final PopupMotionStyle style;

  /// The side of the anchor it opened on, if anchored.
  final OverlaySide? side;

  /// Its alignment along that side.
  final OverlayAlign align;

  Alignment get _origin {
    final cross = switch (align) {
      OverlayAlign.start => -1.0,
      OverlayAlign.center => 0.0,
      OverlayAlign.end => 1.0,
    };
    return switch (side) {
      null => Alignment.center,
      OverlaySide.bottom => Alignment(cross, -1),
      OverlaySide.top => Alignment(cross, 1),
      OverlaySide.right => Alignment(-1, cross),
      OverlaySide.left => Alignment(1, cross),
    };
  }

  Offset _from(double distance) => switch (side) {
    null => Offset.zero,
    OverlaySide.bottom => Offset(0, -distance),
    OverlaySide.top => Offset(0, distance),
    OverlaySide.right => Offset(-distance, 0),
    OverlaySide.left => Offset(distance, 0),
  };

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final t = animation.value;
      final leaving = animation.status == AnimationStatus.reverse;
      final (opacity, offset, turn, scale) = switch ((style, leaving)) {
        (PopupMotionStyle.none, _) => (1.0, Offset.zero, 0.0, 1.0),
        (PopupMotionStyle.fade, _) => (t, Offset.zero, 0.0, 1.0),
        (PopupMotionStyle.sheetDrop, false) => _drop(t),
        (PopupMotionStyle.rise, false) => _rise(ease.transform(t), rise, 1),
        (PopupMotionStyle.rise, true) => _rise(ease.transform(t), fall, 0.95),
        (PopupMotionStyle.pop, false) => _pop(ease.transform(t), true),
        _ => _pop(ease.transform(t), false),
      };
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: turn * math.pi / 180,
            child: Transform.scale(
              scale: scale,
              alignment: _origin,
              child: child,
            ),
          ),
        ),
      );
    },
  );

  (double, Offset, double, double) _pop(double t, bool entering) => (
    t,
    switch (entering) {
      true => _from(slide * (1 - t)),
      false => Offset.zero,
    },
    0,
    0.95 + 0.05 * t,
  );

  (double, Offset, double, double) _rise(double t, double from, double scale) =>
      (t, Offset(0, from * (1 - t)), 0, scale + (1 - scale) * t);

  (double, Offset, double, double) _drop(double time) {
    if (time < 0.7) {
      final k = dialogCurve.transform((time / 0.7).clamp(0.0, 1.0));
      return (k, Offset(0, -14 + 15 * k), -1.2 + 1.35 * k, 1.02 - 0.022 * k);
    }
    final k = dialogCurve.transform(((time - 0.7) / 0.3).clamp(0.0, 1.0));
    return (1, Offset(0, 1 - k), 0.15 * (1 - k), 0.998 + 0.002 * k);
  }
}
