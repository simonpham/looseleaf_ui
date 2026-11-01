import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The words of an [Attachment]: an [AttachmentTitle], an
/// [AttachmentDescription] and maybe an [AttachmentProgress], stacked and
/// set tight. It takes the room the slip has left.
///
/// Mirrors `AttachmentContent` in upstream `src/components/ui/attachment.tsx`.
class AttachmentContent extends StatelessWidget {
  const AttachmentContent({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final vertical = AttachmentScope.of(context).vertical;
    return Padding(
      padding: switch (vertical) {
        true => const EdgeInsets.symmetric(horizontal: Spacing.d4),
        false => const EdgeInsetsDirectional.only(end: Spacing.d2),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
