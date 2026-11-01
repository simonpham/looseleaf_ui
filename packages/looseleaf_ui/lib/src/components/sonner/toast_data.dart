import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sonner/toast_type.dart';

/// A labelled button on a toast: the highlighted action or the wavy
/// underlined cancel.
class ToastButton {
  const ToastButton({required this.label, required this.onPressed});

  final String label;

  /// Called on press; the toast closes after.
  final VoidCallback onPressed;
}

/// One toast as the [ToastController] keeps it.
@immutable
class ToastData {
  const ToastData({
    required this.id,
    required this.title,
    this.type = ToastType.normal,
    this.description,
    this.action,
    this.cancel,
    this.duration,
    this.dismissible = true,
    this.icon,
    this.onDismiss,
    this.onAutoClose,
  });

  final Object id;
  final String title;
  final ToastType type;
  final String? description;
  final ToastButton? action;
  final ToastButton? cancel;

  /// How long it stays; the [Toaster]'s when null. Loading toasts stay until
  /// updated.
  final Duration? duration;

  /// Whether a swipe or the close button may take it away.
  final bool dismissible;

  /// An icon over the type's own.
  final Widget? icon;

  /// Called when the user closes it.
  final VoidCallback? onDismiss;

  /// Called when it times out.
  final VoidCallback? onAutoClose;

  ToastData copyWith({
    String? title,
    ToastType? type,
    String? description,
    Duration? duration,
  }) => ToastData(
    id: id,
    title: title ?? this.title,
    type: type ?? this.type,
    description: description ?? this.description,
    action: action,
    cancel: cancel,
    duration: duration ?? this.duration,
    dismissible: dismissible,
    icon: icon,
    onDismiss: onDismiss,
    onAutoClose: onAutoClose,
  );
}
