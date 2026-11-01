import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// Whether moving onto a tab with the arrow keys also opens it.
enum TabsActivationMode {
  /// Arrows open the tab they land on (Radix's default).
  automatic,

  /// Arrows only move focus; Enter or Space opens.
  manual,
}

/// What [Tabs] hands its list, triggers and panels.
class TabsScope extends InheritedWidget {
  const TabsScope({
    super.key,
    required this.value,
    required this.orientation,
    required this.activationMode,
    required this.select,
    required super.child,
  });

  /// The open tab's value.
  final String? value;
  final TabsOrientation orientation;
  final TabsActivationMode activationMode;

  /// Opens the tab with this value.
  final ValueChanged<String> select;

  static TabsScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabsScope>();

  @override
  bool updateShouldNotify(TabsScope oldWidget) =>
      oldWidget.value != value ||
      oldWidget.orientation != orientation ||
      oldWidget.activationMode != activationMode ||
      oldWidget.select != select;
}

/// The [TabsVariant] a [TabsList] hands its triggers.
class TabsListScope extends InheritedWidget {
  const TabsListScope({super.key, required this.variant, required super.child});

  final TabsVariant variant;

  static TabsListScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabsListScope>();

  @override
  bool updateShouldNotify(TabsListScope oldWidget) =>
      oldWidget.variant != variant;
}
