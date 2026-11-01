import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_format.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_presets.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_shell.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_preset.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_range.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Builds the two-month grid in a [DateRangePicker]'s popup.
typedef DateRangeCalendarBuilder = Widget Function(
  BuildContext context,
  DateRange? selected,
  ValueChanged<DateRange?> onSelect,
  bool Function(DateTime day) isDisabled,
);

final RegExp _rangeSeparator = RegExp(r'\s+(?:–|—|-|to)\s+|\s*[–—]\s*');

/// A span of days you type ("Sep 1, 2026 – Sep 9, 2026", "9/1/26 to
/// 9/9/26") or pick on a two-month calendar under the field.
///
/// Mirrors `DateRangePicker` in upstream
/// `src/components/ui/date-picker.tsx`. The calendar comes through
/// [calendarBuilder] until the Calendar component is ported.
class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.calendarBuilder,
    this.format = formatDateMedium,
    this.placeholder = 'Pick a date range',
    this.presets = const [],
    this.closeOnSelect = true,
    this.min,
    this.max,
    this.isDateDisabled,
    this.typeable = true,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.open,
    this.onOpenChange,
    this.calendarLabel = 'Choose dates',
    this.invalidMessage = 'Enter a date we can read.',
    this.now,
    this.seed,
    this.semanticLabel,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The chosen span, or null.
  final DateRange? value;

  final ValueChanged<DateRange?>? onChanged;

  /// The calendar in the popup.
  final DateRangeCalendarBuilder? calendarBuilder;

  /// The text for each end; date-fns `PP` by default.
  final DatePickerFormat format;

  final String placeholder;

  /// Shortcuts beside the calendar.
  final List<DatePreset<DateRange>> presets;

  /// Closes the popup once both ends are chosen.
  final bool closeOnSelect;

  final DateTime? min;
  final DateTime? max;
  final bool Function(DateTime day)? isDateDisabled;
  final bool typeable;
  final bool disabled;
  final bool readOnly;
  final bool invalid;
  final bool? open;
  final ValueChanged<bool>? onOpenChange;
  final String calendarLabel;
  final String invalidMessage;

  /// What "today" means when reading typed words; the clock when null.
  final DateTime Function()? now;

  final String? seed;
  final String? semanticLabel;
  final bool autofocus;
  final Set<InkState> forcedStates;

  /// Whether [day] falls outside [min]..[max] or [isDateDisabled].
  bool isDisabled(DateTime day) {
    final first = min;
    final last = max;
    if (first != null &&
        day.isBefore(DateTime(first.year, first.month, first.day))) {
      return true;
    }
    if (last != null &&
        day.isAfter(DateTime(last.year, last.month, last.day))) {
      return true;
    }
    return isDateDisabled?.call(day) ?? false;
  }

  String get _text {
    final range = value;
    if (range == null) return '';
    return switch (range.to) {
      final to? => '${format(range.from)} – ${format(to)}',
      null => '${format(range.from)} –',
    };
  }

  bool _commit(String typed) {
    if (typed.trim().isEmpty) {
      onChanged?.call(null);
      return true;
    }
    final reference = (now ?? DateTime.now).call();
    final parts = [
      for (final part in typed.trim().split(_rangeSeparator))
        if (part.trim().isNotEmpty) part,
    ];
    if (parts.isEmpty || parts.length > 2) return false;
    final days = [
      for (final part in parts) parseDateInput(part, reference: reference),
    ];
    final a = days.first;
    final b = days.elementAtOrNull(1);
    if (a == null || (parts.length == 2 && b == null)) return false;
    final from = switch (b != null && b.isBefore(a)) {
      true => b ?? a,
      false => a,
    };
    final to = switch (b) {
      final end? when end.isBefore(a) => a,
      final end? => end,
      null => null,
    };
    if (isDisabled(from) || (to != null && isDisabled(to))) return false;
    onChanged?.call(DateRange(from: from, to: to));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final builder = calendarBuilder;
    return DatePickerShell(
      text: _text,
      onCommit: _commit,
      placeholder: placeholder,
      typeable: typeable,
      disabled: disabled,
      readOnly: readOnly,
      invalid: invalid,
      open: open,
      onOpenChange: onOpenChange,
      calendarLabel: calendarLabel,
      invalidMessage: invalidMessage,
      seed: seed,
      semanticLabel: semanticLabel,
      autofocus: autofocus,
      forcedStates: forcedStates,
      presets: switch (presets.isEmpty) {
        true => null,
        false => (context, close) => DatePickerPresets<DateRange>(
          presets: presets,
          onPick: (preset) {
            final next = preset.value();
            onChanged?.call(next);
            if (closeOnSelect && next.to != null) close();
          },
        ),
      },
      calendar: (context, close) => switch (builder) {
        final build? => build(context, value, (range) {
          onChanged?.call(range);
          final to = range?.to;
          if (closeOnSelect &&
              range != null &&
              to != null &&
              !isSameDay(range.from, to)) {
            close();
          }
        }, isDisabled),
        null => const SizedBox.shrink(),
      },
    );
  }
}
