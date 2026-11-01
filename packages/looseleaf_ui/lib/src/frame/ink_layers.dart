/// Ink state layer names and their paint order, from `INK_LAYER_ORDER` in
/// upstream `src/lib/ink/recipes/index.ts`.
abstract final class InkLayers {
  static const String rest = 'rest';
  static const String disabled = 'disabled';
  static const String invalid = 'invalid';
  static const String checked = 'checked';
  static const String indeterminate = 'indeterminate';
  static const String open = 'open';
  static const String busy = 'busy';
  static const String hover = 'hover';
  static const String pressed = 'pressed';
  static const String focus = 'focus';

  static const List<String> order = [
    rest,
    disabled,
    invalid,
    checked,
    indeterminate,
    open,
    busy,
    hover,
    pressed,
    focus,
  ];

  /// [names] sorted into paint order; unknown names go last.
  static List<String> sorted(Iterable<String> names) {
    int rank(String name) {
      final index = order.indexOf(name);
      if (index < 0) return order.length;
      return index;
    }

    return [...names]..sort((a, b) => rank(a).compareTo(rank(b)));
  }
}
