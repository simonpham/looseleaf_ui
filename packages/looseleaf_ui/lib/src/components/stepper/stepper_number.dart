import 'dart:math' as math;

/// The number handling of a [Stepper]: decimal places, rounding without
/// float drift, and a forgiving parser.
///
/// Mirrors `decimals` and `parseNumber` in upstream
/// `src/components/ui/stepper.tsx`.
abstract final class StepperNumber {
  /// The decimal places [n] is written with (`1e-7` has 7).
  static int decimals(num? n) {
    if (n == null || !n.isFinite) return 0;
    final text = _jsString(n.toDouble());
    if (text.contains('e-')) return int.parse(text.split('e-')[1]);
    final dot = text.indexOf('.');
    if (dot < 0) return 0;
    return text.length - dot - 1;
  }

  static String _jsString(double n) {
    if (n == n.roundToDouble() && n.abs() < 1e21) return n.round().toString();
    return n.toString();
  }

  /// [n] rounded to [places] decimals (at most 12).
  static double round(double n, int places) =>
      double.parse(n.toStringAsFixed(math.min(math.max(places, 0), 12)));

  /// [n] as upstream's `String(n)`: no trailing `.0`.
  static String plain(double n) => _jsString(n);

  /// The number in [text], or null: Arabic-Indic digits, `.` or `,` as the
  /// decimal point (the last one when both appear), grouping marks, spaces,
  /// apostrophes and a leading `+`, `-` or `−` are understood.
  static double? parse(String text) {
    final normalized = text
        .trim()
        .replaceAllMapped(
          RegExp('[٠-٩]'),
          (m) => '${(m[0] ?? '0').codeUnitAt(0) - 0x660}',
        )
        .replaceAllMapped(
          RegExp('[۰-۹]'),
          (m) => '${(m[0] ?? '0').codeUnitAt(0) - 0x6f0}',
        )
        .replaceAll('٫', '.')
        .replaceAll('٬', ',')
        .replaceAll(RegExp("[\\s  ']"), '');
    final match = RegExp('^([-+−]?)([\\d.,]*)\$').firstMatch(normalized);
    if (match == null) return null;
    final sign = match[1] ?? '';
    final body = match[2] ?? '';
    if (!RegExp(r'\d').hasMatch(body)) return null;
    final dots = body.split('.').length - 1;
    final commas = body.split(',').length - 1;
    final point = switch ((dots, commas)) {
      (> 0, > 0) => switch (body.lastIndexOf('.') > body.lastIndexOf(',')) {
        true => '.',
        false => ',',
      },
      (1, 0) => '.',
      (0, 1) => ',',
      _ => '',
    };
    final group = switch (point) {
      '.' => ',',
      ',' => '.',
      _ => switch ((dots > 1, commas > 1)) {
        (true, _) => '.',
        (false, true) => ',',
        _ => '',
      },
    };
    final at = switch (point) {
      '' => -1,
      _ => body.lastIndexOf(point),
    };
    final whole = switch (at < 0) {
      true => body,
      false => body.substring(0, at),
    };
    final fraction = switch (at < 0) {
      true => '',
      false => body.substring(at + 1),
    };
    final wholePattern = switch (group) {
      '' => RegExp(r'^\d*$'),
      _ => RegExp('^(\\d{1,3}(\\$group\\d{3})*)?\$'),
    };
    if (!wholePattern.hasMatch(whole) || !RegExp(r'^\d*$').hasMatch(fraction)) {
      return null;
    }
    final digits = whole.replaceAll(RegExp('[.,]'), '');
    final number = double.tryParse(
      '${switch (digits) {
        '' => '0',
        _ => digits,
      }}${switch (fraction) {
        '' => '',
        _ => '.$fraction',
      }}',
    );
    if (number == null || !number.isFinite) return null;
    return switch (sign) {
      '-' || '−' => -number,
      _ => number,
    };
  }
}
