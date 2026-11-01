import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';

/// The control that opens an [AlertDialog]; a [DialogTrigger] (use
/// `AlertDialogTrigger.builder` around your own `Button`).
///
/// Mirrors `AlertDialogTrigger` in upstream
/// `src/components/ui/alert-dialog.tsx`.
typedef AlertDialogTrigger = DialogTrigger;

/// An alert dialog's question, in the script face at 27 px.
///
/// Mirrors `AlertDialogTitle` in upstream
/// `src/components/ui/alert-dialog.tsx`.
typedef AlertDialogTitle = DialogTitle;

/// What answering means, in small muted ink.
///
/// Mirrors `AlertDialogDescription` in upstream
/// `src/components/ui/alert-dialog.tsx`.
typedef AlertDialogDescription = DialogDescription;

/// The size of an [AlertDialogContent].
enum AlertDialogSize {
  /// Up to 512 px wide; the media sits beside the title from 640 px.
  regular,

  /// Up to 320 px wide, centred, with the two answers side by side.
  small,
}

/// The mood of an [AlertDialogContent].
enum AlertDialogTone {
  /// A plain question.
  neutral,

  /// A risky one: hazard tape across the top corners.
  danger,
}

/// What an [AlertDialogContent] tells its header and footer.
class AlertDialogContentScope extends InheritedWidget {
  const AlertDialogContentScope({
    super.key,
    required this.size,
    required super.child,
  });

  /// The content's size.
  final AlertDialogSize size;

  /// The nearest content's size, regular outside one.
  static AlertDialogSize sizeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AlertDialogContentScope>()
          ?.size ??
      AlertDialogSize.regular;

  @override
  bool updateShouldNotify(AlertDialogContentScope oldWidget) =>
      oldWidget.size != size;
}
