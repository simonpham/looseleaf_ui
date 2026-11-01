import 'package:looseleaf_ui/src/frame/frame.dart';

/// [source]'s drawing without its `data-part="[part]"` groups, like
/// upstream's `[&>svg_[data-part=seam]]:hidden` on a joined group's first
/// item.
class WithoutPartInkSource extends InkSource {
  const WithoutPartInkSource(this.source, this.part);

  final InkSource source;

  /// The `data-part` name whose groups are left out.
  final String part;

  @override
  String get id => '${source.id}|without-$part';

  @override
  String get paramsKey => source.paramsKey;

  @override
  Set<String> get lazyLayers => source.lazyLayers;

  @override
  InkMarkup draw(InkFrameRequest request) {
    final markup = source.draw(request);
    return InkMarkup(
      parts: {
        for (final MapEntry(:key, :value) in markup.parts.entries)
          key: _strip(value),
      },
      pad: markup.pad,
    );
  }

  String _strip(String svg) {
    final open = RegExp('<g[^>]*\\sdata-part="$part"[^>]*>');
    var text = svg;
    for (var match = open.firstMatch(text); match != null;) {
      text = text.replaceRange(match.start, _close(text, match.end), '<g/>');
      match = open.firstMatch(text);
    }
    return text;
  }

  static int _close(String text, int from) {
    var depth = 1;
    var index = from;
    while (depth > 0) {
      final nextOpen = text.indexOf('<g', index);
      final nextClose = text.indexOf('</g>', index);
      if (nextClose < 0) return text.length;
      if (nextOpen >= 0 && nextOpen < nextClose) {
        final tagEnd = text.indexOf('>', nextOpen);
        final selfClosing = tagEnd > 0 && text[tagEnd - 1] == '/';
        if (!selfClosing) depth++;
        index = tagEnd + 1;
        continue;
      }
      depth--;
      index = nextClose + '</g>'.length;
    }
    return index;
  }

  @override
  bool operator ==(Object other) =>
      other is WithoutPartInkSource &&
      other.source == source &&
      other.part == part;

  @override
  int get hashCode => Object.hash(source, part);
}
