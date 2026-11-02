import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_caption.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_dates.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_day_button.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_formatters.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_mode.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_month_grid.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_move.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_nav.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_selection.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_sheet.dart';
import 'package:looseleaf_ui/src/components/date_picker/date_picker.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the content of [day]'s button in a [Calendar] around its
/// [number], the date in script.
typedef CalendarDayContentBuilder =
    Widget Function(
      BuildContext context,
      DateTime day,
      Widget number,
    );

/// A month on planner paper: the grid ruled by hand, the chosen day
/// circled in marker, today underlined in felt, a range one highlighter
/// swipe per week, a day you may not pick hatched out in pencil.
///
/// Pick one day ([Calendar.new]), several ([Calendar.multiple]) or a span
/// ([Calendar.range]). Show week numbers in a red-ruled margin, month and
/// year dropdowns in the caption, several months side by side; it follows
/// the ambient [Directionality] for right to left.
///
/// One day is the tab stop. Arrow keys move by day and week, Home and End
/// to the week's edges, Page Up / Page Down by month (with Shift, by
/// year); Enter and Space pick.
///
/// ```dart
/// Calendar(
///   selected: day,
///   onSelect: (picked) => setState(() => day = picked),
///   sheet: const CalendarSheet(),
/// )
/// Calendar.range(
///   numberOfMonths: 2,
///   showWeekNumber: true,
///   selected: range,
///   onSelect: (picked) => setState(() => range = picked),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/calendar.tsx`, a react-day-picker
/// `DayPicker` there.
class Calendar extends StatefulWidget {
  /// Picks one day; tapping it again clears it unless [required].
  const Calendar({
    super.key,
    DateTime? selected,
    ValueChanged<DateTime?>? onSelect,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.today,
    this.isDateDisabled,
    this.isDateHidden,
    this.required = false,
    this.numberOfMonths = 1,
    this.showOutsideDays = true,
    this.showWeekNumber = false,
    this.fixedWeeks = false,
    this.weekStartsOn = 0,
    this.captionLayout = CalendarCaptionLayout.label,
    this.startMonth,
    this.endMonth,
    this.buttonVariant = ButtonVariant.ghost,
    this.ruled = true,
    this.sheet,
    this.seed,
    this.footer,
    this.padding,
    this.autofocus = false,
    this.formatters = const CalendarFormatters(),
    this.cellSize,
    this.dayContentBuilder,
  }) : mode = CalendarMode.single,
       selectedDay = selected,
       onSelectDay = onSelect,
       selectedDays = const [],
       onSelectDays = null,
       selectedRange = null,
       onSelectRange = null;

  /// Picks any number of days; each tap toggles one.
  const Calendar.multiple({
    super.key,
    List<DateTime> selected = const [],
    ValueChanged<List<DateTime>>? onSelect,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.today,
    this.isDateDisabled,
    this.isDateHidden,
    this.required = false,
    this.numberOfMonths = 1,
    this.showOutsideDays = true,
    this.showWeekNumber = false,
    this.fixedWeeks = false,
    this.weekStartsOn = 0,
    this.captionLayout = CalendarCaptionLayout.label,
    this.startMonth,
    this.endMonth,
    this.buttonVariant = ButtonVariant.ghost,
    this.ruled = true,
    this.sheet,
    this.seed,
    this.footer,
    this.padding,
    this.autofocus = false,
    this.formatters = const CalendarFormatters(),
    this.cellSize,
    this.dayContentBuilder,
  }) : mode = CalendarMode.multiple,
       selectedDay = null,
       onSelectDay = null,
       selectedDays = selected,
       onSelectDays = onSelect,
       selectedRange = null,
       onSelectRange = null;

  /// Picks a first and a last day.
  const Calendar.range({
    super.key,
    DateRange? selected,
    ValueChanged<DateRange?>? onSelect,
    this.month,
    this.defaultMonth,
    this.onMonthChange,
    this.today,
    this.isDateDisabled,
    this.isDateHidden,
    this.required = false,
    this.numberOfMonths = 1,
    this.showOutsideDays = true,
    this.showWeekNumber = false,
    this.fixedWeeks = false,
    this.weekStartsOn = 0,
    this.captionLayout = CalendarCaptionLayout.label,
    this.startMonth,
    this.endMonth,
    this.buttonVariant = ButtonVariant.ghost,
    this.ruled = true,
    this.sheet,
    this.seed,
    this.footer,
    this.padding,
    this.autofocus = false,
    this.formatters = const CalendarFormatters(),
    this.cellSize,
    this.dayContentBuilder,
  }) : mode = CalendarMode.range,
       selectedDay = null,
       onSelectDay = null,
       selectedDays = const [],
       onSelectDays = null,
       selectedRange = selected,
       onSelectRange = onSelect;

  /// How days are picked; set by the constructor.
  final CalendarMode mode;

  /// The chosen day of a single calendar.
  final DateTime? selectedDay;
  final ValueChanged<DateTime?>? onSelectDay;

  /// The chosen days of a [Calendar.multiple].
  final List<DateTime> selectedDays;
  final ValueChanged<List<DateTime>>? onSelectDays;

  /// The chosen span of a [Calendar.range].
  final DateRange? selectedRange;
  final ValueChanged<DateRange?>? onSelectRange;

  /// The (first) month shown, when the caller drives it.
  final DateTime? month;

  /// The month shown first when [month] is null; today's by default.
  final DateTime? defaultMonth;

  /// Called when the arrows, the dropdowns or the keyboard page.
  final ValueChanged<DateTime>? onMonthChange;

  /// What counts as today; the clock when null.
  final DateTime? today;

  /// Days that cannot be picked: hatched, graphite, skipped by the keys.
  final bool Function(DateTime day)? isDateDisabled;

  /// Days left out of the grid.
  final bool Function(DateTime day)? isDateHidden;

  /// The selection cannot be emptied by tapping it again.
  final bool required;

  /// Months shown side by side (stacked on narrow screens).
  final int numberOfMonths;

  /// Days of the neighbouring months in the first and last week.
  final bool showOutsideDays;

  /// Week numbers in a margin behind a red rule.
  final bool showWeekNumber;

  /// Always six weeks, so the grid keeps its height.
  final bool fixedWeeks;

  /// The first column's weekday: 0 for Sunday, 1 for Monday.
  final int weekStartsOn;

  final CalendarCaptionLayout captionLayout;

  /// The first month that can be shown; with dropdowns, a hundred years
  /// back by default.
  final DateTime? startMonth;

  /// The last month that can be shown; with dropdowns, the end of this
  /// year by default.
  final DateTime? endMonth;

  /// The previous / next buttons' variant.
  final ButtonVariant buttonVariant;

  /// Hand-rules the grid; false leaves the page plain.
  final bool ruled;

  /// A sheet of paper of its own; transparent (on the paper around it)
  /// when null.
  final CalendarSheet? sheet;

  /// Pins the hand: the same seed always rules the same grid.
  final String? seed;

  /// A line under the months, in the hand's muted ink.
  final Widget? footer;

  /// The space round the months: `p-3` (`calm:p-2`) when null.
  final EdgeInsetsGeometry? padding;

  /// Focuses the day holding the tab stop once shown.
  final bool autofocus;

  /// The words and numerals.
  final CalendarFormatters formatters;

  /// A day's side (upstream's `--cell`): 40 by default, 34 compact, 30
  /// calm. Sidebars use `Spacing.d32` like upstream's `[--cell:2rem]`.
  final double? cellSize;

  /// Builds what sits inside a day's button around its [number], for marks
  /// of your own such as event dots under the date; upstream wraps
  /// `CalendarDayButton` in `components.DayButton` for this. The day keeps
  /// its circle, swipe, underline, hatch and keyboard behaviour.
  final CalendarDayContentBuilder? dayContentBuilder;

  /// The months from [startMonth] or its default to [endMonth] or its
  /// default.
  (DateTime?, DateTime?) bounds(DateTime today) {
    final dropdowns = captionLayout != CalendarCaptionLayout.label;
    final start = switch ((startMonth, dropdowns)) {
      (final first?, _) => CalendarDates.month(first),
      (null, true) => DateTime(today.year - 100),
      (null, false) => null,
    };
    final end = switch ((endMonth, dropdowns)) {
      (final last?, _) => CalendarDates.month(last),
      (null, true) => DateTime(today.year, 12),
      (null, false) => null,
    };
    return (start, end);
  }

  /// The side of a day: [cellSize], else [CalendarMetrics.cell] for the
  /// density.
  double cell(LooseleafDensity density) =>
      cellSize ?? CalendarMetrics.cell.resolve(density);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with InkSeed {
  late DateTime _ownMonth = _clamp(
    CalendarDates.month(widget.defaultMonth ?? _today),
  );
  DateTime? _focused;
  final Map<DateTime, FocusNode> _nodes = {};

  DateTime get _today => CalendarDates.day(widget.today ?? DateTime.now());

  DateTime get _month => CalendarDates.month(widget.month ?? _ownMonth);

  int get _count => widget.numberOfMonths.clamp(1, 12);

  List<DateTime> get _months => [
    for (var i = 0; i < _count; i++) CalendarDates.addMonths(_month, i),
  ];

  CalendarSelection get _selection => CalendarSelection(
    mode: widget.mode,
    day: widget.selectedDay,
    days: widget.selectedDays,
    range: widget.selectedRange,
    required: widget.required,
  );

  @override
  void initState() {
    super.initState();
    if (!widget.autofocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _target();
      if (!mounted || target == null) return;
      _node(target).requestFocus();
    });
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  DateTime _clamp(DateTime month) {
    final (start, end) = widget.bounds(_today);
    final last = switch (end) {
      final limit? => CalendarDates.addMonths(limit, 1 - _count),
      null => null,
    };
    if (last != null && month.isAfter(last)) month = last;
    if (start != null && month.isBefore(start)) month = start;
    return month;
  }

  FocusNode _node(DateTime day) => _nodes.putIfAbsent(
    day,
    () => FocusNode(debugLabel: 'Calendar ${day.toIso8601String()}'),
  );

  bool _disabled(DateTime day) => widget.isDateDisabled?.call(day) ?? false;

  bool _shown(DateTime day) => _months.any(
    (month) => month.year == day.year && month.month == day.month,
  );

  /// react-day-picker's `calculateFocusTarget`: the focused day, else a
  /// chosen one, else today, else the first day that can be picked.
  DateTime? _target() {
    bool usable(DateTime day) =>
        _shown(day) &&
        !_disabled(day) &&
        !(widget.isDateHidden?.call(day) ?? false);
    final selection = _selection;
    final candidates = [
      ?_focused,
      ?widget.selectedDay,
      ...widget.selectedDays,
      ?widget.selectedRange?.from,
      ?widget.selectedRange?.to,
      _today,
    ];
    for (final day in candidates) {
      final date = CalendarDates.day(day);
      if (usable(date) && (date == _focused || selection.isSelected(date))) {
        return date;
      }
    }
    if (usable(_today)) return _today;
    for (final month in _months) {
      for (var d = 1; d <= DateTime(month.year, month.month + 1, 0).day; d++) {
        final date = DateTime(month.year, month.month, d);
        if (usable(date)) return date;
      }
    }
    return null;
  }

  void _setMonth(DateTime month) {
    final next = _clamp(CalendarDates.month(month));
    if (next == _month) return;
    if (widget.month == null) setState(() => _ownMonth = next);
    widget.onMonthChange?.call(next);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prune());
  }

  void _prune() {
    if (!mounted) return;
    final stale = [
      for (final MapEntry(key: day, value: node) in _nodes.entries)
        if (!node.hasFocus && !_onGrid(day)) day,
    ];
    for (final day in stale) {
      _nodes.remove(day)?.dispose();
    }
  }

  bool _onGrid(DateTime day) => _months.any(
    (month) => CalendarDates.weeks(
      month,
      weekStartsOn: widget.weekStartsOn,
      fixedWeeks: widget.fixedWeeks,
    ).any((week) => week.contains(day)),
  );

  void _pick(DateTime day) {
    setState(() => _focused = day);
    _node(day).requestFocus();
    final selection = _selection;
    switch (widget.mode) {
      case CalendarMode.single:
        widget.onSelectDay?.call(selection.pickDay(day));
      case CalendarMode.multiple:
        widget.onSelectDays?.call(selection.pickDays(day));
      case CalendarMode.range:
        widget.onSelectRange?.call(selection.pickRange(day));
    }
  }

  void _focusDay(DateTime day) {
    final months = _months;
    final first = months.first;
    final last = months.last;
    if (day.isBefore(first)) _setMonth(CalendarDates.month(day));
    if (day.isAfter(DateTime(last.year, last.month + 1, 0))) {
      _setMonth(CalendarDates.addMonths(CalendarDates.month(day), 1 - _count));
    }
    setState(() => _focused = day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _node(day).requestFocus();
    });
  }

  CalendarMove? _move(KeyEvent event) {
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return switch ((event.logicalKey, rtl, shift)) {
      (LogicalKeyboardKey.arrowLeft, false, _) ||
      (LogicalKeyboardKey.arrowRight, true, _) => CalendarMove.dayBefore,
      (LogicalKeyboardKey.arrowRight, false, _) ||
      (LogicalKeyboardKey.arrowLeft, true, _) => CalendarMove.dayAfter,
      (LogicalKeyboardKey.arrowUp, _, _) => CalendarMove.weekBefore,
      (LogicalKeyboardKey.arrowDown, _, _) => CalendarMove.weekAfter,
      (LogicalKeyboardKey.home, _, _) => CalendarMove.weekStart,
      (LogicalKeyboardKey.end, _, _) => CalendarMove.weekEnd,
      (LogicalKeyboardKey.pageUp, _, false) => CalendarMove.monthBefore,
      (LogicalKeyboardKey.pageDown, _, false) => CalendarMove.monthAfter,
      (LogicalKeyboardKey.pageUp, _, true) => CalendarMove.yearBefore,
      (LogicalKeyboardKey.pageDown, _, true) => CalendarMove.yearAfter,
      _ => null,
    };
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final focused = [
      for (final MapEntry(key: day, value: node) in _nodes.entries)
        if (node.hasPrimaryFocus) day,
    ];
    final move = _move(event);
    if (focused.isEmpty || move == null) return KeyEventResult.ignored;
    final (start, end) = widget.bounds(_today);
    final next = move.land(
      focused.first,
      weekStartsOn: widget.weekStartsOn,
      isDisabled: _disabled,
      start: start,
      end: end,
    );
    if (next != null) _focusDay(next);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final wide = (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= 768;
    final (start, end) = widget.bounds(_today);
    final months = _months;
    final target = _target();
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Flex(
              direction: switch (wide) {
                true => Axis.horizontal,
                false => Axis.vertical,
              },
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CalendarMetrics.monthGap,
              children: [
                for (final (index, month) in months.indexed)
                  _monthColumn(month, index, seed, target, start, end),
              ],
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              top: 0,
              child: CalendarNav(
                seed: seed,
                variant: widget.buttonVariant,
                cellSize: widget.cell(theme.density),
                previousLabel: widget.formatters.previousMonthLabel,
                nextLabel: widget.formatters.nextMonthLabel,
                canPrevious: start == null || months.first.isAfter(start),
                canNext: end == null || months.last.isBefore(end),
                onPrevious: () =>
                    _setMonth(CalendarDates.addMonths(_month, -1)),
                onNext: () => _setMonth(CalendarDates.addMonths(_month, 1)),
              ),
            ),
          ],
        ),
        if (widget.footer case final footer?)
          Padding(
            padding: const EdgeInsets.only(top: CalendarMetrics.footerGap),
            child: DefaultTextStyle(
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: CalendarMetrics.footerSize,
                cssLineHeight: 20 / 14,
                color: theme.colors.inkMuted,
              ),
              child: footer,
            ),
          ),
      ],
    );
    final padding =
        widget.padding ??
        EdgeInsets.all(CalendarMetrics.padding.resolve(theme.density));
    final keyed = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: content,
    );
    final sheet = widget.sheet;
    if (sheet == null) return Padding(padding: padding, child: keyed);
    return Paper(
      stock: sheet.stock,
      edge: sheet.edge,
      tilt: sheet.tilt,
      tiltDegrees: sheet.tiltDegrees,
      rules: RuleName.none,
      tape: sheet.tape,
      tapeKind: sheet.tapeKind,
      fastener: sheet.fastener,
      fastenerTone: sheet.fastenerTone,
      shadow: sheet.shadow,
      seed: sheet.seed ?? seed,
      padding: padding,
      child: keyed,
    );
  }

  Widget _monthColumn(
    DateTime month,
    int index,
    String seed,
    DateTime? target,
    DateTime? start,
    DateTime? end,
  ) {
    final weeks = CalendarDates.weeks(
      month,
      weekStartsOn: widget.weekStartsOn,
      fixedWeeks: widget.fixedWeeks,
    );
    final theme = LooseleafTheme.of(context);
    final width =
        widget.cell(theme.density) * 7 +
        switch (widget.showWeekNumber) {
          true => CalendarMetrics.weekNumber,
          false => 0,
        };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          child: CalendarCaption(
            month: month,
            layout: widget.captionLayout,
            cellSize: widget.cell(theme.density),
            formatters: widget.formatters,
            startMonth: start ?? DateTime(month.year - 100),
            endMonth: end ?? DateTime(month.year + 100, 12),
            seed: '$seed|$index',
            onMonthChange: (picked) =>
                _setMonth(CalendarDates.addMonths(picked, -index)),
          ),
        ),
        Semantics(
          container: true,
          label: widget.formatters.gridLabel(month),
          child: CalendarMonthGrid(
            weeks: weeks,
            seed: '$seed|$index',
            weekStartsOn: widget.weekStartsOn,
            showWeekNumber: widget.showWeekNumber,
            ruled: widget.ruled,
            formatters: widget.formatters,
            active: target,
            cellSize: widget.cell(theme.density),
            dayBuilder: (context, day, row) =>
                _day(context, month, day, row, target),
          ),
        ),
      ],
    );
  }

  Widget _day(
    BuildContext context,
    DateTime month,
    DateTime day,
    int row,
    DateTime? target,
  ) {
    final outside = day.month != month.month || day.year != month.year;
    final hidden =
        (outside && !widget.showOutsideDays) ||
        (widget.isDateHidden?.call(day) ?? false);
    if (hidden) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final selection = _selection;
    final column = CalendarDates.weekday(day, widget.weekStartsOn);
    final selected = selection.isSelected(day);
    final today = day == _today;
    final node = _node(day)..skipTraversal = day != target || outside;
    final number = Text(widget.formatters.day(day));
    return CalendarDayButton(
      day: day,
      size: widget.cell(theme.density),
      focusNode: node,
      outside: outside,
      disabled: _disabled(day),
      today: today,
      selected: selected,
      chosen: selection.isRinged(day),
      band: selection.band(day, first: column == 0, last: column == 6),
      bandFrame: row % bandFrames,
      semanticLabel: widget.formatters.dayLabel(
        day,
        today: today,
        selected: selected,
      ),
      onPressed: () => _pick(day),
      child: switch (widget.dayContentBuilder) {
        final builder? => builder(context, day, number),
        null => number,
      },
    );
  }
}
