import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_widget.dart';

/// Hands a [Dropzone]'s state to its parts.
class DropzoneScope extends InheritedWidget {
  const DropzoneScope({
    super.key,
    required this.state,
    required this.revision,
    required super.child,
  });

  final DropzoneState state;

  /// Bumped on every change, so parts rebuild.
  final int revision;

  /// The nearest scope; parts must sit inside a [Dropzone].
  static DropzoneScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DropzoneScope>();
    if (scope == null) {
      throw FlutterError('Dropzone parts must be used inside a Dropzone.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(DropzoneScope oldWidget) =>
      oldWidget.revision != revision || oldWidget.state != state;
}
