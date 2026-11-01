import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' as ink;
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
        swipe: motion.swipe.value,
        reveal: motion.reveal.value,
      ),
    );
    switch (frame.sheet) {
      case final sheet?:
        _paintSheet(canvas, frame, sheet, context, hasRest: hasRest);
      case null:
        for (final layer in frame.layers) {
          _paintLayer(canvas, frame, layer, context, hasRest: hasRest);
        }
    }
    if (isolated) canvas.restore();
    canvas.restore();
  }

  static bool _always(String layer, InkState? state, {required bool hasRest}) =>
      layer == InkLayers.rest || (!hasRest && _alwaysWithoutRest(state));

  double _opacityOf(String layer, {required bool hasRest}) {
    final state = InkState.ofLayer(layer);
    return switch ((_always(layer, state, hasRest: hasRest), state)) {
      (true, _) => 1.0,
      (false, final shown?) => motion.layerOpacity(shown),
      (false, null) => 0.0,
    };
  }

  void _paintSheet(
    Canvas canvas,
    InkFrame frame,
    InkSheet sheet,
    InkPaintContext context, {
    required bool hasRest,
  }) {
    for (final cast in sheet.casts) {
      _paintCast(canvas, frame, cast);
    }
    final box = Rect.fromLTWH(
      -frame.pad,
      -frame.pad,
      frame.width + 2 * frame.pad,
      frame.height + 2 * frame.pad,
    );
    for (final piece in sheet.pieces) {
      switch (piece) {
        case InkSheetFace(:final spec, :final layer, :final path):
          final opacity = _opacityOf(layer, hasRest: hasRest);
          if (opacity <= 0) continue;
          final faded = opacity < 1;
          if (faded) {
            canvas.saveLayer(
              box,
              Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
            );
          }
          PaperFacePainter.paint(
            canvas,
            path,
            stock: spec.stock,
            seed: spec.seed,
            theme: theme,
            box: box,
            veil: spec.veil,
            textures: context.textures,
          );
          if (faded) canvas.restore();
        case InkSheetRun(:final groups):
          for (final (layer, part) in groups) {
            _paintLayer(
              canvas,
              frame,
              layer,
              context,
              hasRest: hasRest,
              document: sheet.document,
              part: part,
            );
          }
      }
    }
  }

  void _paintCast(Canvas canvas, InkFrame frame, ink.FaceSpec spec) {
    final cast = spec.cast;
    if (cast == null) return;
    final [top, right, bottom, left] = cast.inset;
    final rect = Rect.fromLTRB(
      left,
      top,
      frame.width - right,
      frame.height - bottom,
    );
    final radius = cast.radius;
    final box = switch (radius) {
      [final tl, final tr, final br, final bl] => RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(tl),
        topRight: Radius.circular(tr),
        bottomRight: Radius.circular(br),
        bottomLeft: Radius.circular(bl),
      ),
      _ => RRect.fromRectAndRadius(rect, Radius.zero),
    };
    PaperShadowPainter.paint(
      canvas,
      box,
      PaperShadowPainter.layersOf(cast.kind, all: radius != null),
      theme: theme,
    );
  }

  void _paintLayer(
    Canvas canvas,
    InkFrame frame,
    String layer,
    InkPaintContext context, {
    required bool hasRest,
    InkDocument? document,
    String? part,
  }) {
    final source = document ?? frame.documents[layer];
    if (source == null) return;
    final state = InkState.ofLayer(layer);
    final opacity = _opacityOf(layer, hasRest: hasRest);
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
      _pop(canvas, frame.boundsOf(layer), switch (_always(
        layer,
        state,
        hasRest: hasRest,
      )) {
        true => 1,
        false => motion.pop(state ?? InkState.checked),
      });
    }
    InkPainter(
      source,
      context,
    ).paintLayer(canvas, part ?? layer, opacity: opacity);
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
