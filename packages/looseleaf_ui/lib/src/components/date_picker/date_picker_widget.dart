import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_format.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_presets.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker_shell.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_preset.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// Builds the month grid in a [DatePicker]'s popup: show [selected], call
/// [onSelect] with the day picked (null to clear), honour [isDisabled].
typedef DatePickerCalendarBuilder = Widget Function(
  BuildContext context,
  DateTime? selected,
  ValueChanged<DateTime?> onSelect,
  bool Function(DateTime day) isDisabled,
);

/// A day you type ("Sep 17, 2026", "9/17/26", "tomorrow") or pick from a
/// calendar under the field, with optional [presets] beside it.
///
/// ```dart
/// DatePicker(
///   value: due,
///   onChanged: (day) => setState(() => due = day),
///   min: DateTime.now(),
/// )
/// ```
///
/// Mirrors `DatePicker` in upstream `src/components/ui/date-picker.tsx`.
/// The popup's month grid is a [Calendar] opened on the chosen day; swap
/// it through [calendarBuilder].
class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.calendarBuilder,
    this.format = formatDateMedium,
    this.placeholder = 'Pick a date',
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
    this.calendarLabel = 'Choose date',
    this.invalidMessage = 'Enter a date we can read.',
    this.now,
    this.seed,
    this.semanticLabel,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The chosen day, or null.
  final DateTime? value;

  final ValueChanged<DateTime?>? onChanged;

  /// The calendar in the popup; a single [Calendar] when null.
  final DatePickerCalendarBuilder? calendarBuilder;

  /// The field's text for a day; date-fns `PP` by default.
  final DatePickerFormat format;

  final String placeholder;

  /// Shortcuts beside the calendar.
  final List<DatePreset<DateTime>> presets;

  /// Closes the popup once a day or preset is chosen.
  final bool closeOnSelect;

  /// The first day allowed.
  final DateTime? min;

  /// The last day allowed.
  final DateTime? max;

  /// More days that cannot be chosen.
  final bool Function(DateTime day)? isDateDisabled;

  /// A field to type in; false makes it one button.
  final bool typeable;

  final bool disabled;
  final bool readOnly;
  final bool invalid;

  /// Opens the popup from outside.
  final bool? open;

  final ValueChanged<bool>? onOpenChange;

  /// The calendar button's and the popup's accessible name.
  final String calendarLabel;

  /// Heard while a typed date cannot be read.
  final String invalidMessage;

  /// What "today" means when reading typed words; the clock when null.
  final DateTime Function()? now;

  /// Pins the hand.
  final String? seed;

  /// The field's accessible name.
  final String? semanticLabel;

  final bool autofocus;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// Whether [day] falls outside [min]..[max] or [isDateDisabled].
  bool isDisabled(DateTime day) {
    final first = min;
    final last = max;
    if (first != null && day.isBefore(_dayOf(first))) return true;
    if (last != null && day.isAfter(_dayOf(last))) return true;
    return isDateDisabled?.call(day) ?? false;
  }

  static DateTime _dayOf(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool _commit(String typed) {
    if (typed.trim().isEmpty) {
      onChanged?.call(null);
      return true;
    }
    final day = parseDateInput(
      typed,
      reference: (now ?? DateTime.now).call(),
    );
    if (day == null || isDisabled(day)) return false;
    final current = value;
    if (current == null || !isSameDay(day, current)) onChanged?.call(day);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    final builder = calendarBuilder;
    return DatePickerShell(
      text: switch (current) {
        final day? => format(day),
        null => '',
      },
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
        false => (context, close) => DatePickerPresets<DateTime>(
          presets: presets,
          onPick: (preset) {
            onChanged?.call(preset.value());
            if (closeOnSelect) close();
          },
        ),
      },
      calendar: (context, close) {
        void onSelect(DateTime? day) {
          if (day == null && current != null && typeable) {
            if (closeOnSelect) close();
            return;
          }
          onChanged?.call(day);
          if (closeOnSelect && day != null) close();
        }

        return switch (builder) {
          final build? => build(context, current, onSelect, isDisabled),
          null => Calendar(
            selected: current,
            onSelect: onSelect,
            defaultMonth: current,
            today: now?.call(),
            isDateDisabled: isDisabled,
            autofocus: true,
            seed: switch (seed) {
              final pinned? => '$pinned|calendar',
              null => null,
            },
          ),
        };
      },
    );
  }
}
