import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs.dart';

/// What a [Folder] hands its tabs and panels: the open tab, the stock and
/// how to open another tab.
class FolderScope extends InheritedWidget {
  const FolderScope({
    super.key,
    required this.value,
    required this.stock,
    required this.activationMode,
    required this.select,
    required super.child,
  });

  /// The open tab's value.
  final String? value;

  /// What tabs and body are made of.
  final StockName stock;

  /// Whether arrowing onto a tab opens it.
  final TabsActivationMode activationMode;

  /// Opens the tab with this value.
  final ValueChanged<String> select;

  /// The nearest folder's scope, if any.
  static FolderScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FolderScope>();

  @override
  bool updateShouldNotify(FolderScope oldWidget) =>
      oldWidget.value != value ||
      oldWidget.stock != stock ||
      oldWidget.activationMode != activationMode ||
      oldWidget.select != select;
}
