import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/looseleaf_theme_data.dart';

/// Provides a [LooseleafThemeData] to the widgets below it.
class LooseleafTheme extends InheritedWidget {
  const LooseleafTheme({super.key, required this.data, required super.child});

  final LooseleafThemeData data;

  static const LooseleafThemeData _fallback = LooseleafThemeData();

  /// The nearest theme, or Looseleaf's defaults when there is none.
  static LooseleafThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LooseleafTheme>()?.data ??
      _fallback;

  @override
  bool updateShouldNotify(LooseleafTheme oldWidget) => oldWidget.data != data;
}
