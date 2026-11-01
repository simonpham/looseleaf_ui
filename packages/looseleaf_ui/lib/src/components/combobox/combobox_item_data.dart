/// One choice of a [Combobox]: its [value], the [label] shown and searched,
/// extra search [keywords], and whether it is [disabled].
///
/// Mirrors `ComboboxItemData` in upstream `src/components/ui/combobox.tsx`;
/// [ComboboxItemData.of] is its plain-string form.
class ComboboxItemData {
  const ComboboxItemData({
    required this.value,
    String? label,
    this.keywords = const [],
    this.disabled = false,
  }) : _label = label;

  /// An item whose label is its value.
  const ComboboxItemData.of(this.value)
    : _label = null,
      keywords = const [],
      disabled = false;

  final String value;
  final String? _label;

  /// More words the filter matches.
  final List<String> keywords;

  final bool disabled;

  /// The text shown and searched; [value] when no label is given.
  String get label => _label ?? value;
}
