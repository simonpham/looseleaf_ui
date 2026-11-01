import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/ink_motion.dart';
import 'package:looseleaf_ui/src/surface/ink_state.dart';
import 'package:looseleaf_ui/src/surface/ink_surface_motion.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Paints an ink frame behind a widget, like upstream `InkSvg`
/// (`src/lib/ink/react/svg.tsx`): the viewBox is the frame's box grown by
/// its pad, stretched over the widget's size grown by the same pad.
class InkSurfacePainter extends CustomPainter {
  InkSurfacePainter({
    required this.source,
    required this.cache,
    required this.seed,
    required this.theme,
    required this.currentColor,
    required this.states,
    required this.lazy,
    required this.motion,
    required this.sinkSelf,
    this.pad,
    this.onFrame,
    super.repaint,
  });

  final InkSource source;
  final InkFrameCache cache;
  final String seed;
  final LooseleafThemeData theme;
  final Color currentColor;
  final Set<InkState> states;
  final Set<String> lazy;
  final InkSurfaceMotion motion;
  final bool sinkSelf;
  final double? pad;

  /// Called with each frame painted, so the surface learns its layers.
  final void Function(InkFrame frame)? onFrame;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final frame = cache.frame(
      source,
      InkFrameRequest(
        box: InkFrameRequest.bucketBox(size),
        seed: seed,
        tier: theme.tier,
        density: theme.density,
        textDirection: theme.textDirection,
        knobs: theme.resolvedKnobs,
        pad: pad,
        lazy: lazy,
      ),
    );
    onFrame?.call(frame);
    final framePad = frame.pad;
    final scaleX = (size.width + 2 * framePad) / (frame.width + 2 * framePad);
    final scaleY = (size.height + 2 * framePad) / (frame.height + 2 * framePad);
    canvas.save();
    final tilt = motion.tilt.value;
    if (tilt != 0) {
      final center = size.center(Offset.zero);
      canvas.translate(center.dx, center.dy);
      canvas.rotate(tilt);
      canvas.translate(-center.dx, -center.dy);
    }
    canvas.translate(-framePad, -framePad);
    canvas.scale(scaleX, scaleY);
    canvas.translate(framePad, framePad);
    final isolated = frame.usesBlend;
    if (isolated) {
      canvas.saveLayer(
        Rect.fromLTWH(
          -framePad,
          -framePad,
          frame.width + 2 * framePad,
          frame.height + 2 * framePad,
        ).inflate(framePad),
        Paint(),
      );
    }
    final hasRest = frame.has(InkLayers.rest);
    final context = InkPaintContext(
      theme: theme,
      currentColor: currentColor,
      state: InkStateEffects(
        hidden: motion.hidden,
        partShift: motion.partShift.value,
      ),
    );
    for (final layer in frame.layers) {
      _paintLayer(canvas, frame, layer, context, hasRest: hasRest);
    }
    if (isolated) canvas.restore();
    canvas.restore();
  }

  void _paintLayer(
    Canvas canvas,
    InkFrame frame,
    String layer,
    InkPaintContext context, {
    required bool hasRest,
  }) {
    final document = frame.documents[layer];
    if (document == null) return;
    final state = InkState.ofLayer(layer);
    final always =
        layer == InkLayers.rest || (!hasRest && _alwaysWithoutRest(state));
    final opacity = switch ((always, state)) {
      (true, _) => 1.0,
      (false, final shown?) => motion.layerOpacity(shown),
      (false, null) => 0.0,
    };
    if (opacity <= 0) return;
    canvas.save();
    if (layer == InkLayers.rest) {
      final sunk = motion.sink.value * InkMotion.pressSink;
      final dy = switch (sinkSelf) {
        true => 0.0,
        false => sunk,
      };
      canvas.translate(sunk * 0.6, dy);
    }
    if (state == InkState.checked || state == InkState.indeterminate) {
      _pop(canvas, frame.boundsOf(layer), switch (always) {
        true => 1,
        false => motion.pop(state ?? InkState.checked),
      });
    }
    InkPainter(document, context).paintLayer(canvas, layer, opacity: opacity);
    canvas.restore();
  }

  static bool _alwaysWithoutRest(InkState? state) => switch (state) {
    InkState.disabled ||
    InkState.invalid ||
    InkState.checked ||
    InkState.indeterminate ||
    InkState.open ||
    InkState.busy => true,
    _ => false,
  };

  static void _pop(Canvas canvas, Rect? bounds, double progress) {
    if (progress >= 1 || bounds == null) return;
    final scale = InkMotion.popScale + (1 - InkMotion.popScale) * progress;
    final center = bounds.center;
    canvas.translate(center.dx, center.dy);
    canvas.rotate(InkMotion.popRotation * (1 - progress));
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);
  }

  @override
  bool shouldRepaint(InkSurfacePainter oldDelegate) =>
      oldDelegate.source != source ||
      oldDelegate.cache != cache ||
      oldDelegate.seed != seed ||
      oldDelegate.theme != theme ||
      oldDelegate.currentColor != currentColor ||
      oldDelegate.pad != pad ||
      oldDelegate.sinkSelf != sinkSelf ||
      !setEquals(oldDelegate.lazy, lazy) ||
      !setEquals(oldDelegate.states, states);
}
