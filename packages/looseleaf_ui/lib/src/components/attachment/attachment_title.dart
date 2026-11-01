import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_pulse.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_scope.dart';

/// The file name on an [Attachment]: bold, one line, cut with an ellipsis.
/// It breathes while the file uploads or is processed.
///
/// Mirrors `AttachmentTitle` in upstream `src/components/ui/attachment.tsx`.
class AttachmentTitle extends StatelessWidget {
  const AttachmentTitle({super.key, required this.child});

  /// The name, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = AttachmentScope.of(context).state;
    return AttachmentPulse(
      active:
          state == AttachmentState.uploading ||
          state == AttachmentState.processing,
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: const TextStyle(fontWeight: FontWeight.w700),
        child: child,
      ),
    );
  }
}
