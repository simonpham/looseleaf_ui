import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';

/// What an [Attachment] tells its parts: its state, orientation and size.
///
/// Mirrors `AttachmentContext` in upstream `src/components/ui/attachment.tsx`.
class AttachmentScope extends InheritedWidget {
  const AttachmentScope({
    super.key,
    required this.state,
    required this.orientation,
    required this.size,
    required super.child,
  });

  final AttachmentState state;
  final AttachmentOrientation orientation;
  final AttachmentSize size;

  /// Whether the attachment is a vertical print.
  bool get vertical => orientation == AttachmentOrientation.vertical;

  /// The enclosing attachment's scope, or a done horizontal default one.
  static AttachmentScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AttachmentScope>() ??
      const AttachmentScope(
        state: AttachmentState.done,
        orientation: AttachmentOrientation.horizontal,
        size: AttachmentSize.regular,
        child: SizedBox.shrink(),
      );

  @override
  bool updateShouldNotify(AttachmentScope oldWidget) =>
      oldWidget.state != state ||
      oldWidget.orientation != orientation ||
      oldWidget.size != size;
}
