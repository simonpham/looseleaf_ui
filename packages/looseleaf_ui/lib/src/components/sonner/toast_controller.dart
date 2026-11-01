import 'package:flutter/foundation.dart';
import 'package:looseleaf_ui/src/components/sonner/toast_data.dart';

/// The toasts on show, newest last: what [toast] adds to and a [Toaster]
/// shows. [ToastController.instance] is the one the global [toast] and a
/// plain `Toaster` share.
class ToastController extends ChangeNotifier {
  ToastController();

  /// The shared controller.
  static final ToastController instance = ToastController();

  final List<ToastData> _toasts = [];
  int _next = 0;

  /// The toasts, oldest first.
  List<ToastData> get toasts => List.unmodifiable(_toasts);

  /// A fresh toast id.
  int nextId() => ++_next;

  /// Shows [data], or replaces the toast with its id.
  Object show(ToastData data) {
    final at = _toasts.indexWhere((toast) => toast.id == data.id);
    if (at < 0) {
      _toasts.add(data);
    } else {
      _toasts[at] = data;
    }
    notifyListeners();
    return data.id;
  }

  /// Takes the toast with [id] away, or every toast when null.
  void dismiss([Object? id]) {
    if (id == null) {
      _toasts.clear();
      notifyListeners();
      return;
    }
    final before = _toasts.length;
    _toasts.removeWhere((toast) => toast.id == id);
    if (_toasts.length != before) notifyListeners();
  }
}
