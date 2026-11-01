/// The attributes the painter understands, per element. Anything else is an
/// [InkMarkupError], so new engine output cannot be silently misdrawn.
abstract final class InkAttributes {
  static const Set<String> presentation = {
    'fill',
    'fill-opacity',
    'fill-rule',
    'stroke',
    'stroke-width',
    'stroke-opacity',
    'stroke-linecap',
    'stroke-linejoin',
    'stroke-miterlimit',
    'stroke-dasharray',
    'stroke-dashoffset',
    'clip-rule',
    'font-family',
    'font-size',
    'font-weight',
    'text-anchor',
  };

  static const Set<String> effects = {
    'id',
    'transform',
    'opacity',
    'clip-path',
    'mask',
    'style',
    'isolation',
    'data-part',
    'data-hide-on',
    'data-layer',
    'data-stroke',
  };

  static const Map<String, Set<String>> geometry = {
    'g': {},
    'path': {'d', 'pathLength'},
    'rect': {'x', 'y', 'width', 'height', 'rx', 'ry'},
    'circle': {'cx', 'cy', 'r'},
    'ellipse': {'cx', 'cy', 'rx', 'ry'},
    'line': {'x1', 'y1', 'x2', 'y2'},
    'polyline': {'points'},
    'polygon': {'points'},
    'use': {'href', 'xlink:href', 'x', 'y'},
    'text': {'x', 'y'},
    'image': {
      'href',
      'xlink:href',
      'x',
      'y',
      'width',
      'height',
      'preserveAspectRatio',
    },
  };

  static const Map<String, Set<String>> definitions = {
    'defs': {'id'},
    'clipPath': {'id', 'clipPathUnits', 'transform'},
    'mask': {
      'id',
      'maskUnits',
      'maskContentUnits',
      'x',
      'y',
      'width',
      'height',
    },
    'pattern': {
      'id',
      'x',
      'y',
      'width',
      'height',
      'patternUnits',
      'patternTransform',
    },
    'linearGradient': {
      'id',
      'x1',
      'y1',
      'x2',
      'y2',
      'gradientUnits',
      'gradientTransform',
    },
    'radialGradient': {
      'id',
      'cx',
      'cy',
      'r',
      'fx',
      'fy',
      'gradientUnits',
      'gradientTransform',
    },
    'stop': {'offset', 'stop-color', 'stop-opacity', 'style'},
  };

  /// Whether [attribute] is allowed on a drawable [element].
  static bool allowsDrawable(String element, String attribute) =>
      presentation.contains(attribute) ||
      effects.contains(attribute) ||
      (geometry[element]?.contains(attribute) ?? false);
}
