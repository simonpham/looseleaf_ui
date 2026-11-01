import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';

/// [sidebarMarkRecipe] for one row, optionally without its margin
/// bracket: collapsed to icons upstream hides
/// `[data-part=bracket]` with CSS, here the part is cut from the markup.
class SidebarMarkSource extends InkSource {
  SidebarMarkSource({
    required bool active,
    required bool outline,
    required this.bracket,
  }) : _recipe = RecipeInkSource(
         sidebarMarkRecipe,
         SidebarMarkParams(active: active, outline: outline),
         json: SidebarMarkParams(active: active, outline: outline).toJson(),
       );

  final RecipeInkSource<SidebarMarkParams> _recipe;

  /// Whether the active row's bracket is drawn.
  final bool bracket;

  static final RegExp _open = RegExp(r'<g\b[^>]*data-part="bracket"[^>]*>');
  static final RegExp _tag = RegExp(r'<(/?)g\b[^>]*?(/?)>');

  @override
  String get id => _recipe.id;

  @override
  String get paramsKey => switch (bracket) {
    true => _recipe.paramsKey,
    false => '${_recipe.paramsKey}|no-bracket',
  };

  @override
  Set<String> get lazyLayers => _recipe.lazyLayers;

  @override
  InkMarkup draw(InkFrameRequest request) {
    final markup = _recipe.draw(request);
    if (bracket) return markup;
    return InkMarkup(
      parts: {
        for (final MapEntry(:key, :value) in markup.parts.entries)
          key: withoutBracket(value),
      },
      pad: markup.pad,
    );
  }

  /// [markup] with every `bracket` part group removed.
  static String withoutBracket(String markup) {
    var text = markup;
    for (
      var start = _open.firstMatch(text);
      start != null;
      start = _open.firstMatch(text)
    ) {
      var depth = 0;
      var end = text.length;
      for (final tag in _tag.allMatches(text, start.start)) {
        final closing = tag.group(1) == '/';
        final selfClosing = tag.group(2) == '/';
        if (selfClosing) continue;
        depth += switch (closing) {
          true => -1,
          false => 1,
        };
        if (depth > 0) continue;
        end = tag.end;
        break;
      }
      text = text.replaceRange(start.start, end, '');
    }
    return text;
  }

  @override
  bool operator ==(Object other) =>
      other is SidebarMarkSource &&
      other._recipe == _recipe &&
      other.bracket == bracket;

  @override
  int get hashCode => Object.hash(_recipe, bracket);
}
