import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// Hands an [Alert]'s tone to its parts, like upstream's
/// `*:data-[slot=alert-description]:text-*` variant classes.
class AlertScope extends InheritedWidget {
  const AlertScope({super.key, required this.tone, required super.child});

  /// The enclosing alert's tone.
  final AlertTone tone;

  /// The nearest alert's tone; [AlertTone.neutral] outside an alert.
  static AlertTone toneOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AlertScope>()?.tone ??
      AlertTone.neutral;

  @override
  bool updateShouldNotify(AlertScope oldWidget) => oldWidget.tone != tone;
}
