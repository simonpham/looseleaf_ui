import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// The alert box drawn by [alertRecipe], without the circle behind the icon
/// when the alert has none, like upstream's
/// `[&:not(:has(>svg))]>svg_[data-part=icon-mark]]:hidden`.
class AlertInkSource extends InkSource {
  AlertInkSource({required this.tone, required this.withIcon})
    : _recipe = RecipeInkSource(
        alertRecipe,
        AlertParams(tone: tone),
        json: AlertParams(tone: tone).toJson(),
      );

  /// The alert's tone.
  final AlertTone tone;

  /// Whether the `icon-mark` part is kept.
  final bool withIcon;

  final RecipeInkSource<AlertParams> _recipe;

  @override
  String get id => _recipe.id;

  @override
  String get paramsKey => '${_recipe.paramsKey}|icon:$withIcon';

  @override
  Set<String> get lazyLayers => _recipe.lazyLayers;

  @override
  InkMarkup draw(InkFrameRequest request) {
    final markup = _recipe.draw(request);
    if (withIcon) return markup;
    return InkMarkup(
      parts: {
        for (final MapEntry(key: layer, value: svg) in markup.parts.entries)
          layer: withoutPart(svg, 'icon-mark'),
      },
      pad: markup.pad,
    );
  }

  /// [svg] without the `<g data-part="[part]">` groups.
  static String withoutPart(String svg, String part) {
    final marker = 'data-part="$part"';
    var out = svg;
    while (true) {
      final at = out.indexOf(marker);
      if (at < 0) return out;
      final start = out.lastIndexOf('<g', at);
      final end = _groupEnd(out, start);
      out = out.replaceRange(start, end, '');
    }
  }

  static int _groupEnd(String svg, int start) {
    var depth = 0;
    var at = start;
    while (at < svg.length) {
      final open = svg.indexOf(RegExp(r'<g[\s>]'), at);
      final close = svg.indexOf('</g>', at);
      if (close < 0) return svg.length;
      if (open >= 0 && open < close) {
        depth++;
        at = open + 2;
        continue;
      }
      depth--;
      at = close + 4;
      if (depth == 0) return at;
    }
    return svg.length;
  }

  @override
  bool operator ==(Object other) =>
      other is AlertInkSource &&
      other.tone == tone &&
      other.withIcon == withIcon;

  @override
  int get hashCode => Object.hash(tone, withIcon);
}
