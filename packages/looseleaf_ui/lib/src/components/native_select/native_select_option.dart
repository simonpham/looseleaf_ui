/// An entry of a [NativeSelect]: an option or a group of them.
sealed class NativeSelectEntry<T> {
  const NativeSelectEntry();
}

/// One choice of a [NativeSelect].
///
/// Mirrors `NativeSelectOption` in upstream
/// `src/components/ui/native-select.tsx`.
final class NativeSelectOption<T> extends NativeSelectEntry<T> {
  const NativeSelectOption({
    required this.value,
    required this.label,
    this.disabled = false,
  });

  /// The value the select takes when this is chosen.
  final T value;

  /// The words shown in the list and, once chosen, in the box; typeahead
  /// matches their start.
  final String label;

  /// Shown but not choosable.
  final bool disabled;
}

/// Options under a bold caption in a [NativeSelect]'s list.
///
/// Mirrors `NativeSelectOptGroup` in upstream
/// `src/components/ui/native-select.tsx`.
final class NativeSelectOptGroup<T> extends NativeSelectEntry<T> {
  const NativeSelectOptGroup({
    required this.label,
    required this.options,
    this.disabled = false,
  });

  /// The caption.
  final String label;

  final List<NativeSelectOption<T>> options;

  /// Disables every option in the group.
  final bool disabled;
}

/// The options of [entries] in order, with group-disabled options marked
/// disabled.
List<NativeSelectOption<T>> flattenNativeSelectEntries<T>(
  List<NativeSelectEntry<T>> entries,
) => [
  for (final entry in entries)
    ...switch (entry) {
      NativeSelectOption<T>() => [entry],
      NativeSelectOptGroup<T>(:final options, disabled: false) => options,
      NativeSelectOptGroup<T>(:final options, disabled: true) => [
        for (final option in options)
          NativeSelectOption(
            value: option.value,
            label: option.label,
            disabled: true,
          ),
      ],
    },
];
