import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';
import 'package:looseleaf_ui/src/painter/markup/markup_element.dart';

/// Reads the well-formed SVG fragments the ink engine emits into
/// [MarkupElement]s. It knows elements, quoted attributes, text, comments and
/// the five XML entities; nothing else of XML.
class MarkupReader {
  MarkupReader(this._source);

  final String _source;
  int _at = 0;

  /// The top-level elements of the fragment.
  List<MarkupElement> read() {
    final root = MarkupElement('#root', const {});
    final stack = [root];
    while (_at < _source.length) {
      final open = _source.indexOf('<', _at);
      if (open < 0) {
        stack.last.text.write(decodeEntities(_source.substring(_at)));
        break;
      }
      if (open > _at) {
        stack.last.text.write(decodeEntities(_source.substring(_at, open)));
      }
      _at = open;
      if (_source.startsWith('<!--', _at)) {
        _at = _expect('-->', _at) + 3;
        continue;
      }
      if (_source.startsWith('</', _at)) {
        final close = _expect('>', _at);
        final name = _source.substring(_at + 2, close).trim();
        if (stack.length < 2 || stack.last.name != name) {
          throw InkMarkupError('unexpected </$name> at $_at');
        }
        stack.removeLast();
        _at = close + 1;
        continue;
      }
      final (element, selfClosing) = _readTag();
      stack.last.children.add(element);
      if (selfClosing) continue;
      stack.add(element);
    }
    if (stack.length > 1) throw InkMarkupError('unclosed <${stack.last.name}>');
    return root.children;
  }

  int _expect(String token, int from) {
    final found = _source.indexOf(token, from);
    if (found < 0) throw InkMarkupError('missing "$token" after $from');
    return found;
  }

  (MarkupElement, bool) _readTag() {
    _at++;
    final nameStart = _at;
    while (_at < _source.length && !_isNameEnd(_source.codeUnitAt(_at))) {
      _at++;
    }
    final element = MarkupElement(_source.substring(nameStart, _at), {});
    while (true) {
      _skipSpace();
      if (_at >= _source.length) throw InkMarkupError('unclosed tag');
      if (_source.startsWith('/>', _at)) {
        _at += 2;
        return (element, true);
      }
      if (_source.codeUnitAt(_at) == 0x3E) {
        _at++;
        return (element, false);
      }
      final (name, value) = _readAttribute();
      element.attributes[name] = value;
    }
  }

  (String, String) _readAttribute() {
    final start = _at;
    while (_at < _source.length && !_isNameEnd(_source.codeUnitAt(_at))) {
      _at++;
    }
    final name = _source.substring(start, _at);
    _skipSpace();
    if (_at >= _source.length || _source.codeUnitAt(_at) != 0x3D) {
      throw InkMarkupError('attribute "$name" has no value');
    }
    _at++;
    _skipSpace();
    final quote = _source[_at];
    if (quote != '"' && quote != "'") {
      throw InkMarkupError('attribute "$name" is not quoted');
    }
    final end = _expect(quote, _at + 1);
    final value = decodeEntities(_source.substring(_at + 1, end));
    _at = end + 1;
    return (name, value);
  }

  void _skipSpace() {
    while (_at < _source.length && _isSpace(_source.codeUnitAt(_at))) {
      _at++;
    }
  }

  static bool _isSpace(int unit) =>
      unit == 0x20 || unit == 0x0A || unit == 0x09 || unit == 0x0D;

  static bool _isNameEnd(int unit) =>
      _isSpace(unit) || unit == 0x3D || unit == 0x3E || unit == 0x2F;

  /// Decodes `&amp;`, `&lt;`, `&gt;`, `&quot;`, `&#39;` and numeric references.
  static String decodeEntities(String text) {
    if (!text.contains('&')) return text;
    return text.replaceAllMapped(RegExp('&(#x?[0-9a-fA-F]+|[a-z]+);'), (match) {
      final entity = match[1] ?? '';
      if (entity.startsWith('#x')) {
        return String.fromCharCode(int.parse(entity.substring(2), radix: 16));
      }
      if (entity.startsWith('#')) {
        return String.fromCharCode(int.parse(entity.substring(1)));
      }
      return switch (entity) {
        'amp' => '&',
        'lt' => '<',
        'gt' => '>',
        'quot' => '"',
        'apos' => "'",
        _ => throw InkMarkupError('unknown entity &$entity;'),
      };
    });
  }
}
