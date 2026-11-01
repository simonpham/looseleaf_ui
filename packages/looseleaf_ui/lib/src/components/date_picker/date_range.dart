/// A span of days picked by a [DateRangePicker]: [from], and [to] once
/// the second day is chosen.
///
/// Mirrors react-day-picker's `DateRange`, which upstream
/// `src/components/ui/date-picker.tsx` uses.
class DateRange {
  const DateRange({required this.from, this.to});

  final DateTime from;
  final DateTime? to;

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'DateRange($from, $to)';
}
