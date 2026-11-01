import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/corkboard/corkboard.dart';

/// What a [Corkboard] shares with its notes: the layout, a way to change
/// it, the cork's size and the note being dragged.
class CorkboardScope extends InheritedWidget {
  const CorkboardScope({
    super.key,
    required this.positions,
    required this.update,
    required this.topZ,
    required this.surface,
    required this.disabled,
    required this.lift,
    required this.lifted,
    required super.child,
  });

  /// The layout by note id.
  final CorkboardValue positions;

  /// Lays a patch over note `id`'s position and announces `message`.
  final void Function(String id, NotePosition patch, String? message) update;

  /// The highest depth on the board.
  final int topZ;

  /// The cork's size (inside the frame).
  final Size surface;

  /// Notes stay put.
  final bool disabled;

  /// Raises note `id` over every other while it is dragged; null lets go.
  final ValueChanged<String?> lift;

  /// The note being dragged.
  final String? lifted;

  /// The nearest board's scope.
  static CorkboardScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CorkboardScope>();
    if (scope == null) {
      throw FlutterError('CorkboardNote must be used inside a Corkboard.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(CorkboardScope oldWidget) =>
      oldWidget.positions != positions ||
      oldWidget.topZ != topZ ||
      oldWidget.surface != surface ||
      oldWidget.disabled != disabled ||
      oldWidget.lifted != lifted;
}
