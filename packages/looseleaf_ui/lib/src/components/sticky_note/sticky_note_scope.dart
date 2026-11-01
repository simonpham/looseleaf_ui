import 'package:flutter/widgets.dart';

/// Tells a sticky note's parts whether the note is done, so
/// `StickyNoteContent` can strike itself through.
class StickyNoteScope extends InheritedWidget {
  const StickyNoteScope({super.key, required this.done, required super.child});

  /// Whether the note is ticked.
  final bool done;

  /// Whether the nearest note is done; false outside a note.
  static bool doneOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StickyNoteScope>()?.done ??
      false;

  @override
  bool updateShouldNotify(StickyNoteScope oldWidget) => oldWidget.done != done;
}
