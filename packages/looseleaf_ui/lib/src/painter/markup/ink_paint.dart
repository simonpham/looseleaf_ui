import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';

/// A `fill`, `stroke` or `stop-color` value, kept unresolved so the same
/// parsed markup paints under any theme.
sealed class InkPaint {
  const InkPaint();

  /// Parses `none`, `currentColor`, `var(--ll-name[, fallback])`,
  /// `url(#id)`, `#rgb`, `#rrggbb`, `rgb()`/`rgba()`, and a few color names.
  static InkPaint parse(String source) {
    final value = source.trim();
    if (value == 'none' || value == 'transparent') return const InkNoPaint();
    if (value == 'currentColor') return const InkCurrentColor();
    if (value.startsWith('var(')) return _parseVar(value);
    if (value.startsWith('url(')) return InkUrlPaint(_urlId(value));
    return InkColorPaint(parseColor(value));
  }

  static InkTokenPaint _parseVar(String value) {
    final match = RegExp(
      r'^var\(\s*--ll-([a-z0-9-]+)\s*(?:,\s*(.+))?\)$',
    ).firstMatch(value);
    if (match == null) throw InkMarkupError('unsupported paint "$value"');
    final fallback = match[2];
    return InkTokenPaint(match[1] ?? '', switch (fallback) {
      null => null,
      final text => parse(text),
    });
  }

  /// The id inside `url(#id)`.
  static String urlId(String value) => _urlId(value.trim());

  static String _urlId(String value) {
    final match = RegExp(
      r'''^url\(\s*['"]?#([^'")]+)['"]?\s*\)$''',
    ).firstMatch(value);
    if (match == null) throw InkMarkupError('unsupported url "$value"');
    return match[1] ?? '';
  }

  /// Parses a literal CSS color.
  static Color parseColor(String value) {
    final named = switch (value) {
      'white' => const Color(0xFFFFFFFF),
      'black' => const Color(0xFF000000),
      _ => null,
    };
    if (named != null) return named;
    if (value.startsWith('#')) return _hex(value.substring(1));
    final rgb = RegExp(
      r'^rgba?\(\s*([\d.]+)[\s,]+([\d.]+)[\s,]+([\d.]+)\s*(?:[,/]\s*([\d.]+%?))?\s*\)$',
    ).firstMatch(value);
    if (rgb == null) throw InkMarkupError('unsupported color "$value"');
    final alphaText = rgb[4] ?? '1';
    final alpha = switch (alphaText.endsWith('%')) {
      true => double.parse(alphaText.substring(0, alphaText.length - 1)) / 100,
      false => double.parse(alphaText),
    };
    return Color.from(
      alpha: alpha,
      red: double.parse(rgb[1] ?? '0') / 255,
      green: double.parse(rgb[2] ?? '0') / 255,
      blue: double.parse(rgb[3] ?? '0') / 255,
    );
  }

  static Color _hex(String digits) {
    final full = switch (digits.length) {
      3 || 4 => digits.split('').map((digit) => '$digit$digit').join(),
      6 || 8 => digits,
      _ => throw InkMarkupError('bad color "#$digits"'),
    };
    final rgb = int.parse(full.substring(0, 6), radix: 16);
    final alpha = switch (full.length) {
      8 => int.parse(full.substring(6), radix: 16),
      _ => 0xFF,
    };
    return Color((alpha << 24) | rgb);
  }
}

/// `none`: nothing is painted.
class InkNoPaint extends InkPaint {
  const InkNoPaint();
}

/// `currentColor`: the surface's current color.
class InkCurrentColor extends InkPaint {
  const InkCurrentColor();
}

/// A literal color.
class InkColorPaint extends InkPaint {
  const InkColorPaint(this.color);

  final Color color;
}

/// `var(--ll-<token>)`, resolved against the theme when painting.
class InkTokenPaint extends InkPaint {
  const InkTokenPaint(this.token, this.fallback);

  final String token;
  final InkPaint? fallback;
}

/// `url(#id)`: a gradient or pattern defined in the markup.
class InkUrlPaint extends InkPaint {
  const InkUrlPaint(this.id);

  final String id;
}
