/// How a [Calendar] picks days, react-day-picker's `mode`.
enum CalendarMode {
  /// One day; tapping it again clears it unless `required`.
  single,

  /// Any number of days, each tap toggles one.
  multiple,

  /// A first and a last day, drawn as one highlighter swipe per week.
  range,
}

/// What the caption above a month shows, react-day-picker's
/// `captionLayout`.
enum CalendarCaptionLayout {
  /// The month and year in script.
  label,

  /// Month and year dropdowns in pencil boxes.
  dropdown,

  /// A month dropdown and the year in script.
  dropdownMonths,

  /// The month in script and a year dropdown.
  dropdownYears,
}
