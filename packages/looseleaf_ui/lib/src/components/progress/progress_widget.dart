import 'dart:async';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/progress/progress.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// How far along something is: a pencil-hatched track filled with marker
/// up to [value]. Without a value it is indeterminate: a marker scribble
/// slides across, and holds still mid-bar where motion is reduced.
///
/// Value changes glide; right to left, the marker grows from the right. A
/// status display, not a control: not focusable. Name it with
/// [semanticLabel].
///
/// ```dart
/// Progress(value: 45, semanticLabel: 'Upload')
/// const Progress(tone: ProgressTone.green, semanticLabel: 'Waiting')
/// ```
///
/// Mirrors upstream `src/components/ui/progress.tsx`.
class Progress extends StatefulWidget {
  const Progress({
    super.key,
    this.value,
    this.max = 100,
    this.size = ProgressSize.regular,
    this.tone = ProgressTone.marker,
    this.seed,
    this.semanticLabel,
    this.semanticValue,
  });

  /// The progress from 0 to [max], clamped; null or NaN is indeterminate.
  final double? value;

  /// The value of a full bar; anything not finite and positive is 100.
  final double max;

  final ProgressSize size;

  /// The marker ink.
  final ProgressTone tone;

  /// Pins the hand: the same seed always draws the same track and fill.
  final String? seed;

  /// The accessible name (upstream `aria-label`).
  final String? semanticLabel;

  /// Text read instead of the number, such as "Step 2 of 5"
  /// (`aria-valuetext`).
  final String? semanticValue;

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress>
    with InkSeed, SingleTickerProviderStateMixin {
  /// `ll-progress-slide`'s 1.6 s lap.
  static const Duration _slide = Duration(milliseconds: 1600);

  /// The indeterminate window's width, as a fraction of the bar.
  static const double _window = 0.4;

  /// Where the window rests where motion is reduced: `inset(… 30% … 30%)`.
  static const double _restInset = 0.3;

  static final _track = RecipeInkSource(
    progressRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: _slide,
  );
  bool _still = false;

  double get _max => switch (widget.max.isFinite && widget.max > 0) {
    true => widget.max,
    false => 100,
  };

  double? get _clamped {
    final value = widget.value;
    if (value == null || value.isNaN) return null;
    return value.clamp(0, _max).toDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = InkMotion.reducedIn(context);
    _run();
  }

  @override
  void didUpdateWidget(Progress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _run();
  }

  void _run() {
    if (_still || _clamped != null) {
      _clock.stop();
      return;
    }
    if (_clock.isAnimating) return;
    unawaited(_clock.repeat());
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clamped = _clamped;
    final seed = inkSeed(widget.seed);
    final params = ProgressFillParams(
      tone: widget.tone,
      indeterminate: clamped == null,
    );
    final fill = InkSurface(
      source: RecipeInkSource(
        progressFillRecipe,
        params,
        json: params.toJson(),
      ),
      seed: '$seed:fill',
      still: true,
    );
    return _semantics(
      clamped,
      SizedBox(
        height: widget.size.height,
        child: InkSurface(
          source: _track,
          seed: seed,
          still: true,
          child: switch (clamped) {
            null => _sliding(fill),
            final value => _filled(context, value / _max, fill),
          },
        ),
      ),
    );
  }

  Widget _semantics(double? clamped, Widget child) {
    final label = widget.semanticLabel;
    if (widget.semanticValue case final text?) {
      return Semantics(
        container: true,
        label: label,
        value: text,
        child: child,
      );
    }
    if (clamped == null) {
      return Semantics(container: true, label: label, child: child);
    }
    return Semantics(
      container: true,
      role: SemanticsRole.progressBar,
      label: label,
      minValue: '0',
      maxValue: _format(_max),
      value: _format(clamped),
      child: child,
    );
  }

  static String _format(double value) =>
      switch (value == value.roundToDouble()) {
        true => '${value.round()}',
        false => '$value',
      };

  Widget _filled(BuildContext context, double fraction, Widget fill) =>
      TweenAnimationBuilder<double>(
        tween: Tween(end: fraction),
        duration: InkMotion.of(context, InkMotion.sheet),
        curve: InkMotion.easeOut,
        builder: (context, shown, child) => ClipRect(
          clipper: ProgressClipper(
            start: 0,
            end: shown,
            direction: Directionality.of(context),
          ),
          child: child,
        ),
        child: fill,
      );

  Widget _sliding(Widget fill) {
    if (_still) {
      return ClipRect(
        clipper: ProgressClipper(
          start: _restInset,
          end: 1 - _restInset,
          direction: Directionality.of(context),
        ),
        child: fill,
      );
    }
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, child) {
        final start = -_window + (1 + _window) * _clock.value;
        return ClipRect(
          clipper: ProgressClipper(
            start: start,
            end: start + _window,
            direction: Directionality.of(context),
          ),
          child: child,
        );
      },
      child: fill,
    );
  }
}
