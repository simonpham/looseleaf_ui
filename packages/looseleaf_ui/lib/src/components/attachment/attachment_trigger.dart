import 'package:flutter/widgets.dart';

/// Makes a whole [Attachment] pressable (open the file): put it among the
/// attachment's children. The slip then shows its hover wash and a focus
/// ring; Enter and Space press it. Its own buttons stay on top.
///
/// ```dart
/// AttachmentTrigger(semanticLabel: 'Open tags-list.tsx', onPressed: open)
/// ```
///
/// Mirrors `AttachmentTrigger` in upstream `src/components/ui/attachment.tsx`.
class AttachmentTrigger extends StatelessWidget {
  const AttachmentTrigger({
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final VoidCallback? onPressed;

  /// The trigger's name, like `Open harbour.jpg`.
  final String? semanticLabel;

  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
