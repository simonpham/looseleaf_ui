import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row of [Attachment]s that scrolls sideways when they are wider than
/// the box, 12 px apart, with room above for clips and tape.
///
/// Mirrors `AttachmentGroup` in upstream `src/components/ui/attachment.tsx`.
class AttachmentGroup extends StatelessWidget {
  const AttachmentGroup({super.key, required this.children, this.controller});

  final List<Widget> children;

  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: controller,
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(
      Spacing.d12,
      Spacing.d16,
      Spacing.d12,
      Spacing.d12,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: children,
    ),
  );
}
