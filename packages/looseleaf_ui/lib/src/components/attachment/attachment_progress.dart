import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_pulse.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The upload bar under an [AttachmentTitle]: a paper pill with a marker
/// fill up to [value] out of [max]. The fill is drawn once and only its
/// window moves, so a fast upload never redraws. Without [value] the bar is
/// full and breathes (processing).
///
/// ```dart
/// AttachmentProgress(value: 42, semanticLabel: 'Upload progress')
/// ```
///
/// Mirrors `AttachmentProgress` in upstream
/// `src/components/ui/attachment.tsx`.
class AttachmentProgress extends StatefulWidget {
  const AttachmentProgress({
    super.key,
    this.value,
    this.max = 100,
    this.seed,
    this.semanticLabel,
  });

  /// How far along; null for indeterminate.
  final double? value;

  /// The value of a full bar.
  final double max;

  /// Pins the hand.
  final String? seed;

  /// The bar's name, like `Upload progress`.
  final String? semanticLabel;

  @override
  State<AttachmentProgress> createState() => _AttachmentProgressState();
}

class _AttachmentProgressState extends State<AttachmentProgress> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final params = AttachmentProgressParams(indeterminate: value == null);
    final InkSource full = RecipeInkSource(
      attachmentProgressRecipe,
      params,
      json: params.toJson(),
    );
    final seed = inkSeed(widget.seed);
    final direction = Directionality.of(context);
    Widget pill(InkSource source) => InkSurface(
      source: source,
      seed: seed,
      still: true,
      child: const SizedBox(
        width: double.infinity,
        height: AttachmentMetrics.progressHeight,
      ),
    );
    final track = pill(WithoutPartInkSource(full, 'bar'));
    Widget fill(double shown) => ClipRect(
      clipper: _BarClipper(end: shown, direction: direction),
      child: pill(full),
    );
    final Widget bar = switch (value) {
      null => Stack(
        children: [
          track,
          Positioned.fill(
            child: AttachmentPulse(active: true, child: fill(1)),
          ),
        ],
      ),
      final current => TweenAnimationBuilder<double>(
        tween: Tween(end: _fraction(current)),
        duration: InkMotion.of(context, InkMotion.sheet),
        curve: InkMotion.easeOut,
        builder: (context, shown, _) => Stack(
          children: [
            track,
            Positioned.fill(child: fill(shown)),
          ],
        ),
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(top: AttachmentMetrics.progressGap),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AttachmentMetrics.progressMinWidth,
        ),
        child: _semantics(value, bar),
      ),
    );
  }

  double _fraction(double value) {
    if (widget.max <= 0) return 1;
    return (value / widget.max).clamp(0.0, 1.0);
  }

  Widget _semantics(double? value, Widget child) {
    if (value == null) {
      return Semantics(
        container: true,
        label: widget.semanticLabel,
        child: child,
      );
    }
    return Semantics(
      container: true,
      role: SemanticsRole.progressBar,
      label: widget.semanticLabel,
      minValue: '0',
      maxValue: '${widget.max.round()}',
      value: '${value.round()}',
      child: child,
    );
  }
}

/// Clips the drawing to the bar's band (inside the outline) from the
/// reading start to [end] of the width, so the fill shows over the track
/// without drawing the outline twice.
class _BarClipper extends CustomClipper<Rect> {
  const _BarClipper({required this.end, required this.direction});

  /// The bar's inset from the pill's edge (`pillPoly(2.4, 2.4, …)`).
  static const double _inset = 2.4;

  final double end;
  final TextDirection direction;

  @override
  Rect getClip(Size size) {
    final band = Rect.fromLTRB(
      _inset,
      _inset,
      size.width - _inset,
      size.height - _inset,
    );
    final width = size.width * end;
    return switch (direction) {
      TextDirection.ltr => Rect.fromLTRB(
        band.left,
        band.top,
        width.clamp(band.left, band.right),
        band.bottom,
      ),
      TextDirection.rtl => Rect.fromLTRB(
        (size.width - width).clamp(band.left, band.right),
        band.top,
        band.right,
        band.bottom,
      ),
    };
  }

  @override
  bool shouldReclip(_BarClipper oldClipper) =>
      oldClipper.end != end || oldClipper.direction != direction;
}
