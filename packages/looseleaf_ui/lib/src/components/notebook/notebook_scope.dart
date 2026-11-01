import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// What a notebook tells its parts: the open page, how to turn to another,
/// which edge is bound and the height of a ruled line.
class NotebookScope extends InheritedWidget {
  const NotebookScope({
    super.key,
    required this.value,
    required this.onTurn,
    required this.side,
    required this.lineHeight,
    required super.child,
  });

  /// The open page's value; null when the notebook is not paged.
  final String? value;

  /// Turns to the page with this value.
  final ValueChanged<String> onTurn;

  /// The bound edge.
  final NotebookSide side;

  /// The ruled line's height: 28 px, 24 when calm, 30 bound on top.
  final double lineHeight;

  /// The nearest notebook's scope, if any.
  static NotebookScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NotebookScope>();

  @override
  bool updateShouldNotify(NotebookScope oldWidget) =>
      oldWidget.value != value ||
      oldWidget.side != side ||
      oldWidget.lineHeight != lineHeight ||
      oldWidget.onTurn != onTurn;
}
