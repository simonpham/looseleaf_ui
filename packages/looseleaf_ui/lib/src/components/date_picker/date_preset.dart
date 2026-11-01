/// A shortcut beside the calendar ("Today", "In a week"): [value] is
/// worked out when it is chosen, not when the page was built.
///
/// Mirrors `DatePreset` / `DateRangePreset` in upstream
/// `src/components/ui/date-picker.tsx`.
class DatePreset<T> {
  const DatePreset({required this.label, required this.value});

  final String label;
  final T Function() value;
}
