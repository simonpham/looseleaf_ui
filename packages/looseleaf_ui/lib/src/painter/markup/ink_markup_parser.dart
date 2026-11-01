import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_affine.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_attributes.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_bounds.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_def.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_document.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_effects.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_node.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_paint.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_scalar.dart';
import 'package:looseleaf_ui/src/painter/markup/ink_style.dart';
import 'package:looseleaf_ui/src/painter/markup/markup_element.dart';
import 'package:looseleaf_ui/src/painter/markup/markup_reader.dart';
import 'package:looseleaf_ui/src/painter/markup/number_scanner.dart';
import 'package:looseleaf_ui/src/painter/markup/path_data_parser.dart';
import 'package:looseleaf_ui/src/painter/markup/transform_parser.dart';

/// Turns ink markup into an [InkDocument], failing on anything unsupported.
class InkMarkupParser {
  final Map<String, InkNode> _elements = {};
  final Map<String, InkDef> _defs = {};
  bool _usesBlend = false;

  InkDocument parse(Map<String, String> parts) {
    final layers = <String, InkGroupNode>{};
    var chars = 0;
    for (final MapEntry(key: name, value: markup) in parts.entries) {
      chars += markup.length;
      final children = _nodes(MarkupReader(markup).read());
      layers[name] = InkGroupNode(
        style: InkStyle.empty,
        effects: InkEffects.none,
        children: children,
      );
    }
    final bounds = InkBounds(_elements);
    for (final layer in layers.values) {
      bounds.measure(layer, InkStyle.initial);
    }
    for (final def in _defs.values) {
      bounds.measureDef(def);
    }
    return InkDocument(
      layers: layers,
      elements: _elements,
      defs: _defs,
      usesBlend: _usesBlend,
      chars: chars,
    );
  }

  List<InkNode> _nodes(List<MarkupElement> elements) {
    final out = <InkNode>[];
    for (final element in elements) {
      if (_node(element) case final node?) out.add(node);
    }
    return out;
  }

  InkNode? _node(MarkupElement element) {
    final name = element.name;
    if (InkAttributes.definitions.containsKey(name)) {
      _definition(element);
      return null;
    }
    if (name == 'title' || name == 'desc') return null;
    if (!InkAttributes.geometry.containsKey(name)) {
      throw InkMarkupError('unsupported element <$name>');
    }
    final attrs = element.attributes;
    for (final attribute in attrs.keys) {
      if (!InkAttributes.allowsDrawable(name, attribute)) {
        throw InkMarkupError('unsupported attribute $attribute on <$name>');
      }
    }
    final style = _style(attrs);
    final effects = _effects(attrs);
    final node = switch (name) {
      'g' => InkGroupNode(
        style: style,
        effects: effects,
        children: _nodes(element.children),
      ),
      'use' => InkUseNode(
        style: style,
        effects: effects,
        href: _href(attrs),
        offset: Offset(_number(attrs, 'x'), _number(attrs, 'y')),
      ),
      'text' => InkTextNode(
        style: style,
        effects: effects,
        position: Offset(_number(attrs, 'x'), _number(attrs, 'y')),
        text: element.text.toString(),
      ),
      'image' => InkImageNode(
        style: style,
        effects: effects,
        href: _href(attrs),
        rect: Rect.fromLTWH(
          _number(attrs, 'x'),
          _number(attrs, 'y'),
          _number(attrs, 'width'),
          _number(attrs, 'height'),
        ),
      ),
      _ => InkShapeNode(
        style: style,
        effects: effects,
        path: _shapePath(name, attrs),
        pathLength: _optionalNumber(attrs, 'pathLength'),
      ),
    };
    if (name != 'g' && element.children.isNotEmpty) {
      throw InkMarkupError('unexpected children in <$name>');
    }
    if (attrs['id'] case final id?) _elements[id] = node;
    return node;
  }

  void _definition(MarkupElement element) {
    final attrs = element.attributes;
    final allowed = InkAttributes.definitions[element.name] ?? const {};
    for (final attribute in attrs.keys) {
      if (!allowed.contains(attribute)) {
        throw InkMarkupError(
          'unsupported attribute $attribute on <${element.name}>',
        );
      }
    }
    final id = attrs['id'];
    switch (element.name) {
      case 'defs':
        _nodes(element.children);
      case 'clipPath':
        if (attrs['clipPathUnits'] case final units?
            when units != 'userSpaceOnUse') {
          throw InkMarkupError('unsupported clipPathUnits "$units"');
        }
        _define(
          id,
          InkClipPathDef(
            _nodes(element.children),
            transform: _transform(attrs['transform']),
          ),
        );
      case 'mask':
        _define(id, _mask(element));
      case 'pattern':
        _define(id, _pattern(element));
      case 'linearGradient' || 'radialGradient':
        _define(id, _gradient(element));
      case 'stop':
        throw InkMarkupError('<stop> outside a gradient');
    }
  }

  void _define(String? id, InkDef def) {
    if (id == null) throw InkMarkupError('definition without an id');
    _defs[id] = def;
  }

  InkMaskDef _mask(MarkupElement element) {
    final attrs = element.attributes;
    if (attrs['maskContentUnits'] case final units?
        when units != 'userSpaceOnUse') {
      throw InkMarkupError('unsupported maskContentUnits "$units"');
    }
    final children = _nodes(element.children);
    if (attrs['maskUnits'] == 'userSpaceOnUse') {
      return InkMaskDef(
        children,
        region: Rect.fromLTWH(
          _number(attrs, 'x'),
          _number(attrs, 'y'),
          _number(attrs, 'width'),
          _number(attrs, 'height'),
        ),
      );
    }
    return InkMaskDef(
      children,
      boundingBoxRegion: Rect.fromLTWH(
        _number(attrs, 'x', -0.1),
        _number(attrs, 'y', -0.1),
        _number(attrs, 'width', 1.2),
        _number(attrs, 'height', 1.2),
      ),
    );
  }

  InkPatternDef _pattern(MarkupElement element) {
    final attrs = element.attributes;
    if (attrs['patternUnits'] != 'userSpaceOnUse') {
      throw InkMarkupError('patterns must use patternUnits="userSpaceOnUse"');
    }
    return InkPatternDef(
      Rect.fromLTWH(
        _number(attrs, 'x'),
        _number(attrs, 'y'),
        _number(attrs, 'width'),
        _number(attrs, 'height'),
      ),
      _nodes(element.children),
      transform: _transform(attrs['patternTransform']),
    );
  }

  InkGradientDef _gradient(MarkupElement element) {
    final attrs = element.attributes;
    final radial = element.name == 'radialGradient';
    final stops = <InkStop>[];
    for (final child in element.children) {
      if (child.name != 'stop') {
        throw InkMarkupError('unsupported <${child.name}> in a gradient');
      }
      stops.add(_stop(child));
    }
    final userSpace = attrs['gradientUnits'] == 'userSpaceOnUse';
    if (radial) {
      final center = Offset(
        _fraction(attrs, 'cx', 0.5),
        _fraction(attrs, 'cy', 0.5),
      );
      return InkGradientDef(
        radial: true,
        stops: stops,
        userSpace: userSpace,
        from: center,
        to: center,
        radius: _fraction(attrs, 'r', 0.5),
        transform: _transform(attrs['gradientTransform']),
      );
    }
    return InkGradientDef(
      radial: false,
      stops: stops,
      userSpace: userSpace,
      from: Offset(_fraction(attrs, 'x1', 0), _fraction(attrs, 'y1', 0)),
      to: Offset(_fraction(attrs, 'x2', 1), _fraction(attrs, 'y2', 0)),
      radius: 0,
      transform: _transform(attrs['gradientTransform']),
    );
  }

  InkStop _stop(MarkupElement element) {
    final attrs = element.attributes;
    for (final attribute in attrs.keys) {
      if (!(InkAttributes.definitions['stop'] ?? const {}).contains(
        attribute,
      )) {
        throw InkMarkupError('unsupported attribute $attribute on <stop>');
      }
    }
    if (attrs.containsKey('style')) {
      throw InkMarkupError('style on <stop> is not supported');
    }
    return InkStop(
      _fraction(attrs, 'offset', 0).clamp(0, 1),
      InkPaint.parse(attrs['stop-color'] ?? 'black'),
      InkScalar.parse(attrs['stop-opacity'] ?? '1'),
    );
  }

  InkStyle _style(Map<String, String> attrs) {
    if (!attrs.keys.any(InkAttributes.presentation.contains)) {
      return InkStyle.empty;
    }
    return InkStyle(
      fill: _paint(attrs['fill']),
      fillOpacity: _scalar(attrs['fill-opacity']),
      fillRule: _fillType(attrs['fill-rule']),
      stroke: _paint(attrs['stroke']),
      strokeWidth: _optionalNumber(attrs, 'stroke-width'),
      strokeOpacity: _scalar(attrs['stroke-opacity']),
      strokeCap: switch (attrs['stroke-linecap']) {
        null => null,
        'butt' => StrokeCap.butt,
        'round' => StrokeCap.round,
        'square' => StrokeCap.square,
        final other => throw InkMarkupError('bad stroke-linecap "$other"'),
      },
      strokeJoin: switch (attrs['stroke-linejoin']) {
        null => null,
        'miter' => StrokeJoin.miter,
        'round' => StrokeJoin.round,
        'bevel' => StrokeJoin.bevel,
        final other => throw InkMarkupError('bad stroke-linejoin "$other"'),
      },
      strokeMiterLimit: _optionalNumber(attrs, 'stroke-miterlimit'),
      dashArray: _dashArray(attrs['stroke-dasharray']),
      dashOffset: _optionalNumber(attrs, 'stroke-dashoffset'),
      clipRule: _fillType(attrs['clip-rule']),
      fontFamily: attrs['font-family'],
      fontSize: _optionalNumber(attrs, 'font-size'),
      fontWeight: switch (attrs['font-weight']) {
        null => null,
        'bold' || '700' || '800' || '900' => FontWeight.w700,
        'normal' || '400' || '300' || '500' => FontWeight.w400,
        '600' => FontWeight.w600,
        final other => throw InkMarkupError('bad font-weight "$other"'),
      },
      textAnchor: switch (attrs['text-anchor']) {
        null => null,
        final anchor when const {'start', 'middle', 'end'}.contains(anchor) =>
          anchor,
        final other => throw InkMarkupError('bad text-anchor "$other"'),
      },
    );
  }

  InkEffects _effects(Map<String, String> attrs) {
    if (!attrs.keys.any(_isEffect)) return InkEffects.none;
    var blend = InkBlend.none;
    var blendMode = BlendMode.srcOver;
    var mx = 0.0;
    var my = 0.0;
    for (final declaration in (attrs['style'] ?? '').split(';')) {
      if (declaration.trim().isEmpty) continue;
      final colon = declaration.indexOf(':');
      if (colon < 0) throw InkMarkupError('bad style "$declaration"');
      final property = declaration.substring(0, colon).trim();
      final value = declaration.substring(colon + 1).trim();
      switch (property) {
        case 'mix-blend-mode' when value == 'var(--ll-blend)':
          blend = InkBlend.theme;
          _usesBlend = true;
        case 'mix-blend-mode':
          blend = InkBlend.literal;
          blendMode = _blendMode(value);
          _usesBlend = true;
        case '--mx':
          mx = _parseNumber(value);
        case '--my':
          my = _parseNumber(value);
        case 'isolation':
          break;
        default:
          if (!property.startsWith('--')) {
            throw InkMarkupError('unsupported style property "$property"');
          }
      }
    }
    return InkEffects(
      transform: _transform(attrs['transform']),
      opacity: _scalar(attrs['opacity']),
      clipPathId: switch (attrs['clip-path']) {
        null => null,
        final value => InkPaint.urlId(value),
      },
      maskId: switch (attrs['mask']) {
        null => null,
        final value => InkPaint.urlId(value),
      },
      blend: blend,
      blendMode: blendMode,
      part: attrs['data-part'],
      misregister: Offset(mx, my),
      hideOn: switch (attrs['data-hide-on']) {
        null => const {},
        final value => value.split(RegExp(r'\s+')).toSet(),
      },
    );
  }

  static bool _isEffect(String attribute) =>
      attribute != 'id' && InkAttributes.effects.contains(attribute);

  static BlendMode _blendMode(String value) => switch (value) {
    'normal' => BlendMode.srcOver,
    'multiply' => BlendMode.multiply,
    'screen' => BlendMode.screen,
    'overlay' => BlendMode.overlay,
    'darken' => BlendMode.darken,
    'lighten' => BlendMode.lighten,
    'color-burn' => BlendMode.colorBurn,
    'color-dodge' => BlendMode.colorDodge,
    _ => throw InkMarkupError('unsupported blend mode "$value"'),
  };

  static InkAffine? _transform(String? source) => switch (source) {
    null => null,
    final text => TransformParser.parse(text),
  };

  static InkPaint? _paint(String? source) => switch (source) {
    null => null,
    final text => InkPaint.parse(text),
  };

  static InkScalar? _scalar(String? source) => switch (source) {
    null => null,
    final text => InkScalar.parse(text),
  };

  static PathFillType? _fillType(String? source) => switch (source) {
    null => null,
    'nonzero' => PathFillType.nonZero,
    'evenodd' => PathFillType.evenOdd,
    final other => throw InkMarkupError('bad fill rule "$other"'),
  };

  static List<double>? _dashArray(String? source) {
    if (source == null) return null;
    if (source.trim() == 'none') return const [];
    final scan = NumberScanner(source);
    final out = <double>[];
    while (!scan.done) {
      out.add(scan.number());
    }
    if (out.length.isOdd) return [...out, ...out];
    return out;
  }

  static String _href(Map<String, String> attrs) {
    final href = attrs['href'] ?? attrs['xlink:href'];
    if (href == null) throw InkMarkupError('missing href');
    if (href.startsWith('#')) return href.substring(1);
    if (href.startsWith('data:')) return href;
    throw InkMarkupError('unsupported href "$href"');
  }

  static double _parseNumber(String text) {
    final scan = NumberScanner(text);
    final value = scan.number();
    if (!scan.done) throw InkMarkupError('bad number "$text"');
    return value;
  }

  static double _number(
    Map<String, String> attrs,
    String name, [
    double fallback = 0,
  ]) => _optionalNumber(attrs, name) ?? fallback;

  static double? _optionalNumber(Map<String, String> attrs, String name) {
    final text = attrs[name];
    if (text == null) return null;
    if (text.endsWith('px')) {
      return _parseNumber(text.substring(0, text.length - 2));
    }
    return _parseNumber(text);
  }

  static double _fraction(
    Map<String, String> attrs,
    String name,
    double fallback,
  ) {
    final text = attrs[name];
    if (text == null) return fallback;
    if (text.endsWith('%')) {
      return _parseNumber(text.substring(0, text.length - 1)) / 100;
    }
    return _parseNumber(text);
  }

  static Path _shapePath(String name, Map<String, String> attrs) {
    switch (name) {
      case 'path':
        return PathDataParser.parse(attrs['d'] ?? '');
      case 'rect':
        final rect = Rect.fromLTWH(
          _number(attrs, 'x'),
          _number(attrs, 'y'),
          _number(attrs, 'width'),
          _number(attrs, 'height'),
        );
        final rx = _optionalNumber(attrs, 'rx');
        final ry = _optionalNumber(attrs, 'ry') ?? rx;
        if (ry == null) return Path()..addRect(rect);
        return Path()..addRRect(
          RRect.fromRectXY(
            rect,
            (rx ?? ry).clamp(0, rect.width / 2),
            ry.clamp(0, rect.height / 2),
          ),
        );
      case 'circle':
        return Path()..addOval(
          Rect.fromCircle(
            center: Offset(_number(attrs, 'cx'), _number(attrs, 'cy')),
            radius: _number(attrs, 'r'),
          ),
        );
      case 'ellipse':
        return Path()..addOval(
          Rect.fromCenter(
            center: Offset(_number(attrs, 'cx'), _number(attrs, 'cy')),
            width: 2 * _number(attrs, 'rx'),
            height: 2 * _number(attrs, 'ry'),
          ),
        );
      case 'line':
        return Path()
          ..moveTo(_number(attrs, 'x1'), _number(attrs, 'y1'))
          ..lineTo(_number(attrs, 'x2'), _number(attrs, 'y2'));
      case 'polyline' || 'polygon':
        final scan = NumberScanner(attrs['points'] ?? '');
        final points = <Offset>[];
        while (!scan.done) {
          final x = scan.number();
          points.add(Offset(x, scan.number()));
        }
        return Path()..addPolygon(points, name == 'polygon');
    }
    throw InkMarkupError('unsupported element <$name>');
  }
}
