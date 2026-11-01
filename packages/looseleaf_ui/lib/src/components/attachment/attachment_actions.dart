import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The buttons at the end of an [Attachment] (remove, retry, cancel),
/// usually [AttachmentAction]s. On a vertical print they sit in its top
/// corner, 4 px apart.
///
/// Mirrors `AttachmentActions` in upstream `src/components/ui/attachment.tsx`.
class AttachmentActions extends StatelessWidget {
  const AttachmentActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d4,
    children: children,
  );
}
