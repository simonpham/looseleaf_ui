/// A widget state that shows an ink layer, mirroring the attribute rules of
/// `src/styles/looseleaf.css` (`:hover`, `:active`, `:focus-visible`,
/// `:disabled`, `aria-invalid`, `data-state=checked`, …).
enum InkState {
  hovered('hover'),
  pressed('pressed'),
  focused('focus'),
  disabled('disabled'),
  invalid('invalid'),
  checked('checked'),
  indeterminate('indeterminate'),
  open('open'),
  busy('busy');

  const InkState(this.layer);

  /// The layer this state shows, and its `data-hide-on` token.
  final String layer;

  /// The state that shows [layer], or null for `rest` and unknown layers.
  static InkState? ofLayer(String layer) {
    for (final state in values) {
      if (state.layer == layer) return state;
    }
    return null;
  }
}
