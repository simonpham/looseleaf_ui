import 'package:flutter/widgets.dart';

/// What an [InputOTP] accepts, upstream's `REGEXP_ONLY_*` patterns.
enum InputOTPPattern {
  /// `REGEXP_ONLY_DIGITS`: 0 to 9.
  digits(r'[0-9]'),

  /// `REGEXP_ONLY_CHARS`: letters.
  chars(r'[a-zA-Z]'),

  /// `REGEXP_ONLY_DIGITS_AND_CHARS`: letters and digits.
  digitsAndChars(r'[a-zA-Z0-9]');

  const InputOTPPattern(this.source);

  /// One allowed character, as a regular expression.
  final String source;
}

/// What an [InputOTP] tells its slots: the code, the active slot and the
/// shared states.
class InputOTPScope extends InheritedWidget {
  const InputOTPScope({
    super.key,
    required this.text,
    required this.active,
    required this.focused,
    required this.invalid,
    required this.disabled,
    required this.touched,
    required this.placeholder,
    required super.child,
  });

  /// The code typed so far.
  final String text;

  /// The slot holding the caret, or null while unfocused.
  final int? active;

  /// The code field has focus.
  final bool focused;

  final bool invalid;
  final bool disabled;

  /// The user has typed, so new characters pop in.
  final bool touched;

  /// One placeholder character per slot; empty for none.
  final String placeholder;

  /// The nearest code input, or null outside one.
  static InputOTPScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InputOTPScope>();

  /// The character in slot [index], or null when it is empty.
  String? charAt(int index) => switch (index < text.length) {
    true => text[index],
    false => null,
  };

  /// The placeholder of slot [index], or null.
  String? placeholderAt(int index) => switch (index < placeholder.length) {
    true => placeholder[index],
    false => null,
  };

  @override
  bool updateShouldNotify(InputOTPScope oldWidget) =>
      oldWidget.text != text ||
      oldWidget.active != active ||
      oldWidget.focused != focused ||
      oldWidget.invalid != invalid ||
      oldWidget.disabled != disabled ||
      oldWidget.touched != touched ||
      oldWidget.placeholder != placeholder;
}
