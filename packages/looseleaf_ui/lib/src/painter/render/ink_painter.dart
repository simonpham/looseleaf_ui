import 'dart:math' as math;
import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/markup.dart';
import 'package:looseleaf_ui/src/painter/render/grain_mask.dart';
import 'package:looseleaf_ui/src/painter/render/ink_dash.dart';
import 'package:looseleaf_ui/src/painter/render/ink_paint_context.dart';
import 'package:looseleaf_ui/src/painter/render/ink_shaders.dart';
import 'package:looseleaf_ui/src/painter/render/ink_state_effects.dart';
import 'package:looseleaf_ui/src/painter/render/ink_text.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';

/// Paints a parsed [InkDocument] on a [Canvas], in the document's user units.
///
/// Mirrors how a browser renders the engine's SVG: inherited presentation
/// attributes, `use`, clip paths, luminance masks (grain masks included),
/// group opacity and `mix-blend-mode`, gradients and patterns.
class InkPainter {
  InkPainter(this.document, this.context) {
    _shaders = InkShaders(document, context, _paintPattern);
  }

  final InkDocument document;
  final InkPaintContext context;
  late final InkShaders _shaders;
  final Paint _paint = Paint()..isAntiAlias = true;
  int _useDepth = 0;

  /// Paints layer [name] with an extra [opacity].
  void paintLayer(Canvas canvas, String name, {double opacity = 1}) {
    final layer = document.layers[name];
    if (layer == null || opacity <= 0) return;
    if (opacity >= 1) {
      _node(canvas, layer, InkStyle.initial);
      return;
    }
    canvas.saveLayer(
      layer.bounds?.inflate(1),
      Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
    );
    _node(canvas, layer, InkStyle.initial);
    canvas.restore();
  }

  void _paintPattern(Canvas canvas, List<InkNode> children) {
    for (final child in children) {
      _node(canvas, child, InkStyle.initial);
    }
  }

  void _node(Canvas canvas, InkNode node, InkStyle parent) {
    final effects = node.effects;
    var alpha = 1.0;
    if (effects.hideOn.isNotEmpty) {
      alpha = context.state.opacityFor(effects.hideOn);
    }
    if (effects.opacity case final opacity?) {
      alpha *= opacity.resolve(context.scalar).clamp(0.0, 1.0);
    }
    if (alpha <= 0) return;
    final style = node.style.inherit(parent);
    final shift = context.state.shiftFor(effects.part, effects.misregister);
    final partClip = context.state.clipFor(
      effects.part,
      node.bounds,
      context.theme.textDirection,
    );
    final mask = _mask(effects.maskId);
    final blend = switch (effects.blend) {
      InkBlend.none => null,
      InkBlend.theme => context.theme.blendMode,
      InkBlend.literal => effects.blendMode,
    };
    final foldAlpha =
        alpha < 1 && mask == null && blend == null && _paintsOnce(node, style);
    final layered = (alpha < 1 && !foldAlpha) || mask != null || blend != null;
    final saved =
        layered ||
        shift != Offset.zero ||
        partClip != null ||
        effects.transform != null ||
        effects.clipPathId != null;
    if (saved) canvas.save();
    if (shift != Offset.zero) canvas.translate(shift.dx, shift.dy);
    if (partClip != null) canvas.clipRect(partClip);
    if (layered) {
      final layerPaint = Paint()..color = Color.fromRGBO(0, 0, 0, alpha);
      if (blend != null) layerPaint.blendMode = blend;
      canvas.saveLayer(node.bounds?.inflate(2), layerPaint);
    }
    if (effects.transform case final transform?) {
      canvas.transform(transform.storage);
    }
    if (effects.clipPathId case final clipId?) _clip(canvas, clipId);
    _content(canvas, node, style, switch (foldAlpha) {
      true => alpha,
      false => 1,
    });
    if (mask != null) _applyMask(canvas, mask, node);
    if (layered) canvas.restore();
    if (saved) canvas.restore();
  }

  static bool _paintsOnce(InkNode node, InkStyle style) {
    if (node is! InkShapeNode) {
      return node is InkImageNode || node is InkTextNode;
    }
    final fills = style.fill is! InkNoPaint;
    final strokes = style.stroke is! InkNoPaint;
    return !(fills && strokes);
  }

  Object? _mask(String? id) {
    if (id == null) return null;
    final def = document.defs[id];
    if (def is InkMaskDef) return def;
    final grain = GrainMask.parse(id);
    if (grain == null) throw InkMarkupError('unknown mask #$id');
    return grain;
  }

  void _applyMask(Canvas canvas, Object mask, InkNode node) {
    if (mask case (final String kind, final int variant)) {
      final tile = context.textures.grain(kind);
      if (tile != null) GrainMask.apply(canvas, tile, kind, variant);
      return;
    }
    if (mask is! InkMaskDef) return;
    canvas.saveLayer(
      null,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..colorFilter = GrainMask.luminanceToAlpha,
    );
    final region = mask.region ?? _boxRegion(mask, node);
    if (region != null) {
      canvas.clipRect(region);
      canvas.drawRect(region, Paint()..color = const Color(0xFF000000));
    }
    for (final child in mask.children) {
      _node(canvas, child, InkStyle.initial);
    }
    canvas.restore();
  }

  static Rect? _boxRegion(InkMaskDef mask, InkNode node) {
    final fraction = mask.boundingBoxRegion;
    final box = node.bounds;
    if (fraction == null || box == null) return null;
    return Rect.fromLTWH(
      box.left + fraction.left * box.width,
      box.top + fraction.top * box.height,
      fraction.width * box.width,
      fraction.height * box.height,
    );
  }

  void _clip(Canvas canvas, String id) {
    final def = document.defs[id];
    if (def is! InkClipPathDef) throw InkMarkupError('unknown clip path #$id');
    Path? union;
    for (final child in def.children) {
      final path = _clipPathOf(child, InkStyle.initial);
      if (path == null) continue;
      union = switch (union) {
        null => path,
        final previous => Path.combine(PathOperation.union, previous, path),
      };
    }
    final clip = union ?? Path();
    if (def.transform case final transform?) {
      canvas.clipPath(clip.transform(transform.storage));
      return;
    }
    canvas.clipPath(clip);
  }

  Path? _clipPathOf(InkNode node, InkStyle parent) {
    final style = node.style.inherit(parent);
    final path = switch (node) {
      InkShapeNode(:final path) => _withFillType(path, style.clipRule),
      InkUseNode(:final href) => switch (document.elements[href]) {
        null => null,
        final target => _clipPathOf(target, style),
      },
      InkGroupNode(:final children) => _unionOf(children, style),
      _ => null,
    };
    final transform = node.effects.transform;
    if (path == null || transform == null) return path;
    return path.transform(transform.storage);
  }

  Path? _unionOf(List<InkNode> children, InkStyle style) {
    Path? union;
    for (final child in children) {
      final path = _clipPathOf(child, style);
      if (path == null) continue;
      union = switch (union) {
        null => path,
        final previous => Path.combine(PathOperation.union, previous, path),
      };
    }
    return union;
  }

  static Path _withFillType(Path path, PathFillType? type) {
    final wanted = type ?? PathFillType.nonZero;
    if (path.fillType == wanted) return path;
    return Path.from(path)..fillType = wanted;
  }

  void _content(Canvas canvas, InkNode node, InkStyle style, double alpha) {
    switch (node) {
      case InkGroupNode(:final children):
        for (final child in children) {
          _node(canvas, child, style);
        }
      case InkShapeNode():
        _shape(canvas, node, style, alpha);
      case InkUseNode(:final href, :final offset):
        _use(canvas, href, offset, style);
      case InkTextNode():
        InkText.paint(
          canvas,
          node,
          style,
          context,
          _shaders.resolveColor,
          alpha,
        );
      case InkImageNode(:final href, :final rect):
        final image = switch (href.startsWith('data:')) {
          true => context.textures.dataImage(href),
          false => _builtinImage(href),
        };
        if (image == null) return;
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          rect,
          Paint()
            ..filterQuality = FilterQuality.low
            ..color = Color.fromRGBO(0, 0, 0, alpha),
        );
    }
  }

  Image? _builtinImage(String id) {
    final match = RegExp(r'^ll-tex-([a-z]+)-img$').firstMatch(id);
    if (match == null) return null;
    return context.textures.paper(match[1] ?? '');
  }

  void _use(Canvas canvas, String href, Offset offset, InkStyle style) {
    final target = document.elements[href];
    final hasOffset = offset != Offset.zero;
    if (hasOffset) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
    }
    if (target != null && _useDepth < 8) {
      _useDepth++;
      _node(canvas, target, style);
      _useDepth--;
    }
    if (target == null) _builtinUse(canvas, href);
    if (hasOffset) canvas.restore();
  }

  void _builtinUse(Canvas canvas, String href) {
    final match = RegExp(r'^ll-tex-([a-z]+)-img$').firstMatch(href);
    final tile = InkTextures.paperTile(match?[1] ?? '');
    if (match == null || tile == null) {
      throw InkMarkupError('unknown use #$href');
    }
    final image = context.textures.paper(match[1] ?? '');
    if (image == null) return;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, tile.cssWidth, tile.cssHeight),
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  void _shape(Canvas canvas, InkShapeNode node, InkStyle style, double alpha) {
    final fill = style.fill ?? const InkNoPaint();
    if (fill is! InkNoPaint) {
      final opacity = (style.fillOpacity?.resolve(context.scalar) ?? 1) * alpha;
      if (_setPaint(canvas, fill, node.path, opacity)) {
        _paint.style = PaintingStyle.fill;
        final path = node.path;
        path.fillType = style.fillRule ?? PathFillType.nonZero;
        canvas.drawPath(path, _paint);
      }
    }
    final stroke = style.stroke ?? const InkNoPaint();
    final width = style.strokeWidth ?? 1;
    if (stroke is InkNoPaint || width <= 0) return;
    final opacity = (style.strokeOpacity?.resolve(context.scalar) ?? 1) * alpha;
    if (!_setPaint(canvas, stroke, node.path, opacity)) return;
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = style.strokeCap ?? StrokeCap.butt
      ..strokeJoin = style.strokeJoin ?? StrokeJoin.miter
      ..strokeMiterLimit = style.strokeMiterLimit ?? 4;
    canvas.drawPath(_strokePath(node, style), _paint);
  }

  Path _strokePath(InkShapeNode node, InkStyle style) {
    final InkStateEffects(:reveal, :revealDashes) = context.state;
    if (node.effects.part == 'reveal' && (reveal < 1 || revealDashes != null)) {
      return InkDash.revealed(node, reveal, dashes: revealDashes);
    }
    final dashes = style.dashArray ?? const [];
    if (dashes.isEmpty) return node.path;
    return InkDash.dashed(node, dashes, style.dashOffset ?? 0);
  }

  bool _setPaint(Canvas canvas, InkPaint paint, Path path, double opacity) {
    if (opacity <= 0) return false;
    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver;
    if (paint case InkUrlPaint(:final id)) {
      final def = document.defs[id];
      if (def == null) throw InkMarkupError('unknown paint #$id');
      final shader = _shaders.shader(
        def,
        path.getBounds(),
        _deviceScale(canvas),
      );
      if (shader == null) return false;
      _paint
        ..shader = shader
        ..color = Color.fromRGBO(0, 0, 0, opacity.clamp(0.0, 1.0));
      return true;
    }
    final color = _shaders.resolveColor(paint);
    if (color == null) return false;
    _paint.color = color.withValues(alpha: color.a * opacity.clamp(0.0, 1.0));
    return true;
  }

  static double _deviceScale(Canvas canvas) {
    final m = canvas.getTransform();
    final scale = math.sqrt(m[0] * m[0] + m[1] * m[1]);
    return scale.clamp(0.25, 8.0);
  }
}
