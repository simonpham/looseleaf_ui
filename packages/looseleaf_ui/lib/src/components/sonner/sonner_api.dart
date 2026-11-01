import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sonner/toast_controller.dart';
import 'package:looseleaf_ui/src/components/sonner/toast_data.dart';
import 'package:looseleaf_ui/src/components/sonner/toast_type.dart';

/// Shows toasts, Sonner style: `toast('Event created')`,
/// `toast.success(...)`, `toast.promise(...)`, `toast.dismiss(id)`. Each
/// call returns the toast's id; pass it back as `id` to update the toast.
///
/// Mirrors sonner's `toast` as re-exported by upstream
/// `src/components/ui/sonner.tsx`.
class Sonner {
  const Sonner([this._controller]);

  final ToastController? _controller;

  /// The toasts this adds to; [ToastController.instance] by default.
  ToastController get controller => _controller ?? ToastController.instance;

  /// A plain toast.
  Object call(
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    ToastButton? cancel,
    Duration? duration,
    bool dismissible = true,
    Widget? icon,
    VoidCallback? onDismiss,
    VoidCallback? onAutoClose,
  }) => _show(
    ToastType.normal,
    title,
    id: id,
    description: description,
    action: action,
    cancel: cancel,
    duration: duration,
    dismissible: dismissible,
    icon: icon,
    onDismiss: onDismiss,
    onAutoClose: onAutoClose,
  );

  /// A success toast on a green guest check.
  Object success(
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    Duration? duration,
  }) => _show(
    ToastType.success,
    title,
    id: id,
    description: description,
    action: action,
    duration: duration,
  );

  /// An error toast on a pink sticky.
  Object error(
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    Duration? duration,
  }) => _show(
    ToastType.error,
    title,
    id: id,
    description: description,
    action: action,
    duration: duration,
  );

  /// A warning toast on a yellow sticky.
  Object warning(
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    Duration? duration,
  }) => _show(
    ToastType.warning,
    title,
    id: id,
    description: description,
    action: action,
    duration: duration,
  );

  /// An info toast on a blue sticky.
  Object info(
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    Duration? duration,
  }) => _show(
    ToastType.info,
    title,
    id: id,
    description: description,
    action: action,
    duration: duration,
  );

  /// A loading toast with a spinning loader; it stays until updated.
  Object loading(String title, {Object? id, String? description}) =>
      _show(ToastType.loading, title, id: id, description: description);

  /// A loading toast that turns into a success or an error toast when
  /// [future] completes.
  Object promise<T>(
    Future<T> future, {
    required String loading,
    required String Function(T value) success,
    required String Function(Object error) error,
    Object? id,
  }) {
    final toastId = this.loading(loading, id: id);
    unawaited(
      future.then(
        (value) => this.success(success(value), id: toastId),
        onError: (Object failure) => this.error(error(failure), id: toastId),
      ),
    );
    return toastId;
  }

  /// Takes the toast with [id] away, or every toast when null.
  void dismiss([Object? id]) => controller.dismiss(id);

  Object _show(
    ToastType type,
    String title, {
    Object? id,
    String? description,
    ToastButton? action,
    ToastButton? cancel,
    Duration? duration,
    bool dismissible = true,
    Widget? icon,
    VoidCallback? onDismiss,
    VoidCallback? onAutoClose,
  }) => controller.show(
    ToastData(
      id: id ?? controller.nextId(),
      title: title,
      type: type,
      description: description,
      action: action,
      cancel: cancel,
      duration: duration,
      dismissible: dismissible,
      icon: icon,
      onDismiss: onDismiss,
      onAutoClose: onAutoClose,
    ),
  );
}

/// Shows a toast in the [Toaster]s on [ToastController.instance].
const toast = Sonner();
